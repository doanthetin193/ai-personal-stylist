# Services - Backend Services Documentation

> **File 4/8** - Tài liệu chi tiết về các Backend Services

## 📁 Vị trí: `lib/services/`

```
lib/services/
├── firebase_service.dart   # Firebase Auth, Firestore, Storage
├── gemini_service.dart     # Google Gemini AI
└── weather_service.dart    # Open-Meteo Weather API
```

---

## 1. FirebaseService (`firebase_service.dart`)

### 1.1 Mục đích

Quản lý tất cả tương tác với Firebase:
- **Authentication**: Google Sign-in, Email/Password, Anonymous
- **Firestore**: CRUD operations cho clothing items
- **Storage**: Upload/Delete images (legacy, hiện dùng Base64)

### 1.2 Dependencies

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
```

### 1.3 Instances

```dart
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseStorage _storage = FirebaseStorage.instance;
```

---

### 1.4 Authentication Methods

#### `ensurePersistence()` - Setup Session Persistence

```dart
Future<void> ensurePersistence() async
```

**Mục đích:** Giữ phiên đăng nhập qua reload/restart.

```
┌─────────────────────────────────────────────────┐
│ Platform │ Persistence Method                   │
├─────────────────────────────────────────────────┤
│ Web      │ Persistence.LOCAL (localStorage)     │
│ Mobile   │ Tự động (secure storage)             │
└─────────────────────────────────────────────────┘
```

---

#### `signInWithGoogle()` - Đăng nhập Google

```dart
Future<UserCredential?> signInWithGoogle() async
```

**Flow:**
```
1. Tạo GoogleAuthProvider
2. Set 'prompt': 'select_account' (force chọn account)
3. signInWithPopup (Web)
4. Return UserCredential hoặc null
```

---

#### `signInWithEmail()` - Đăng nhập Email/Password

```dart
Future<UserCredential?> signInWithEmail(String email, String password) async
```

**Note:** Rethrow exception để AuthProvider handle error messages.

---

#### `registerWithEmail()` - Đăng ký Email/Password

```dart
Future<UserCredential?> registerWithEmail(String email, String password) async
```

---

#### `signInAnonymously()` - Đăng nhập ẩn danh

```dart
Future<UserCredential?> signInAnonymously() async
```

**Use case:** Testing, demo mode.

---

#### `signOut()` - Đăng xuất

```dart
Future<void> signOut() async {
  await _auth.signOut();
}
```

---

#### Getters

```dart
User? get currentUser => _auth.currentUser;
Stream<User?> get authStateChanges => _auth.authStateChanges();
bool get isLoggedIn => currentUser != null;
```

---

### 1.5 Firestore Methods

#### Collection Reference

```dart
CollectionReference<Map<String, dynamic>> get _itemsRef =>
    _firestore.collection(AppConstants.itemsCollection);
// Collection: 'items'
```

---

#### `addClothingItem()` - Thêm item mới

```dart
Future<String?> addClothingItem(ClothingItem item) async
```

**Flow:**
```
1. Convert item to JSON: item.toJson()
2. Add to Firestore với timeout 30s
3. Return document ID hoặc null
```

---

#### `updateClothingItem()` - Cập nhật item

```dart
Future<bool> updateClothingItem(ClothingItem item) async {
  await _itemsRef.doc(item.id).update(item.toJson());
  return true;
}
```

---

#### `deleteClothingItem()` - Xóa item

```dart
Future<bool> deleteClothingItem(String itemId, String? imageUrl) async
```

**Flow:**
```
1. Nếu có imageUrl (legacy) → xóa từ Storage
2. Xóa document từ Firestore (Base64 tự động xóa)
```

---

#### `getUserItems()` - Lấy tất cả items của user

```dart
Future<List<ClothingItem>> getUserItems() async
```

**Query:**
```dart
_itemsRef
  .where('userId', isEqualTo: userId)
  .orderBy('createdAt', descending: true)  // Mới nhất trước
  .get();
```

---

#### `markAsWorn()` - Đánh dấu đã mặc

```dart
Future<bool> markAsWorn(String itemId) async {
  await _itemsRef.doc(itemId).update({
    'lastWorn': Timestamp.now(),
    'wearCount': FieldValue.increment(1),  // Atomic increment
  });
  return true;
}
```

---

#### `toggleFavorite()` - Toggle yêu thích

```dart
Future<bool> toggleFavorite(String itemId, bool isFavorite) async {
  await _itemsRef.doc(itemId).update({'isFavorite': isFavorite});
  return true;
}
```

---

### 1.6 Storage Methods

#### `uploadClothingImage()` - Upload ảnh (Mobile)

```dart
Future<String?> uploadClothingImage(File imageFile) async
```

**Path:** `clothing_images/{userId}/{uuid}.jpg`

**Note:** Legacy method, hiện tại Web dùng Base64.

---

#### `deleteImage()` - Xóa ảnh từ Storage

```dart
Future<bool> deleteImage(String imageUrl) async {
  final ref = _storage.refFromURL(imageUrl);
  await ref.delete();
  return true;
}
```

---

### 1.7 Base64 Utils

```dart
/// Convert bytes to Base64 (thay thế Firebase Storage cho Web)
String convertToBase64(Uint8List bytes) {
  return base64Encode(bytes);
}
```

**Tại sao dùng Base64?**
- Web không hỗ trợ Firebase Storage upload trực tiếp
- Base64 lưu thẳng vào Firestore document
- Đơn giản hóa flow, không cần CORS config

---

## 2. GeminiService (`gemini_service.dart`)

### 2.1 Mục đích

Tích hợp Google Gemini AI cho các tính năng:
- Phân tích ảnh quần áo
- Gợi ý outfit
- Đánh giá color harmony
- Gợi ý dọn tủ đồ

### 2.2 Model Configuration

```dart
late final GenerativeModel _model;        // Text generation
late final GenerativeModel _visionModel;  // Image + Text

// Model: gemini-2.0-flash
// Temperature: 0.7 (general), 0.3 (vision - for consistent JSON)
// Max tokens: 1024
```

### 2.3 `initialize()` - Khởi tạo với API Key

```dart
void initialize(String apiKey)
```

**Flow:**
```
1. Check API key validity
2. Create _model (text) với temperature 0.7
3. Create _visionModel với temperature 0.3 (lower = more consistent)
4. Set _isInitialized = true
```

**Được gọi từ:** `main.dart` sau khi Firebase init.

---

### 2.4 `analyzeClothingImageBytes()` - Phân tích ảnh

```dart
Future<Map<String, dynamic>?> analyzeClothingImageBytes(Uint8List imageBytes) async
```

**Input:** Image bytes từ file picker

**Output JSON:**
```json
{
  "type": "shirt|tshirt|pants|...",
  "color": "màu tiếng Việt",
  "material": "cotton|denim|...",
  "styles": ["casual", "formal", ...],
  "seasons": ["spring", "summer", ...]
}
```

**Flow:**
```
┌─────────────────────────────────────────────────────────────┐
│ 1. Check _isInitialized                                     │
│ 2. Create prompt (TextPart) + image (DataPart)              │
│ 3. Call _visionModel.generateContent()                      │
│ 4. Parse JSON response với safeParseJson()                  │
│ 5. Return Map<String, dynamic>                              │
└─────────────────────────────────────────────────────────────┘
```

**Prompt highlights:**
- Phân biệt tshirt vs shirt (cổ áo, nút)
- Màu sắc tiếng Việt, hỗ trợ nhiều màu/họa tiết
- Output: JSON only, không markdown

---

### 2.5 `suggestOutfit()` - Gợi ý outfit

```dart
Future<Map<String, dynamic>?> suggestOutfit({
  required List<ClothingItem> wardrobe,
  required String weatherContext,
  required String occasion,
  String? stylePreference,
}) async
```

**Input:**
- `wardrobe`: List tất cả items (converted to AI description)
- `weatherContext`: Từ WeatherInfo.toAIDescription()
- `occasion`: "Đi làm", "Hẹn hò", etc.
- `stylePreference`: "loose", "regular", "fitted"

**Output JSON:**
```json
{
  "top": "item_id or null",
  "bottom": "item_id or null",
  "outerwear": "item_id or null",
  "footwear": "item_id or null",
  "accessories": ["item_id", ...],
  "reason": "Lý do gợi ý bằng tiếng Việt"
}
```

**AI Selection Criteria:**
1. Match weather conditions
2. Appropriate for occasion
3. Harmonious colors
4. Cohesive style
5. Respect user's style preference

---

### 2.6 `evaluateColorHarmony()` - Đánh giá phối màu

```dart
Future<ColorHarmonyResult?> evaluateColorHarmony(
  ClothingItem item1,
  ClothingItem item2,
) async
```

**Output JSON:**
```json
{
  "score": 85,           // 0-100
  "reason": "Lý do...",
  "vibe": "Classic & Elegant",
  "tips": ["Tip 1", "Tip 2"]
}
```

**Scoring Guide:**
```
┌──────────────────────────────────────────┐
│ Score    │ Meaning                       │
├──────────────────────────────────────────┤
│ 90-100   │ Perfect harmony, trending     │
│ 70-89    │ Good match                    │
│ 50-69    │ Acceptable                    │
│ 30-49    │ Clashing, not recommended     │
│ 0-29     │ Very poor combination         │
└──────────────────────────────────────────┘
```

---

### 2.7 `getCleanupSuggestions()` - Gợi ý dọn tủ

```dart
Future<Map<String, dynamic>?> getCleanupSuggestions(
  List<ClothingItem> wardrobe,
) async
```

**Output JSON:**
```json
{
  "duplicates": [
    {"ids": ["id1", "id2"], "reason": "Lý do trùng lặp"}
  ],
  "mismatched": [
    {"id": "item_id", "reason": "Lý do không phù hợp"}
  ],
  "suggestions": ["Gợi ý chung 1", "Gợi ý 2"]
}
```

**AI Identifies:**
1. Duplicate items (same type + similar color)
2. Mismatched items (không hợp style tủ đồ)
3. Seasonal items không cần thiết

---

## 3. WeatherService (`weather_service.dart`)

### 3.1 Mục đích

Lấy thông tin thời tiết từ OpenWeatherMap API.

### 3.2 Configuration

```dart
// Base URL
static const String weatherBaseUrl = 'https://api.openweathermap.org/data/2.5';

// Default location
static const String defaultCity = 'Quy Nhon';
static const String defaultCountryCode = 'VN';

// Cache duration
static const Duration weatherCacheDuration = Duration(minutes: 30);
```

### 3.3 Caching Mechanism

```dart
WeatherInfo? _cachedWeather;
DateTime? _lastFetchTime;
```

**Logic:**
```dart
if (_cachedWeather != null && _lastFetchTime != null) {
  final diff = DateTime.now().difference(_lastFetchTime!);
  if (diff < AppConstants.weatherCacheDuration) {
    return _cachedWeather;  // Return cached data
  }
}
// Else: fetch new data
```

**Tại sao cache 30 phút?**
- Giảm API calls
- Thời tiết không đổi nhanh
- Free tier API có giới hạn

---

### 3.4 `getCurrentWeather()` - Lấy thời tiết hiện tại

```dart
Future<WeatherInfo?> getCurrentWeather({
  String city = AppConstants.defaultCity,
  String countryCode = AppConstants.defaultCountryCode,
}) async
```

**API Call:**
```
GET https://api.openweathermap.org/data/2.5/weather
    ?q={city},{countryCode}
    &appid={API_KEY}
    &units=metric
```

**Flow:**
```
┌─────────────────────────────────────────────────────────────┐
│ 1. Check cache (valid < 30 mins) → return cached            │
│ 2. Check API key validity                                   │
│ 3. Call OpenWeatherMap API                                  │
│ 4. Parse response → WeatherInfo.fromJson()                  │
│ 5. Update cache: _cachedWeather, _lastFetchTime             │
│ 6. Return WeatherInfo                                       │
│                                                             │
│ On Error: Return _getDefaultWeather()                       │
└─────────────────────────────────────────────────────────────┘
```

---

### 3.5 `_getDefaultWeather()` - Fallback Weather

```dart
WeatherInfo _getDefaultWeather() {
  return WeatherInfo(
    temperature: 28,
    feelsLike: 30,
    humidity: 70,
    windSpeed: 3,
    description: 'Partly cloudy',
    icon: '02d',
    cityName: AppConstants.defaultCity,
    timestamp: DateTime.now(),
  );
}
```

**Use cases:**
- API key không hợp lệ
- Network error
- API response error

---

### 3.6 `clearCache()` - Xóa cache

```dart
void clearCache() {
  _cachedWeather = null;
  _lastFetchTime = null;
}
```

**Gọi khi:** User đổi thành phố.

---

## 4. AI Prompts (`utils/constants.dart`)

### 4.1 AIPrompts Class

Chứa tất cả prompts cho Gemini AI.

#### `analyzeClothing` - Phân tích ảnh

Key points:
- Phân biệt tshirt vs shirt (cổ áo, nút)
- Màu sắc tiếng Việt, hỗ trợ nhiều màu
- Output: JSON only

#### `suggestOutfit()` - Gợi ý outfit

Parameters:
- `wardrobeContext`: Items descriptions
- `weatherContext`: Weather info
- `occasion`: Event type
- `stylePreference`: User's fit preference

#### `colorHarmony()` - Đánh giá phối màu

Parameters:
- `item1Desc`, `item2Desc`: Item AI descriptions

#### `cleanupSuggestion()` - Gợi ý dọn tủ

Parameter:
- `wardrobeContext`: All items descriptions

---

## 5. Service Interaction Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                      SERVICE INTERACTIONS                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌───────────────────────────────────────────────────────────┐    │
│   │                     PROVIDERS                              │    │
│   │  AuthProvider          WardrobeProvider                    │    │
│   └─────────┬─────────────────────┬───────────────────────────┘    │
│             │                     │                                 │
│             ▼                     ▼                                 │
│   ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐  │
│   │ FirebaseService │   │  GeminiService  │   │ WeatherService  │  │
│   │                 │   │                 │   │                 │  │
│   │ • Auth          │   │ • analyzeImage  │   │ • getWeather    │  │
│   │ • Firestore     │   │ • suggestOutfit │   │ • cache         │  │
│   │ • Storage       │   │ • colorHarmony  │   │                 │  │
│   └────────┬────────┘   └────────┬────────┘   └────────┬────────┘  │
│            │                     │                     │            │
│            ▼                     ▼                     ▼            │
│   ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐  │
│   │    Firebase     │   │  Gemini 2.0     │   │ OpenWeatherMap  │  │
│   │   Cloud/Auth    │   │   Flash API     │   │      API        │  │
│   └─────────────────┘   └─────────────────┘   └─────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 6. Error Handling Patterns

### 6.1 FirebaseService

```dart
try {
  // Firebase operation
} catch (e) {
  print('Operation Error: $e');
  return null; // hoặc false
}
```

### 6.2 GeminiService

```dart
try {
  final response = await _model.generateContent([...])
    .timeout(AppConstants.aiTimeout);  // 30s timeout
  
  if (text == null || text.isEmpty) {
    print('Empty response from Gemini');
    return null;
  }
  
  return safeParseJson(text);  // Helper function
} catch (e) {
  print('AI Error: $e');
  return null;
}
```

### 6.3 WeatherService

```dart
try {
  final response = await http.get(url)
    .timeout(Duration(seconds: 10));
  
  if (response.statusCode == 200) {
    return WeatherInfo.fromJson(jsonDecode(response.body));
  }
  return _getDefaultWeather();  // Fallback
} catch (e) {
  return _getDefaultWeather();  // Fallback
}
```

---

## 📝 Summary

| Service | External API | Key Features |
|---------|--------------|--------------|
| `FirebaseService` | Firebase | Auth, Firestore CRUD, Storage |
| `GeminiService` | Gemini 2.0 Flash | Image analysis, Outfit suggestion, Color harmony |
| `WeatherService` | OpenWeatherMap | Weather data, 30-min cache |

---

**Tiếp theo:** [SCREENS.md](./SCREENS.md) - Các màn hình trong app
