import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/clothing_item.dart';
import '../utils/constants.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _persistenceSet = false;

  /// Thiết lập persistence cho Firebase Auth (gọi trước khi đăng nhập)
  Future<void> ensurePersistence() async {
    if (_persistenceSet) return;

    if (kIsWeb) {
      try {
        // Trên Web: giữ phiên đăng nhập trong localStorage (persist qua reload/restart)
        await _auth.setPersistence(Persistence.LOCAL);
        print('Firebase Auth persistence set to LOCAL');
      } catch (e) {
        print('Error setting persistence: $e');
      }
    }
    // Trên Mobile: Firebase Auth tự động persist bằng secure storage
    _persistenceSet = true;
  }

  // ==================== BASE64 & COMPRESSION UTILS ====================

  /// Compress image automatically and convert to Base64
  Future<String> compressAndConvertToBase64(Uint8List bytes) async {
    try {
      // Nén ảnh xuống còn ~200KB để đảm bảo an toàn với Firestore (1MB limit)
      // Base64 encoding thêm ~37% overhead, nên 200KB raw → ~270KB Base64
      final compressed = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 800, // Giảm width tối đa xuống 800px
        minHeight: 800, // Giảm height tối đa xuống 800px
        quality: 85, // Chất lượng 85% (balance giữa size và quality)
      );

      final originalSize = bytes.length;
      final compressedSize = compressed.length;
      final ratio = ((originalSize - compressedSize) / originalSize * 100)
          .toStringAsFixed(1);

      print(
        '📦 Image compressed: ${(originalSize / 1024).toStringAsFixed(1)}KB → '
        '${(compressedSize / 1024).toStringAsFixed(1)}KB '
        '(saved $ratio%)',
      );

      return base64Encode(compressed);
    } catch (e) {
      print('⚠️ Compression failed, using original: $e');
      return base64Encode(bytes);
    }
  }

  // ==================== AUTH ====================

  /// Current user
  User? get currentUser => _auth.currentUser;

  /// Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if logged in
  bool get isLoggedIn => currentUser != null;

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web: use signInWithPopup
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // Android/iOS: use google_sign_in package
        final googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          print('Google Sign-In cancelled by user');
          return null;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  /// Sign in anonymously (for testing)
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print('Anonymous Sign-In Error: $e');
      return null;
    }
  }

  /// Sign in with Email/Password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Email Sign-In Error: $e');
      rethrow;
    }
  }

  /// Register with Email/Password
  Future<UserCredential?> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Email Register Error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ==================== FIRESTORE - ITEMS ====================

  /// Get items collection reference
  CollectionReference<Map<String, dynamic>> get _itemsRef =>
      _firestore.collection(AppConstants.itemsCollection);

  /// Add new clothing item
  Future<String?> addClothingItem(ClothingItem item) async {
    try {
      print('📝 Preparing to add item to Firestore...');
      final json = item.toJson();
      print('📦 JSON data size: ${json.toString().length} chars');
      print('🔄 Adding to collection: ${AppConstants.itemsCollection}');

      final docRef = await _itemsRef
          .add(json)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Firestore timeout after 30 seconds');
            },
          );

      print('✅ Document added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Add Item Error: $e');
      return null;
    }
  }

  /// Update clothing item
  Future<bool> updateClothingItem(ClothingItem item) async {
    try {
      await _itemsRef.doc(item.id).update(item.toJson());
      return true;
    } catch (e) {
      print('Update Item Error: $e');
      return false;
    }
  }

  /// Delete clothing item
  Future<bool> deleteClothingItem(String itemId) async {
    try {
      // Delete document from Firestore (Base64 sẽ tự động bị xóa cùng document)
      await _itemsRef.doc(itemId).delete();
      return true;
    } catch (e) {
      print('Delete Item Error: $e');
      return false;
    }
  }

  /// Get all items for current user
  Future<List<ClothingItem>> getUserItems() async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _itemsRef
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ClothingItem.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get Items Error: $e');
      return [];
    }
  }

  /// Update item's last worn date
  Future<bool> markAsWorn(String itemId) async {
    try {
      await _itemsRef.doc(itemId).update({
        'lastWorn': Timestamp.now(),
        'wearCount': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      print('Mark As Worn Error: $e');
      return false;
    }
  }

  /// Toggle favorite
  Future<bool> toggleFavorite(String itemId, bool isFavorite) async {
    try {
      await _itemsRef.doc(itemId).update({'isFavorite': isFavorite});
      return true;
    } catch (e) {
      print('Toggle Favorite Error: $e');
      return false;
    }
  }
}
