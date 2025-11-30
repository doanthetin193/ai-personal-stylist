import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../models/weather.dart';
import '../services/firebase_service.dart';
import '../services/gemini_service.dart';
import '../services/weather_service.dart';
import '../utils/constants.dart';

enum WardrobeStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Style preference cho gợi ý outfit
enum StylePreference {
  loose,    // Thích đồ rộng
  regular,  // Vừa vặn
  fitted;   // Ôm body

  String get displayName {
    switch (this) {
      case StylePreference.loose:
        return 'Đồ rộng thoải mái';
      case StylePreference.regular:
        return 'Vừa vặn';
      case StylePreference.fitted:
        return 'Ôm body';
    }
  }

  String get aiDescription {
    switch (this) {
      case StylePreference.loose:
        return 'User prefers loose, relaxed, oversized clothing. Prioritize comfort over fitted looks.';
      case StylePreference.regular:
        return 'User prefers regular fit clothing, balanced between loose and fitted.';
      case StylePreference.fitted:
        return 'User prefers fitted, slim, body-hugging clothing. Prioritize sleek silhouettes.';
    }
  }
}

class WardrobeProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final GeminiService _geminiService;
  final WeatherService _weatherService;
  final _uuid = const Uuid();

  // State
  WardrobeStatus _status = WardrobeStatus.initial;
  List<ClothingItem> _items = [];
  WeatherInfo? _weather;
  String? _errorMessage;
  bool _isAnalyzing = false;
  bool _isSuggestingOutfit = false;
  
  // Style preference
  StylePreference _stylePreference = StylePreference.regular;
  
  // Current outfit suggestion
  Outfit? _currentOutfit;
  
  // Filter state
  ClothingType? _filterType;
  String? _filterCategory;

  WardrobeProvider(
    this._firebaseService,
    this._geminiService,
    this._weatherService,
  );

  // Getters
  WardrobeStatus get status => _status;
  List<ClothingItem> get items => _filteredItems;
  List<ClothingItem> get allItems => _items;
  WeatherInfo? get weather => _weather;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == WardrobeStatus.loading;
  bool get isAnalyzing => _isAnalyzing;
  bool get isSuggestingOutfit => _isSuggestingOutfit;
  Outfit? get currentOutfit => _currentOutfit;
  ClothingType? get filterType => _filterType;
  String? get filterCategory => _filterCategory;
  StylePreference get stylePreference => _stylePreference;
  
  // Filtered items
  List<ClothingItem> get _filteredItems {
    if (_filterType != null) {
      return _items.where((item) => item.type == _filterType).toList();
    }
    if (_filterCategory != null) {
      return _items.where((item) => item.type.category == _filterCategory).toList();
    }
    return _items;
  }

  /// Get items grouped by type (for display)
  Map<ClothingType, List<ClothingItem>> get itemsByType {
    final map = <ClothingType, List<ClothingItem>>{};
    for (final item in _items) {
      if (map[item.type] == null) {
        map[item.type] = [];
      }
      map[item.type]!.add(item);
    }
    return map;
  }

  /// Load all items for current user
  Future<void> loadItems() async {
    try {
      _status = WardrobeStatus.loading;
      _errorMessage = null;
      notifyListeners();

      _items = await _firebaseService.getUserItems();
      _status = WardrobeStatus.loaded;
      notifyListeners();
    } catch (e) {
      _status = WardrobeStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Load weather
  Future<void> loadWeather({String? city}) async {
    try {
      _weather = await _weatherService.getCurrentWeather(
        city: city ?? AppConstants.defaultCity,
      );
      notifyListeners();
    } catch (e) {
      print('Load Weather Error: $e');
    }
  }

  /// Change weather location
  Future<void> changeWeatherLocation(String city) async {
    _weatherService.clearCache();
    await loadWeather(city: city);
  }

  /// Add new item with image analysis
  Future<ClothingItem?> addItem(File imageFile) async {
    try {
      _isAnalyzing = true;
      _errorMessage = null;
      notifyListeners();

      // 1. Upload image to Firebase Storage
      final imageUrl = await _firebaseService.uploadClothingImage(imageFile);
      if (imageUrl == null) {
        throw Exception('Không thể upload ảnh');
      }

      // 2. Analyze image with Gemini
      final analysis = await _geminiService.analyzeClothingImage(imageFile);
      
      // 3. Create ClothingItem
      final userId = _firebaseService.currentUser?.uid;
      if (userId == null) {
        throw Exception('Chưa đăng nhập');
      }

      final item = ClothingItem(
        id: '', // Will be set after Firestore add
        userId: userId,
        imageUrl: imageUrl,
        type: analysis != null 
            ? ClothingType.fromString(analysis['type'] ?? 'other')
            : ClothingType.other,
        color: analysis?['color'] ?? 'unknown',
        material: analysis?['material'],
        styles: analysis != null && analysis['styles'] != null
            ? (analysis['styles'] as List)
                .map((s) => ClothingStyle.fromString(s.toString()))
                .toList()
            : [ClothingStyle.casual],
        seasons: analysis != null && analysis['seasons'] != null
            ? (analysis['seasons'] as List)
                .map((s) => Season.fromString(s.toString()))
                .toList()
            : [Season.summer],
        createdAt: DateTime.now(),
      );

      // 4. Save to Firestore
      final docId = await _firebaseService.addClothingItem(item);
      if (docId == null) {
        throw Exception('Không thể lưu item');
      }

      final savedItem = item.copyWith(id: docId);
      _items.insert(0, savedItem);
      
      _isAnalyzing = false;
      notifyListeners();
      
      return savedItem;
    } catch (e) {
      _isAnalyzing = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Add item from bytes (for Web)
  Future<ClothingItem?> addItemFromBytes(
    Uint8List imageBytes, {
    required ClothingType type,
    required String color,
    required List<ClothingStyle> styles,
    required List<Season> seasons,
    String? material,
  }) async {
    try {
      _isAnalyzing = true;
      _errorMessage = null;
      notifyListeners();

      // Compress nếu ảnh quá lớn (> 100KB)
      Uint8List finalBytes = imageBytes;
      if (imageBytes.length > 100000) {
        print('⚠️ Image is large (${imageBytes.length} bytes), consider compressing');
      }

      print('📤 Converting image to Base64... (${finalBytes.length} bytes)');
      
      // 1. Convert image to Base64 (không cần Firebase Storage)
      final imageBase64 = _firebaseService.convertToBase64(finalBytes);
      print('✅ Image converted to Base64 (${imageBase64.length} chars)');
      
      // Cảnh báo nếu data quá lớn
      if (imageBase64.length > 500000) {
        print('⚠️ WARNING: Base64 data is very large (${imageBase64.length} chars). This may cause slow save.');
      }

      // 2. Create ClothingItem with provided data
      final userId = _firebaseService.currentUser?.uid;
      if (userId == null) {
        throw Exception('Chưa đăng nhập');
      }
      print('👤 User ID: $userId');

      final item = ClothingItem(
        id: '',
        userId: userId,
        imageBase64: imageBase64,
        type: type,
        color: color,
        material: material,
        styles: styles,
        seasons: seasons,
        createdAt: DateTime.now(),
      );

      print('💾 Saving to Firestore...');
      // 3. Save to Firestore
      final docId = await _firebaseService.addClothingItem(item);
      if (docId == null) {
        throw Exception('Không thể lưu item. Vui lòng kiểm tra:\n1. Firestore Rules đã cho phép write\n2. Kết nối internet ổn định');
      }
      print('✅ Saved with ID: $docId');

      final savedItem = item.copyWith(id: docId);
      _items.insert(0, savedItem);
      
      _isAnalyzing = false;
      notifyListeners();
      
      return savedItem;
    } catch (e) {
      print('❌ Error saving item: $e');
      _isAnalyzing = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Add item from file (for Mobile)
  Future<ClothingItem?> addItemFromFile(
    File imageFile, {
    required ClothingType type,
    required String color,
    required List<ClothingStyle> styles,
    required List<Season> seasons,
    String? material,
  }) async {
    try {
      _isAnalyzing = true;
      _errorMessage = null;
      notifyListeners();

      // 1. Upload image to Firebase Storage
      final imageUrl = await _firebaseService.uploadClothingImage(imageFile);
      if (imageUrl == null) {
        throw Exception('Không thể upload ảnh');
      }

      // 2. Create ClothingItem with provided data
      final userId = _firebaseService.currentUser?.uid;
      if (userId == null) {
        throw Exception('Chưa đăng nhập');
      }

      final item = ClothingItem(
        id: '',
        userId: userId,
        imageUrl: imageUrl,
        type: type,
        color: color,
        material: material,
        styles: styles,
        seasons: seasons,
        createdAt: DateTime.now(),
      );

      // 3. Save to Firestore
      final docId = await _firebaseService.addClothingItem(item);
      if (docId == null) {
        throw Exception('Không thể lưu item');
      }

      final savedItem = item.copyWith(id: docId);
      _items.insert(0, savedItem);
      
      _isAnalyzing = false;
      notifyListeners();
      
      return savedItem;
    } catch (e) {
      _isAnalyzing = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Update item
  Future<bool> updateItem(ClothingItem item) async {
    try {
      final success = await _firebaseService.updateClothingItem(item);
      if (success) {
        final index = _items.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          _items[index] = item;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Toggle favorite
  Future<void> toggleFavorite(ClothingItem item) async {
    final newValue = !item.isFavorite;
    final success = await _firebaseService.toggleFavorite(item.id, newValue);
    if (success) {
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item.copyWith(isFavorite: newValue);
        notifyListeners();
      }
    }
  }

  /// Mark item as worn
  Future<void> markAsWorn(ClothingItem item) async {
    final success = await _firebaseService.markAsWorn(item.id);
    if (success) {
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item.copyWith(
          lastWorn: DateTime.now(),
          wearCount: item.wearCount + 1,
        );
        notifyListeners();
      }
    }
  }

  /// Set style preference
  void setStylePreference(StylePreference preference) {
    _stylePreference = preference;
    notifyListeners();
  }

  /// Suggest outfit
  Future<Outfit?> suggestOutfit(String occasion) async {
    try {
      _isSuggestingOutfit = true;
      _errorMessage = null;
      notifyListeners();

      // Get weather context
      final weatherContext = _weather?.toAIDescription() ?? 
          'Temperature: 28°C, Humidity: 70%, Condition: Ấm áp';

      // Call AI
      final suggestion = await _geminiService.suggestOutfit(
        wardrobe: _items,
        weatherContext: weatherContext,
        occasion: occasion,
        stylePreference: _stylePreference.aiDescription,
      );

      if (suggestion == null) {
        throw Exception('AI không thể gợi ý outfit');
      }

      // Build outfit from suggestion
      final outfit = _buildOutfitFromSuggestion(suggestion, occasion);
      _currentOutfit = outfit;
      
      _isSuggestingOutfit = false;
      notifyListeners();
      
      return outfit;
    } catch (e) {
      _isSuggestingOutfit = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Build Outfit object from AI suggestion
  Outfit _buildOutfitFromSuggestion(
    Map<String, dynamic> suggestion,
    String occasion,
  ) {
    ClothingItem? findItem(String? id) {
      if (id == null || id == 'null') return null;
      return _items.firstWhere(
        (item) => item.id == id,
        orElse: () => _items.first,
      );
    }

    final accessoryIds = suggestion['accessories'] as List<dynamic>? ?? [];
    final accessories = accessoryIds
        .map((id) => findItem(id.toString()))
        .whereType<ClothingItem>()
        .toList();

    return Outfit(
      id: _uuid.v4(),
      top: findItem(suggestion['top']?.toString()),
      bottom: findItem(suggestion['bottom']?.toString()),
      outerwear: findItem(suggestion['outerwear']?.toString()),
      footwear: findItem(suggestion['footwear']?.toString()),
      accessories: accessories,
      occasion: occasion,
      reason: suggestion['reason'] ?? 'Gợi ý từ AI',
      createdAt: DateTime.now(),
    );
  }

  /// Evaluate color harmony
  Future<ColorHarmonyResult?> evaluateColorHarmony(
    ClothingItem item1,
    ClothingItem item2,
  ) async {
    return await _geminiService.evaluateColorHarmony(item1, item2);
  }

  /// Get cleanup suggestions from AI
  Future<Map<String, dynamic>?> getCleanupSuggestions() async {
    if (_items.isEmpty) return null;
    return await _geminiService.getCleanupSuggestions(_items);
  }

  /// Delete item by ID
  Future<bool> deleteItem(String itemId) async {
    try {
      final item = _items.firstWhere((i) => i.id == itemId);
      final success = await _firebaseService.deleteClothingItem(
        item.id, 
        item.imageUrl,
      );
      if (success) {
        _items.removeWhere((i) => i.id == itemId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete all items
  Future<bool> deleteAllItems() async {
    try {
      final itemIds = _items.map((i) => i.id).toList();
      
      for (final id in itemIds) {
        await deleteItem(id);
      }
      
      _items.clear();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Set filter by category
  void setFilterCategory(String? category) {
    _filterCategory = category;
    _filterType = null;
    notifyListeners();
  }

  void clearFilter() {
    _filterType = null;
    _filterCategory = null;
    notifyListeners();
  }
}
