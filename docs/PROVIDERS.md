# Providers - State Management Documentation

> **File 3/8** - Tài liệu chi tiết về State Management với Provider Pattern

## 📁 Vị trí: `lib/providers/`

```
lib/providers/
├── auth_provider.dart      # Quản lý Authentication state
└── wardrobe_provider.dart  # Quản lý Wardrobe & AI features
```

---

## 1. Provider Pattern Overview

### 1.1 Cách hoạt động

```
┌────────────────────────────────────────────────────────────────┐
│                     PROVIDER PATTERN                           │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│   ┌─────────────┐                                              │
│   │   Widget    │ ◄────── Consumer<Provider>                   │
│   │  (UI Layer) │         context.watch<Provider>()            │
│   └──────┬──────┘         context.read<Provider>()             │
│          │                                                     │
│          │ User Action                                         │
│          ▼                                                     │
│   ┌─────────────┐                                              │
│   │  Provider   │ ◄────── extends ChangeNotifier               │
│   │(State Layer)│         notifyListeners()                    │
│   └──────┬──────┘                                              │
│          │                                                     │
│          │ Call Service                                        │
│          ▼                                                     │
│   ┌─────────────┐                                              │
│   │  Service    │ ◄────── Firebase, Gemini, Weather            │
│   │(Data Layer) │                                              │
│   └─────────────┘                                              │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

### 1.2 Setup trong main.dart

```dart
MultiProvider(
  providers: [
    // Services (không reactive)
    Provider<GeminiService>(create: (_) => GeminiService()),
    Provider<WeatherService>(create: (_) => WeatherService()),
    Provider<FirebaseService>(create: (_) => FirebaseService()),
    
    // Providers (reactive - có notifyListeners)
    ChangeNotifierProvider<AuthProvider>(
      create: (context) => AuthProvider(
        context.read<FirebaseService>(),
      ),
    ),
    ChangeNotifierProvider<WardrobeProvider>(
      create: (context) => WardrobeProvider(
        context.read<FirebaseService>(),
        context.read<GeminiService>(),
        context.read<WeatherService>(),
      ),
    ),
  ],
  child: MyApp(),
)
```

---

## 2. AuthProvider (`auth_provider.dart`)

### 2.1 Mục đích

Quản lý toàn bộ authentication state: đăng nhập, đăng xuất, user info.

### 2.2 Enum: AuthStatus

```dart
enum AuthStatus {
  initial,         // Khởi tạo, chưa check auth
  authenticated,   // Đã đăng nhập
  unauthenticated, // Chưa đăng nhập
  loading,         // Đang xử lý
  error,           // Có lỗi
}
```

### 2.3 State Fields

| Field | Type | Mô tả |
|-------|------|-------|
| `_status` | `AuthStatus` | Trạng thái auth hiện tại |
| `_user` | `User?` | Firebase User object |
| `_errorMessage` | `String?` | Thông báo lỗi |

### 2.4 Getters

```dart
AuthStatus get status          // Trạng thái
User? get user                 // Firebase User
String? get errorMessage       // Lỗi (nếu có)
bool get isAuthenticated       // status == authenticated?
bool get isLoading             // status == loading?
String get displayName         // user?.displayName ?? 'Người dùng'
String? get photoUrl           // user?.photoURL
String? get email              // user?.email
String? get userId             // user?.uid
```

### 2.5 Methods

#### `_init()` - Initialize Auth State Listener

```dart
void _init() {
  _firebaseService.authStateChanges.listen((user) {
    _user = user;
    if (user != null) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  });
}
```

**Flow:**
```
App Start → _init() → Listen authStateChanges → Update state → notifyListeners()
```

---

#### `signInWithGoogle()` - Đăng nhập Google

```dart
Future<bool> signInWithGoogle() async
```

**Flow:**
```
┌─────────────────────────────────────────────────────────────┐
│ 1. Set status = loading, notifyListeners()                  │
│ 2. Call _firebaseService.signInWithGoogle()                 │
│ 3. If success:                                              │
│    - _user = result.user                                    │
│    - status = authenticated                                 │
│ 4. If failed:                                               │
│    - status = unauthenticated                               │
│    - _errorMessage = 'Đăng nhập thất bại'                   │
│ 5. notifyListeners(), return true/false                     │
└─────────────────────────────────────────────────────────────┘
```

---

#### `signInWithEmail()` - Đăng nhập Email/Password

```dart
Future<bool> signInWithEmail(String email, String password) async
```

**Error handling với Vietnamese messages:**
```dart
String _getFirebaseErrorMessage(String code) {
  switch (code) {
    case 'email-already-in-use': return 'Email này đã được sử dụng';
    case 'invalid-email':        return 'Email không hợp lệ';
    case 'weak-password':        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
    case 'user-not-found':       return 'Không tìm thấy tài khoản';
    case 'wrong-password':       return 'Sai mật khẩu';
    case 'invalid-credential':   return 'Email hoặc mật khẩu không đúng';
    default:                     return 'Đã xảy ra lỗi: $code';
  }
}
```

---

#### `registerWithEmail()` - Đăng ký tài khoản

```dart
Future<bool> registerWithEmail(String email, String password) async
```

---

#### `signInAnonymously()` - Đăng nhập ẩn danh (Testing)

```dart
Future<bool> signInAnonymously() async
```

---

#### `signOut()` - Đăng xuất

```dart
Future<void> signOut() async {
  // Set state TRƯỚC để UI phản hồi ngay
  _user = null;
  _status = AuthStatus.unauthenticated;
  notifyListeners();
  
  // Sau đó mới gọi Firebase signOut
  await _firebaseService.signOut();
}
```

**Note:** Update state trước khi gọi Firebase để UI phản hồi nhanh hơn.

---

#### `updateDisplayName()` - Cập nhật tên hiển thị

```dart
Future<bool> updateDisplayName(String name) async
```

---

### 2.6 Usage trong Widget

```dart
// Đọc state (rebuild khi thay đổi)
final authProvider = context.watch<AuthProvider>();
if (authProvider.isAuthenticated) {
  // Show home
}

// Gọi method (không rebuild)
context.read<AuthProvider>().signInWithGoogle();

// Dùng Consumer
Consumer<AuthProvider>(
  builder: (context, auth, child) {
    if (auth.isLoading) return LoadingWidget();
    if (auth.isAuthenticated) return HomeScreen();
    return LoginScreen();
  },
)
```

---

## 3. WardrobeProvider (`wardrobe_provider.dart`)

### 3.1 Mục đích

Quản lý:
- Danh sách quần áo (CRUD)
- Thông tin thời tiết
- AI outfit suggestions
- Color harmony evaluation
- Wardrobe cleanup suggestions
- Filter & style preferences

### 3.2 Enums

#### WardrobeStatus

```dart
enum WardrobeStatus {
  initial,   // Khởi tạo
  loading,   // Đang tải
  loaded,    // Đã tải xong
  error,     // Có lỗi
}
```

#### StylePreference

```dart
enum StylePreference {
  loose,    // Đồ rộng thoải mái
  regular,  // Vừa vặn
  fitted;   // Ôm body
}
```

**Có 2 getters:**
- `displayName` → Tên tiếng Việt
- `aiDescription` → Mô tả cho AI hiểu

### 3.3 Dependencies (Injected)

```dart
final FirebaseService _firebaseService;  // Firestore & Auth
final GeminiService _geminiService;      // AI features
final WeatherService _weatherService;    // Weather API
```

### 3.4 State Fields

| Field | Type | Mô tả |
|-------|------|-------|
| `_status` | `WardrobeStatus` | Trạng thái load |
| `_items` | `List<ClothingItem>` | Danh sách quần áo |
| `_weather` | `WeatherInfo?` | Thời tiết hiện tại |
| `_errorMessage` | `String?` | Thông báo lỗi |
| `_isAnalyzing` | `bool` | Đang phân tích ảnh? |
| `_isSuggestingOutfit` | `bool` | Đang gợi ý outfit? |
| `_stylePreference` | `StylePreference` | Preference người dùng |
| `_currentOutfit` | `Outfit?` | Outfit đang được gợi ý |
| `_filterType` | `ClothingType?` | Filter theo type |
| `_filterCategory` | `String?` | Filter theo category |

### 3.5 Getters

```dart
// Status
WardrobeStatus get status
bool get isLoading
bool get isAnalyzing
bool get isSuggestingOutfit
String? get errorMessage

// Data
List<ClothingItem> get items        // Filtered items
List<ClothingItem> get allItems     // All items
WeatherInfo? get weather
Outfit? get currentOutfit
StylePreference get stylePreference

// Filter
ClothingType? get filterType
String? get filterCategory

// Grouped data
Map<ClothingType, List<ClothingItem>> get itemsByType
```

### 3.6 Methods - Data Loading

#### `loadItems()` - Tải danh sách quần áo

```dart
Future<void> loadItems() async {
  _status = WardrobeStatus.loading;
  notifyListeners();
  
  _items = await _firebaseService.getUserItems();
  _status = WardrobeStatus.loaded;
  notifyListeners();
}
```

#### `loadWeather()` - Tải thời tiết

```dart
Future<void> loadWeather({String? city}) async
```

#### `changeWeatherLocation()` - Đổi thành phố

```dart
Future<void> changeWeatherLocation(String city) async {
  _weatherService.clearCache();
  await loadWeather(city: city);
}
```

---

### 3.7 Methods - CRUD Operations

#### `addItemFromBytes()` - Thêm item (Web)

```dart
Future<ClothingItem?> addItemFromBytes(
  Uint8List imageBytes, {
  required ClothingType type,
  required String color,
  required List<ClothingStyle> styles,
  required List<Season> seasons,
  String? material,
}) async
```

**Flow:**
```
┌─────────────────────────────────────────────────────────────┐
│ 1. _isAnalyzing = true, notifyListeners()                   │
│ 2. Convert imageBytes to Base64                             │
│ 3. Create ClothingItem object                               │
│ 4. Save to Firestore via _firebaseService.addClothingItem() │
│ 5. Add savedItem to _items list                             │
│ 6. _isAnalyzing = false, notifyListeners()                  │
│ 7. Return savedItem                                         │
└─────────────────────────────────────────────────────────────┘
```

#### `addItemFromFile()` - Thêm item (Mobile)

```dart
Future<ClothingItem?> addItemFromFile(File imageFile, {...}) async
```

**Note:** Dùng Firebase Storage thay vì Base64.

#### `updateItem()` - Cập nhật item

```dart
Future<bool> updateItem(ClothingItem item) async
```

#### `deleteItem()` - Xóa item

```dart
Future<bool> deleteItem(String itemId) async
```

#### `deleteAllItems()` - Xóa tất cả

```dart
Future<bool> deleteAllItems() async
```

---

### 3.8 Methods - Item Actions

#### `toggleFavorite()` - Đánh dấu yêu thích

```dart
Future<void> toggleFavorite(ClothingItem item) async
```

#### `markAsWorn()` - Đánh dấu đã mặc

```dart
Future<void> markAsWorn(ClothingItem item) async {
  final success = await _firebaseService.markAsWorn(item.id);
  if (success) {
    _items[index] = item.copyWith(
      lastWorn: DateTime.now(),
      wearCount: item.wearCount + 1,
    );
    notifyListeners();
  }
}
```

---

### 3.9 Methods - AI Features

#### `suggestOutfit()` - Gợi ý outfit từ AI

```dart
Future<Outfit?> suggestOutfit(String occasion) async
```

**Flow:**
```
┌─────────────────────────────────────────────────────────────┐
│ 1. _isSuggestingOutfit = true                               │
│ 2. Get weather context: _weather?.toAIDescription()         │
│ 3. Call _geminiService.suggestOutfit()                      │
│    - wardrobe: _items                                       │
│    - weatherContext: weather description                    │
│    - occasion: user input                                   │
│    - stylePreference: _stylePreference.aiDescription        │
│ 4. _buildOutfitFromSuggestion() - Map AI response to Outfit │
│ 5. _currentOutfit = outfit                                  │
│ 6. _isSuggestingOutfit = false, notifyListeners()           │
└─────────────────────────────────────────────────────────────┘
```

#### `_buildOutfitFromSuggestion()` - Helper

```dart
Outfit _buildOutfitFromSuggestion(
  Map<String, dynamic> suggestion,
  String occasion,
)
```

Parse AI response và map item IDs thành ClothingItem objects.

#### `evaluateColorHarmony()` - Đánh giá phối màu

```dart
Future<ColorHarmonyResult?> evaluateColorHarmony(
  ClothingItem item1,
  ClothingItem item2,
) async
```

#### `getCleanupSuggestions()` - Gợi ý dọn tủ

```dart
Future<Map<String, dynamic>?> getCleanupSuggestions() async
```

---

### 3.10 Methods - Filter & Preferences

#### `setFilterCategory()` - Set filter

```dart
void setFilterCategory(String? category) {
  _filterCategory = category;
  _filterType = null;
  notifyListeners();
}
```

#### `clearFilter()` - Xóa filter

```dart
void clearFilter() {
  _filterType = null;
  _filterCategory = null;
  notifyListeners();
}
```

#### `setStylePreference()` - Set style preference

```dart
void setStylePreference(StylePreference preference) {
  _stylePreference = preference;
  notifyListeners();
}
```

---

### 3.11 Filtered Items Logic

```dart
List<ClothingItem> get _filteredItems {
  if (_filterType != null) {
    return _items.where((item) => item.type == _filterType).toList();
  }
  if (_filterCategory != null) {
    return _items.where((item) => item.type.category == _filterCategory).toList();
  }
  return _items;  // No filter
}
```

---

## 4. Provider Interaction Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PROVIDER INTERACTIONS                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌──────────────┐         ┌─────────────────┐                      │
│   │ AuthProvider │◄───────►│ FirebaseService │                      │
│   │              │         │ (Auth methods)  │                      │
│   └──────┬───────┘         └────────┬────────┘                      │
│          │                          │                               │
│          │ userId                   │ authStateChanges              │
│          │                          │                               │
│          ▼                          ▼                               │
│   ┌────────────────────────────────────────────────┐                │
│   │              WardrobeProvider                   │                │
│   │                                                 │                │
│   │  ┌─────────────────┐  ┌─────────────────┐      │                │
│   │  │ FirebaseService │  │  GeminiService  │      │                │
│   │  │ (Firestore CRUD)│  │  (AI features)  │      │                │
│   │  └─────────────────┘  └─────────────────┘      │                │
│   │                                                 │                │
│   │  ┌─────────────────┐                           │                │
│   │  │ WeatherService  │                           │                │
│   │  │ (Weather API)   │                           │                │
│   │  └─────────────────┘                           │                │
│   └────────────────────────────────────────────────┘                │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 5. Best Practices

### 5.1 Khi nào dùng watch vs read?

```dart
// ✅ watch - Khi cần rebuild UI khi state thay đổi
final items = context.watch<WardrobeProvider>().items;

// ✅ read - Khi chỉ gọi method, không cần rebuild
onPressed: () => context.read<WardrobeProvider>().loadItems()

// ❌ KHÔNG dùng watch trong event handlers
onPressed: () => context.watch<WardrobeProvider>().loadItems() // SAI!
```

### 5.2 notifyListeners() Pattern

```dart
// ✅ Gọi notifyListeners() sau khi update state
_status = WardrobeStatus.loading;
notifyListeners();  // UI update ngay

// ✅ Gọi 1 lần sau nhiều thay đổi
_status = WardrobeStatus.loaded;
_items = newItems;
_errorMessage = null;
notifyListeners();  // Gọi 1 lần cuối

// ❌ KHÔNG gọi quá nhiều lần
_status = WardrobeStatus.loading;
notifyListeners();  // Lần 1
_items = [];
notifyListeners();  // Lần 2 - Thừa!
```

### 5.3 Error Handling Pattern

```dart
try {
  _status = WardrobeStatus.loading;
  _errorMessage = null;  // Clear error cũ
  notifyListeners();
  
  // ... thực hiện operation
  
  _status = WardrobeStatus.loaded;
  notifyListeners();
} catch (e) {
  _status = WardrobeStatus.error;
  _errorMessage = e.toString();
  notifyListeners();
}
```

---

## 📝 Summary

| Provider | Quản lý | Services sử dụng |
|----------|---------|------------------|
| `AuthProvider` | User auth state | FirebaseService |
| `WardrobeProvider` | Items, Weather, AI | FirebaseService, GeminiService, WeatherService |

---

**Tiếp theo:** [SERVICES.md](./SERVICES.md) - Firebase, Gemini AI, Weather Services
