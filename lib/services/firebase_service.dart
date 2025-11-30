import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uuid/uuid.dart';
import '../models/clothing_item.dart';
import '../utils/constants.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();
  
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
  
  // ==================== BASE64 UTILS ====================
  
  /// Convert bytes to Base64 string (thay thế Firebase Storage)
  String convertToBase64(Uint8List bytes) {
    return base64Encode(bytes);
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
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      return await _auth.signInWithPopup(googleProvider);
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
  Future<UserCredential?> registerWithEmail(String email, String password) async {
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

  // ==================== STORAGE ====================
  
  /// Upload clothing image
  Future<String?> uploadClothingImage(File imageFile) async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');
      
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage.ref()
          .child(AppConstants.clothingImagesPath)
          .child(userId)
          .child(fileName);
      
      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Upload Error: $e');
      return null;
    }
  }

  
  
  /// Delete image from storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Delete Image Error: $e');
      return false;
    }
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
      
      final docRef = await _itemsRef.add(json).timeout(
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
  Future<bool> deleteClothingItem(String itemId, String? imageUrl) async {
    try {
      // Nếu có imageUrl (legacy), xóa từ storage
      if (imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
        await deleteImage(imageUrl);
      }
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
