import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../models/weather.dart';
import '../services/firebase_service.dart';
import '../services/groq_service.dart';
import '../services/weather_service.dart';
import '../utils/constants.dart';

enum WardrobeStatus { initial, loading, loaded, error }

/// Style preference cho gợi ý outfit
enum StylePreference {
  loose, // Thích đồ rộng
  regular, // Vừa vặn
  fitted; // Ôm body

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
        return 'Secondary fit preference only: user prefers loose, relaxed, oversized silhouettes.';
      case StylePreference.regular:
        return 'Secondary fit preference only: user prefers regular fit clothing, balanced between loose and fitted.';
      case StylePreference.fitted:
        return 'Secondary fit preference only: user prefers fitted, slim, body-hugging silhouettes.';
    }
  }
}

enum GenderPreference {
  male,
  female;

  String get displayName {
    switch (this) {
      case GenderPreference.male:
        return 'Nam';
      case GenderPreference.female:
        return 'Nữ';
    }
  }

  String get firestoreValue {
    switch (this) {
      case GenderPreference.male:
        return 'male';
      case GenderPreference.female:
        return 'female';
    }
  }

  String get aiDescription {
    switch (this) {
      case GenderPreference.male:
        return 'User gender profile is male. Avoid dress and skirt unless no other reasonable option exists.';
      case GenderPreference.female:
        return 'User gender profile is female. Standard women wardrobe suggestions are allowed.';
    }
  }

  static GenderPreference? fromString(String? value) {
    if (value == null || value.isEmpty) return null;

    switch (value.toLowerCase()) {
      case 'male':
      case 'nam':
        return GenderPreference.male;
      case 'female':
      case 'nu':
      case 'nữ':
        return GenderPreference.female;
      default:
        return null;
    }
  }
}

enum OutfitStyleProfile {
  masculine,
  feminine,
  unisex,
  flexible;

  String get displayName {
    switch (this) {
      case OutfitStyleProfile.masculine:
        return 'Nam tính';
      case OutfitStyleProfile.feminine:
        return 'Nữ tính';
      case OutfitStyleProfile.unisex:
        return 'Unisex';
      case OutfitStyleProfile.flexible:
        return 'Linh hoạt';
    }
  }

  String get description {
    switch (this) {
      case OutfitStyleProfile.masculine:
        return 'Ưu tiên outfit nam tính, hạn chế váy/chân váy.';
      case OutfitStyleProfile.feminine:
        return 'Ưu tiên outfit nữ tính.';
      case OutfitStyleProfile.unisex:
        return 'Ưu tiên đồ trung tính, nam nữ đều mặc hợp.';
      case OutfitStyleProfile.flexible:
        return 'Cho phép mix đa dạng miễn tổng thể hài hòa.';
    }
  }

  String get firestoreValue {
    switch (this) {
      case OutfitStyleProfile.masculine:
        return 'masculine';
      case OutfitStyleProfile.feminine:
        return 'feminine';
      case OutfitStyleProfile.unisex:
        return 'unisex';
      case OutfitStyleProfile.flexible:
        return 'flexible';
    }
  }

  String get aiDescription {
    switch (this) {
      case OutfitStyleProfile.masculine:
        return 'Style profile is masculine. Avoid dress and skirt items.';
      case OutfitStyleProfile.feminine:
        return 'Style profile is feminine. Feminine silhouettes are preferred.';
      case OutfitStyleProfile.unisex:
        return 'Style profile is unisex. Prioritize neutral, cross-gender styling.';
      case OutfitStyleProfile.flexible:
        return 'Style profile is flexible. You may mix feminine and masculine pieces when harmonious.';
    }
  }

  static OutfitStyleProfile? fromString(String? value) {
    if (value == null || value.isEmpty) return null;

    switch (value.toLowerCase()) {
      case 'masculine':
      case 'nam_tinh':
      case 'nam tính':
        return OutfitStyleProfile.masculine;
      case 'feminine':
      case 'nu_tinh':
      case 'nữ tính':
        return OutfitStyleProfile.feminine;
      case 'unisex':
      case 'neutral':
        return OutfitStyleProfile.unisex;
      case 'flexible':
      case 'linh_hoat':
      case 'linh hoạt':
        return OutfitStyleProfile.flexible;
      default:
        return null;
    }
  }

  static OutfitStyleProfile defaultForGender(GenderPreference? gender) {
    switch (gender) {
      case GenderPreference.male:
        return OutfitStyleProfile.masculine;
      case GenderPreference.female:
        return OutfitStyleProfile.feminine;
      default:
        return OutfitStyleProfile.unisex;
    }
  }
}

class WardrobeProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final GroqService _groqService;
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
  GenderPreference? _genderPreference;
  OutfitStyleProfile? _outfitStyleProfile;

  // Current outfit suggestion
  Outfit? _currentOutfit;

  // Filter state
  String? _filterCategory;

  WardrobeProvider(
    this._firebaseService,
    this._groqService,
    this._weatherService,
  );

  // Getters
  WardrobeStatus get status => _status;
  List<ClothingItem> get items =>
      _filteredItems; //để hiển thị UI bao gồm cả lọc hoặc tất cả
  List<ClothingItem> get allItems => _items; //để AI gợi ý
  WeatherInfo? get weather => _weather;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == WardrobeStatus.loading;
  bool get isAnalyzing => _isAnalyzing;
  bool get isSuggestingOutfit => _isSuggestingOutfit;
  Outfit? get currentOutfit => _currentOutfit;
  StylePreference get stylePreference => _stylePreference;
  GenderPreference? get genderPreference => _genderPreference;
  OutfitStyleProfile? get outfitStyleProfile => _outfitStyleProfile;
  bool get hasGenderPreference => _genderPreference != null;
  bool get hasIdentityPreferences =>
      _genderPreference != null && _outfitStyleProfile != null;

  OutfitStyleProfile get effectiveOutfitStyleProfile {
    return _outfitStyleProfile ??
        OutfitStyleProfile.defaultForGender(_genderPreference);
  }

  // Filtered items
  List<ClothingItem> get _filteredItems {
    if (_filterCategory != null) {
      return _items
          .where((item) => item.type.category == _filterCategory)
          .toList();
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

      print(
        '🖼️ Original image size: ${(imageBytes.length / 1024).toStringAsFixed(1)}KB',
      );

      // 1. Tự động nén và convert image to Base64 (thay thế Firebase Storage)
      final imageBase64 = await _firebaseService.compressAndConvertToBase64(
        imageBytes,
      );
      print(
        '✅ Image compressed and converted to Base64 (${imageBase64.length} chars)',
      );

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
        throw Exception(
          'Không thể lưu item. Vui lòng kiểm tra:\n1. Firestore Rules đã cho phép write\n2. Kết nối internet ổn định',
        );
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

  Future<void> loadGenderPreference() async {
    final rawGender = await _firebaseService.getUserGenderPreference();
    final rawStyleProfile = await _firebaseService
        .getUserStyleProfilePreference();
    final parsedGender = GenderPreference.fromString(rawGender);
    final parsedStyleProfile = OutfitStyleProfile.fromString(rawStyleProfile);

    if (parsedGender != _genderPreference ||
        parsedStyleProfile != _outfitStyleProfile) {
      _genderPreference = parsedGender;
      _outfitStyleProfile = parsedStyleProfile;
      notifyListeners();
    }
  }

  Future<bool> saveGenderPreference(GenderPreference preference) async {
    final success = await _firebaseService.saveUserIdentityPreferences(
      gender: preference.firestoreValue,
      styleProfile:
          (_outfitStyleProfile ??
                  OutfitStyleProfile.defaultForGender(preference))
              .firestoreValue,
    );

    if (success) {
      _genderPreference = preference;
      _outfitStyleProfile ??= OutfitStyleProfile.defaultForGender(preference);
      notifyListeners();
    }

    return success;
  }

  Future<bool> saveIdentityPreferences({
    required GenderPreference gender,
    required OutfitStyleProfile styleProfile,
  }) async {
    final success = await _firebaseService.saveUserIdentityPreferences(
      gender: gender.firestoreValue,
      styleProfile: styleProfile.firestoreValue,
    );

    if (success) {
      _genderPreference = gender;
      _outfitStyleProfile = styleProfile;
      notifyListeners();
    }

    return success;
  }

  void setOutfitStyleProfile(OutfitStyleProfile profile) {
    _outfitStyleProfile = profile;
    notifyListeners();
  }

  /// Dùng cho các luồng planner muốn tái sử dụng cùng logic ràng buộc.
  List<ClothingItem> getSuggestionWardrobe() {
    return _getWardrobeForSuggestion();
  }

  String get stylePreferenceAiDescription => _stylePreference.aiDescription;

  String? get genderProfileAiDescription => _genderPreference?.aiDescription;

  String get styleProfileAiDescription =>
      effectiveOutfitStyleProfile.aiDescription;

  Outfit buildPlanningOutfitFromSuggestion(
    Map<String, dynamic> suggestion,
    String occasion,
  ) {
    return _buildOutfitFromSuggestion(suggestion, occasion);
  }

  bool _isRestrictedByStyleProfile(ClothingItem item) {
    final profile = effectiveOutfitStyleProfile;
    if (profile != OutfitStyleProfile.masculine) {
      return false;
    }

    return item.type == ClothingType.dress || item.type == ClothingType.skirt;
  }

  List<ClothingItem> _getWardrobeForSuggestion() {
    if (effectiveOutfitStyleProfile != OutfitStyleProfile.masculine) {
      return _items;
    }

    final filtered = _items
        .where((item) => !_isRestrictedByStyleProfile(item))
        .toList();

    // Fallback to original wardrobe to avoid hard-failing when user has too few items.
    return filtered.isNotEmpty ? filtered : _items;
  }

  /// Suggest outfit
  Future<void> suggestOutfit(String occasion) async {
    try {
      _isSuggestingOutfit = true;
      _errorMessage = null;
      notifyListeners();

      // Get weather context
      final weatherContext =
          _weather?.toAIDescription() ??
          'Temperature: 28°C, Humidity: 70%, Condition: Ấm áp';

      final wardrobeForSuggestion = _getWardrobeForSuggestion();
      if (wardrobeForSuggestion.isEmpty) {
        throw Exception('Tủ đồ trống, chưa thể gợi ý outfit');
      }

      // Call AI
      final suggestion = await _groqService.suggestOutfit(
        wardrobe: wardrobeForSuggestion,
        weatherContext: weatherContext,
        occasion: occasion,
        stylePreference: _stylePreference.aiDescription,
        genderProfile: _genderPreference?.aiDescription,
        styleProfile: effectiveOutfitStyleProfile.aiDescription,
      );

      if (suggestion == null) {
        throw Exception('AI không thể gợi ý outfit');
      }

      // Build outfit from suggestion
      _currentOutfit = _buildOutfitFromSuggestion(suggestion, occasion);

      _isSuggestingOutfit = false;
      notifyListeners();
    } catch (e) {
      _isSuggestingOutfit = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Build Outfit object from AI suggestion
  Outfit _buildOutfitFromSuggestion(
    Map<String, dynamic> suggestion,
    String occasion,
  ) {
    final removedByStyleProfile = <String>[];

    ClothingItem? applyStyleProfileConstraint(ClothingItem? item) {
      if (item == null) return null;
      if (_isRestrictedByStyleProfile(item)) {
        removedByStyleProfile.add(item.type.displayName);
        return null;
      }

      return item;
    }

    ClothingItem? findItem(String? id) {
      if (id == null || id == 'null') return null;
      final found = _items.where((item) => item.id == id);
      if (found.isEmpty) {
        print('⚠️ AI returned invalid item ID: $id');
        return null;
      }
      return found.first;
    }

    final accessoryIds = suggestion['accessories'] as List<dynamic>? ?? [];
    final accessories = accessoryIds
        .map((id) => applyStyleProfileConstraint(findItem(id.toString())))
        .whereType<ClothingItem>()
        .toList();

    final baseReason = suggestion['reason'] ?? 'Gợi ý từ AI';
    final reason = removedByStyleProfile.isEmpty
        ? baseReason
        : '$baseReason (Đã bỏ ${removedByStyleProfile.join(', ')} để phù hợp phong cách hồ sơ đã chọn.)';

    return Outfit(
      id: _uuid.v4(),
      top: applyStyleProfileConstraint(findItem(suggestion['top']?.toString())),
      bottom: applyStyleProfileConstraint(
        findItem(suggestion['bottom']?.toString()),
      ),
      outerwear: applyStyleProfileConstraint(
        findItem(suggestion['outerwear']?.toString()),
      ),
      footwear: applyStyleProfileConstraint(
        findItem(suggestion['footwear']?.toString()),
      ),
      accessories: accessories,
      occasion: occasion,
      reason: reason,
      createdAt: DateTime.now(),
    );
  }

  /// Evaluate color harmony
  Future<ColorHarmonyResult?> evaluateColorHarmony(
    ClothingItem item1,
    ClothingItem item2,
  ) async {
    return await _groqService.evaluateColorHarmony(item1, item2);
  }

  /// Get cleanup suggestions from AI
  Future<Map<String, dynamic>?> getCleanupSuggestions() async {
    if (_items.isEmpty) return null;
    return await _groqService.getCleanupSuggestions(_items);
  }

  /// Delete item by ID
  Future<bool> deleteItem(String itemId) async {
    try {
      final item = _items.firstWhere((i) => i.id == itemId);
      final success = await _firebaseService.deleteClothingItem(item.id);
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
    notifyListeners();
  }

  void clearFilter() {
    _filterCategory = null;
    notifyListeners();
  }
}
