import 'package:flutter/material.dart';
import '../models/saved_outfit.dart';
import '../services/firebase_service.dart';

class LookbookProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  
  List<SavedOutfit> _savedOutfits = [];
  bool _isLoading = false;

  LookbookProvider(this._firebaseService);

  List<SavedOutfit> get savedOutfits => _savedOutfits;
  bool get isLoading => _isLoading;

  Future<void> loadSavedOutfits() async {
    _isLoading = true;
    notifyListeners();

    _savedOutfits = await _firebaseService.getUserSavedOutfits();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveOutfit({
    required String? topId,
    required String? bottomId,
    String? outerwearId,
    required String? footwearId,
    List<String> accessoryIds = const [],
    required String source,
    String? name,
  }) async {
    final userId = _firebaseService.currentUser?.uid;
    if (userId == null) return false;

    final outfit = SavedOutfit(
      id: '', // Firestore sẽ tự tạo ID
      userId: userId,
      name: name,
      topId: topId,
      bottomId: bottomId,
      outerwearId: outerwearId,
      footwearId: footwearId,
      accessoryIds: accessoryIds,
      source: source,
      createdAt: DateTime.now(),
    );

    final id = await _firebaseService.saveOutfit(outfit);
    if (id != null) {
      // Thêm vào danh sách hiện tại để cập nhật UI ngay lập tức
      final newOutfit = SavedOutfit(
        id: id,
        userId: userId,
        name: name,
        topId: topId,
        bottomId: bottomId,
        outerwearId: outerwearId,
        footwearId: footwearId,
        accessoryIds: accessoryIds,
        source: source,
        createdAt: outfit.createdAt,
      );
      _savedOutfits.insert(0, newOutfit);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteOutfit(String outfitId) async {
    final success = await _firebaseService.deleteSavedOutfit(outfitId);
    if (success) {
      _savedOutfits.removeWhere((o) => o.id == outfitId);
      notifyListeners();
    }
    return success;
  }
}
