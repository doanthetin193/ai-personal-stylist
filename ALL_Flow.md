# 🗺️ TẤT CẢ CÁC LUỒNG ĐI TRONG APP

> **Mục đích:** Liệt kê chi tiết TOÀN BỘ luồng để dễ trace code và debug

---

## 📋 MỤC LỤC

### A. AUTHENTICATION FLOWS (4 luồng)

1. [Khởi động App & Auto Login](#1-khởi-động-app--auto-login)
2. [Đăng nhập Google](#2-đăng-nhập-google)
3. [Đăng nhập Email/Password](#3-đăng-nhập-emailpassword)
4. [Đăng xuất](#4-đăng-xuất)

### B. WARDROBE MANAGEMENT FLOWS (8 luồng)

5. [Load Tủ Đồ (Ban đầu)](#5-load-tủ-đồ-ban-đầu)
6. [Thêm Item - Web (từ bytes)](#6-thêm-item---web-từ-bytes)
7. [Thêm Item - Mobile (từ file)](#7-thêm-item---mobile-từ-file)
8. [Xem Chi Tiết Item](#8-xem-chi-tiết-item)
9. [Cập Nhật Item](#9-cập-nhật-item)
10. [Xóa Item](#10-xóa-item)
11. [Toggle Favorite](#11-toggle-favorite)
12. [Filter Items (Theo Type/Category)](#12-filter-items-theo-typecategory)

### C. AI FEATURES FLOWS (5 luồng)

13. [AI Phân Tích Ảnh Quần Áo](#13-ai-phân-tích-ảnh-quần-áo)
14. [Gợi Ý Outfit](#14-gợi-ý-outfit)
15. [Chấm Điểm Color Harmony](#15-chấm-điểm-color-harmony)
16. [Dọn Tủ Đồ (Cleanup Suggestions)](#16-dọn-tủ-đồ-cleanup-suggestions)
17. [Load Weather Data](#17-load-weather-data)

### D. NAVIGATION FLOWS (3 luồng)

18. [Navigate giữa Tabs (Bottom Nav)](#18-navigate-giữa-tabs-bottom-nav)
19. [Navigate tới Add Item](#19-navigate-tới-add-item)
20. [Navigate tới Item Detail](#20-navigate-tới-item-detail)

### E. PROFILE & SETTINGS FLOWS (3 luồng)

21. [Load Profile Info](#21-load-profile-info)
22. [Change Style Preference](#22-change-style-preference)
23. [Change Weather Location](#23-change-weather-location)

---

## A. AUTHENTICATION FLOWS

### 1. Khởi động App & Auto Login

**Trigger:** User mở app

**Flow:**

```
main.dart
  ├─→ Firebase.initializeApp()
  ├─→ FirebaseService.ensurePersistence()
  │   └─→ Persistence.LOCAL (Web) hoặc auto (Mobile)
  │
  ├─→ runApp(MyApp)
  │   └─→ MultiProvider setup
  │       ├─→ AuthProvider
  │       └─→ WardrobeProvider
  │
  └─→ MaterialApp
      └─→ home: AuthWrapper
          │
          ├─→ Check: authProvider.isLoggedIn?
          │   │
          │   ├─→ YES: HomeScreen (auto login thành công)
          │   └─→ NO: LoginScreen
```

**Files:**

- `lib/main.dart` (entry point)
- `lib/services/firebase_service.dart` → `ensurePersistence()`
- `lib/providers/auth_provider.dart` → `isLoggedIn` getter
- `lib/screens/login_screen.dart`
- `lib/screens/home_screen.dart`

**Key Methods:**

```dart
// main.dart
await firebaseService.ensurePersistence()

// auth_provider.dart
bool get isLoggedIn => _user != null
Stream<User?> get authStateChanges => _firebaseService.authStateChanges
```

---

### 2. Đăng nhập Google

**Trigger:** User click "Đăng nhập bằng Google"

**Flow:**

```
LoginScreen
  │
  ├─→ User click Google button
  │
  └─→ authProvider.signInWithGoogle()
      │
      └─→ FirebaseService.signInWithGoogle()
          │
          ├─→ GoogleAuthProvider() với prompt: 'select_account'
          ├─→ signInWithPopup(provider)
          │
          └─→ UserCredential?
              │
              ├─→ SUCCESS:
              │   ├─→ AuthProvider._user = credential.user
              │   ├─→ notifyListeners()
              │   ├─→ Navigator → HomeScreen
              │   └─→ Show SnackBar "Đăng nhập thành công"
              │
              └─→ ERROR:
                  └─→ Show SnackBar với error message
```

**Files:**

- `lib/screens/login_screen.dart` → Button onPressed
- `lib/providers/auth_provider.dart` → `signInWithGoogle()`
- `lib/services/firebase_service.dart` → `signInWithGoogle()`

**Key Methods:**

```dart
// login_screen.dart (line ~180)
onPressed: () async {
  final success = await authProvider.signInWithGoogle();
  if (success) Navigator.pushReplacement...
}

// auth_provider.dart (line ~40)
Future<bool> signInWithGoogle() async

// firebase_service.dart (line ~70)
Future<UserCredential?> signInWithGoogle() async
```

---

### 3. Đăng nhập Email/Password

**Trigger:** User nhập email/password và click "Đăng nhập"

**Flow:**

```
LoginScreen
  │
  ├─→ User nhập email, password
  ├─→ Click "Đăng nhập" button
  │
  └─→ authProvider.signInWithEmail(email, password)
      │
      └─→ FirebaseService.signInWithEmail(email, password)
          │
          ├─→ _auth.signInWithEmailAndPassword(email, password)
          │
          └─→ UserCredential?
              │
              ├─→ SUCCESS:
              │   ├─→ AuthProvider._user = credential.user
              │   ├─→ notifyListeners()
              │   └─→ Navigator → HomeScreen
              │
              └─→ ERROR (catch):
                  ├─→ Parse error code
                  │   ├─→ 'user-not-found' → "Email chưa đăng ký"
                  │   ├─→ 'wrong-password' → "Mật khẩu sai"
                  │   └─→ other → "Đăng nhập thất bại"
                  └─→ Show SnackBar
```

**Files:**

- `lib/screens/login_screen.dart` → Email/Password form
- `lib/providers/auth_provider.dart` → `signInWithEmail()`
- `lib/services/firebase_service.dart` → `signInWithEmail()`

**Key Methods:**

```dart
// auth_provider.dart
Future<bool> signInWithEmail(String email, String password) async

// firebase_service.dart
Future<UserCredential?> signInWithEmail(String email, String password) async
```

---

### 4. Đăng xuất

**Trigger:** User click "Đăng xuất" trong ProfileScreen

**Flow:**

```
ProfileScreen
  │
  ├─→ User click "Đăng xuất" button
  │
  └─→ authProvider.signOut()
      │
      ├─→ FirebaseService.signOut()
      │   └─→ _auth.signOut()
      │
      ├─→ AuthProvider._user = null
      ├─→ notifyListeners()
      │
      └─→ Navigator.pushAndRemoveUntil → LoginScreen
```

**Files:**

- `lib/screens/profile_screen.dart` → Logout button
- `lib/providers/auth_provider.dart` → `signOut()`
- `lib/services/firebase_service.dart` → `signOut()`

**Key Methods:**

```dart
// profile_screen.dart (line ~200+)
onPressed: () async {
  await authProvider.signOut();
  Navigator.pushAndRemoveUntil(context, LoginScreen...);
}

// auth_provider.dart
Future<void> signOut() async

// firebase_service.dart
Future<void> signOut() async
```

---

## B. WARDROBE MANAGEMENT FLOWS

### 5. Load Tủ Đồ (Ban đầu)

**Trigger:** User vào WardrobeScreen lần đầu

**Flow:**

```
WardrobeScreen (initState)
  │
  └─→ wardrobeProvider.loadItems()
      │
      ├─→ _status = WardrobeStatus.loading
      ├─→ notifyListeners() → Show Shimmer loading
      │
      └─→ FirebaseService.getUserItems()
          │
          ├─→ Query Firestore:
          │   collection('items')
          │     .where('userId', isEqualTo: currentUser.uid)
          │     .orderBy('createdAt', descending: true)
          │     .get()
          │
          └─→ List<DocumentSnapshot>
              │
              ├─→ Map to List<ClothingItem>
              │   └─→ ClothingItem.fromJson(doc.data(), doc.id)
              │
              ├─→ WardrobeProvider._items = items
              ├─→ _status = WardrobeStatus.loaded
              └─→ notifyListeners() → UI rebuild với data
```

**Files:**

- `lib/screens/wardrobe_screen.dart` → initState
- `lib/providers/wardrobe_provider.dart` → `loadItems()`
- `lib/services/firebase_service.dart` → `getUserItems()`
- `lib/models/clothing_item.dart` → `fromJson()`

**Key Methods:**

```dart
// wardrobe_screen.dart (line ~60)
@override
void initState() {
  Future.microtask(() => wardrobeProvider.loadItems());
}

// wardrobe_provider.dart (line ~115)
Future<void> loadItems() async

// firebase_service.dart (line ~190)
Future<List<ClothingItem>> getUserItems() async
```

---

### 6. Thêm Item - Web (từ bytes)

**Trigger:** User chọn ảnh trên Web platform

**Flow:**

```
AddItemScreen (Web)
  │
  ├─→ User click chọn ảnh
  │   └─→ ImagePicker.pickImage(source: ImageSource.gallery)
  │       └─→ XFile? pickedFile
  │
  ├─→ await pickedFile.readAsBytes() → Uint8List imageBytes
  │
  ├─→ User điền/chỉnh sửa thông tin:
  │   ├─→ type (required)
  │   ├─→ color (required)
  │   ├─→ styles (required)
  │   ├─→ seasons (required)
  │   └─→ material (optional)
  │
  ├─→ Click "Lưu vào tủ đồ"
  │
  └─→ wardrobeProvider.addItemFromBytes(imageBytes, ...)
      │
      ├─→ _isAnalyzing = true
      ├─→ notifyListeners() → Show loading
      │
      ├─→ [STEP 1] Nén ảnh:
      │   FirebaseService.compressAndConvertToBase64(imageBytes)
      │   │
      │   ├─→ FlutterImageCompress.compressWithList(
      │   │     bytes, minWidth: 800, minHeight: 800, quality: 85
      │   │   )
      │   │
      │   ├─→ Log: "📦 Image compressed: 2500KB → 180KB (92.8%)"
      │   └─→ base64Encode(compressed) → String imageBase64
      │
      ├─→ [STEP 2] AI phân tích (nếu chọn AI):
      │   GeminiService.analyzeClothingImageBytes(imageBytes)
      │   │
      │   ├─→ Upload ảnh to Gemini
      │   ├─→ Send prompt với format yêu cầu
      │   ├─→ Receive JSON response
      │   └─→ Parse JSON → AIAnalysisResult
      │
      ├─→ [STEP 3] Tạo ClothingItem:
      │   ClothingItem(
      │     id: '',
      │     userId: currentUser.uid,
      │     imageBase64: imageBase64,
      │     type: type,
      │     color: color,
      │     styles: styles,
      │     seasons: seasons,
      │     material: material,
      │     createdAt: DateTime.now(),
      │   )
      │
      ├─→ [STEP 4] Lưu Firestore:
      │   FirebaseService.addClothingItem(item)
      │   │
      │   ├─→ collection('items').add(item.toJson())
      │   ├─→ Log: "✅ Document added with ID: abc123"
      │   └─→ Return docId
      │
      ├─→ [STEP 5] Update local state:
      │   ├─→ savedItem = item.copyWith(id: docId)
      │   ├─→ _items.insert(0, savedItem)
      │   ├─→ _isAnalyzing = false
      │   └─→ notifyListeners() → UI update
      │
      └─→ Navigator.pop() → Back to WardrobeScreen
```

**Files:**

- `lib/screens/add_item_screen.dart` → UI và button handler
- `lib/providers/wardrobe_provider.dart` → `addItemFromBytes()`
- `lib/services/firebase_service.dart` → `compressAndConvertToBase64()`, `addClothingItem()`
- `lib/services/gemini_service.dart` → `analyzeClothingImageBytes()`
- `lib/models/clothing_item.dart` → Constructor, `toJson()`

**Key Methods:**

```dart
// add_item_screen.dart (line ~700)
final bytes = await pickedFile!.readAsBytes();
item = await wardrobeProvider.addItemFromBytes(bytes, ...)

// wardrobe_provider.dart (line ~150)
Future<ClothingItem?> addItemFromBytes(Uint8List imageBytes, ...) async

// firebase_service.dart (line ~35)
Future<String> compressAndConvertToBase64(Uint8List bytes) async

// firebase_service.dart (line ~155)
Future<String?> addClothingItem(ClothingItem item) async

// gemini_service.dart (line ~160)
Future<String> analyzeClothingImageBytes(Uint8List imageBytes) async
```

---

### 7. Thêm Item - Mobile (từ file)

**Trigger:** User chụp ảnh hoặc chọn từ gallery trên Mobile

**Flow:**

```
AddItemScreen (Mobile)
  │
  ├─→ User chọn ảnh từ Camera/Gallery
  │   └─→ ImagePicker.pickImage(...) → XFile
  │
  ├─→ File imageFile = File(pickedFile.path)
  │
  ├─→ [Giống Web] User điền thông tin
  │
  └─→ addItemFromBytes() nhưng đọc từ File:
      │
      ├─→ final bytes = await File(_pickedFile!.path).readAsBytes()
      │
      └─→ [Giống hệt flow Web từ đây trở đi]
```

**Files:** Giống Web, chỉ khác cách đọc ảnh

**Key Code:**

```dart
// add_item_screen.dart (line ~715)
else {
  // For mobile, read file as bytes and use addItemFromBytes
  final bytes = await File(_pickedFile!.path).readAsBytes();
  item = await wardrobeProvider.addItemFromBytes(bytes, ...);
}
```

---

### 8. Xem Chi Tiết Item

**Trigger:** User click vào 1 ClothingCard

**Flow:**

```
WardrobeScreen
  │
  ├─→ User tap vào ClothingCard(item)
  │
  └─→ Navigator.push(ItemDetailScreen(item: item))
      │
      └─→ ItemDetailScreen build:
          │
          ├─→ Hiển thị:
          │   ├─→ ClothingImage (from Base64)
          │   ├─→ Item info (type, color, material, styles, seasons)
          │   ├─→ Stats (wearCount, lastWorn)
          │   ├─→ createdAt
          │   └─→ notes
          │
          ├─→ Actions:
          │   ├─→ Toggle Favorite button
          │   ├─→ Mark as Worn button
          │   └─→ Delete button
          │
          └─→ [Các actions dẫn đến flows khác]
```

**Files:**

- `lib/screens/wardrobe_screen.dart` → ClothingCard onTap
- `lib/screens/item_detail_screen.dart`
- `lib/widgets/clothing_card.dart` → ClothingImage widget

**Key Methods:**

```dart
// wardrobe_screen.dart
ClothingCard(
  item: item,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ItemDetailScreen(item: item),
    ),
  ),
)
```

---

### 9. Cập Nhật Item

**Trigger:** User sửa thông tin trong ItemDetailScreen hoặc AddItemScreen

**Flow:**

```
ItemDetailScreen / AddItemScreen
  │
  ├─→ User sửa thông tin (notes, brand, etc.)
  │
  └─→ wardrobeProvider.updateItem(updatedItem)
      │
      ├─→ FirebaseService.updateClothingItem(item)
      │   │
      │   ├─→ collection('items').doc(item.id).update(item.toJson())
      │   └─→ Return success/fail
      │
      ├─→ Nếu success:
      │   ├─→ Tìm index trong _items
      │   ├─→ _items[index] = item
      │   └─→ notifyListeners()
      │
      └─→ Navigator.pop()
```

**Files:**

- `lib/screens/item_detail_screen.dart` → Edit actions
- `lib/providers/wardrobe_provider.dart` → `updateItem()`
- `lib/services/firebase_service.dart` → `updateClothingItem()`

**Key Methods:**

```dart
// wardrobe_provider.dart (line ~220)
Future<bool> updateItem(ClothingItem item) async

// firebase_service.dart (line ~170)
Future<bool> updateClothingItem(ClothingItem item) async
```

---

### 10. Xóa Item

**Trigger:** User click "Xóa" trong ItemDetailScreen

**Flow:**

```
ItemDetailScreen
  │
  ├─→ User click Delete button
  │
  ├─→ Show confirmation dialog
  │   └─→ User confirm
  │
  └─→ wardrobeProvider.deleteItem(item.id)
      │
      ├─→ FirebaseService.deleteClothingItem(item.id)
      │   │
      │   ├─→ collection('items').doc(itemId).delete()
      │   │   └─→ Base64 image tự động xóa cùng document
      │   └─→ Return success/fail
      │
      ├─→ Nếu success:
      │   ├─→ _items.removeWhere((i) => i.id == itemId)
      │   └─→ notifyListeners()
      │
      └─→ Navigator.pop() → Back to WardrobeScreen
```

**Files:**

- `lib/screens/item_detail_screen.dart` → Delete button
- `lib/providers/wardrobe_provider.dart` → `deleteItem()`
- `lib/services/firebase_service.dart` → `deleteClothingItem()`

**Key Methods:**

```dart
// wardrobe_provider.dart (line ~370)
Future<bool> deleteItem(String itemId) async

// firebase_service.dart (line ~176)
Future<bool> deleteClothingItem(String itemId) async
```

---

### 11. Toggle Favorite

**Trigger:** User click nút ⭐ trong ItemDetailScreen hoặc ClothingCard

**Flow:**

```
ItemDetailScreen / ClothingCard
  │
  ├─→ User click Favorite icon
  │
  └─→ wardrobeProvider.toggleFavorite(item, !item.isFavorite)
      │
      ├─→ FirebaseService.toggleFavorite(item.id, newValue)
      │   │
      │   ├─→ collection('items').doc(itemId).update({'isFavorite': newValue})
      │   └─→ Return success
      │
      ├─→ Nếu success:
      │   ├─→ Tìm index trong _items
      │   ├─→ _items[index] = item.copyWith(isFavorite: newValue)
      │   └─→ notifyListeners() → Icon update
      │
      └─→ [Không navigate, chỉ update icon]
```

**Files:**

- `lib/screens/item_detail_screen.dart` → Favorite button
- `lib/widgets/clothing_card.dart` → Favorite icon
- `lib/providers/wardrobe_provider.dart` → `toggleFavorite()`
- `lib/services/firebase_service.dart` → `toggleFavorite()`

**Key Methods:**

```dart
// wardrobe_provider.dart (line ~250)
Future<void> toggleFavorite(ClothingItem item, bool newValue) async

// firebase_service.dart (line ~210)
Future<bool> toggleFavorite(String itemId, bool isFavorite) async
```

---

### 12. Filter Items (Theo Type/Category)

**Trigger:** User chọn category filter trong WardrobeScreen

**Flow:**

```
WardrobeScreen
  │
  ├─→ User tap category chip (Tất cả, Áo, Quần, Giày...)
  │
  └─→ wardrobeProvider.setFilterCategory(categoryName)
      │
      ├─→ _filterCategory = categoryName
      ├─→ _filterType = null (clear type filter)
      │
      ├─→ notifyListeners()
      │   │
      │   └─→ Getter _filteredItems re-compute:
      │       │
      │       ├─→ if (_filterType != null):
      │       │   return items.where((i) => i.type == _filterType)
      │       │
      │       ├─→ if (_filterCategory != null):
      │       │   return items.where((i) => i.type.category == _filterCategory)
      │       │
      │       └─→ else: return all items
      │
      └─→ UI rebuild với filtered list
```

**Files:**

- `lib/screens/wardrobe_screen.dart` → Filter chips
- `lib/providers/wardrobe_provider.dart` → `setFilterCategory()`, `_filteredItems` getter

**Key Methods:**

```dart
// wardrobe_provider.dart (line ~410)
void setFilterCategory(String? category)

// wardrobe_provider.dart (line ~92)
List<ClothingItem> get _filteredItems {
  if (_filterType != null) return _items.where(...);
  if (_filterCategory != null) return _items.where(...);
  return _items;
}
```

---

## C. AI FEATURES FLOWS

### 13. AI Phân Tích Ảnh Quần Áo

**Trigger:** User chọn "Dùng AI phân tích" trong AddItemScreen

**Flow:**

````
AddItemScreen
  │
  ├─→ User toggle "Use AI"
  ├─→ User chọn ảnh
  │
  └─→ GeminiService.analyzeClothingImageBytes(imageBytes)
      │
      ├─→ [UPLOAD] Upload image to Gemini:
      │   GoogleAIFileManager.uploadFile(bytes, mimeType: 'image/jpeg')
      │   └─→ UploadedFile với URI
      │
      ├─→ [PROMPT] Build prompt:
      │   """
      │   Phân tích quần áo trong ảnh. Trả về JSON:
      │   {
      │     "type": "top|bottom|outerwear|footwear|...",
      │     "color": "màu chính",
      │     "material": "cotton|jean|...",
      │     "styles": ["casual", "formal", ...],
      │     "seasons": ["spring", "summer", ...]
      │   }
      │   """
      │
      ├─→ [CALL AI] _visionModel.generateContent([prompt, fileUri])
      │   │
      │   └─→ Timeout: 30 seconds
      │
      ├─→ [PARSE] response.text → JSON
      │   │
      │   ├─→ Extract từ markdown: ```json ... ```
      │   ├─→ jsonDecode(cleanJson)
      │   └─→ Return JSON string
      │
      └─→ AddItemScreen parse và fill vào form
````

**Files:**

- `lib/screens/add_item_screen.dart` → AI toggle
- `lib/services/gemini_service.dart` → `analyzeClothingImageBytes()`
- `lib/models/clothing_item.dart` → Enums (ClothingType, Season, etc.)

**Key Methods:**

```dart
// gemini_service.dart (line ~160)
Future<String> analyzeClothingImageBytes(Uint8List imageBytes) async

// add_item_screen.dart (line ~400+)
final result = await geminiService.analyzeClothingImageBytes(imageBytes);
final json = jsonDecode(result);
// Parse và fill form
```

---

### 14. Gợi Ý Outfit

**Trigger:** User chọn dịp trong OutfitSuggestScreen và click "Gợi ý"

**Flow:**

```
OutfitSuggestScreen
  │
  ├─→ User chọn occasion (work, date, party, ...)
  ├─→ Click "Gợi ý outfit"
  │
  └─→ wardrobeProvider.suggestOutfit(occasion)
      │
      ├─→ _isSuggestingOutfit = true
      ├─→ notifyListeners() → Show loading
      │
      ├─→ [STEP 1] Get weather:
      │   weatherContext = _weather?.toAIDescription() ?? "Không có dữ liệu"
      │
      ├─→ [STEP 2] Call Gemini AI:
      │   GeminiService.suggestOutfit(
      │     wardrobe: _items,
      │     weatherContext: weatherContext,
      │     occasion: occasion,
      │     stylePreference: _stylePreference.aiDescription
      │   )
      │   │
      │   ├─→ Build prompt with:
      │   │   - Danh sách items (format: id|type|color|styles)
      │   │   - Weather context
      │   │   - Occasion
      │   │   - Style preference (regular/minimalist/bold)
      │   │
      │   ├─→ _model.generateContent(prompt)
      │   │
      │   └─→ Parse JSON response:
      │       {
      │         "top": "item_id_1",
      │         "bottom": "item_id_2",
      │         "outerwear": "item_id_3",
      │         "footwear": "item_id_4",
      │         "accessories": ["item_id_5", "item_id_6"],
      │         "reasoning": "Lý do chọn outfit này..."
      │       }
      │
      ├─→ [STEP 3] Build Outfit object:
      │   │
      │   ├─→ Find items by IDs from _items list
      │   ├─→ Outfit(
      │   │     id: uuid.v4(),
      │   │     top: foundItem,
      │   │     bottom: foundItem,
      │   │     outerwear: foundItem,
      │   │     footwear: foundItem,
      │   │     accessories: [foundItems],
      │   │     occasion: occasion,
      │   │     reasoning: reasoning
      │   │   )
      │   └─→ _currentOutfit = outfit
      │
      ├─→ _isSuggestingOutfit = false
      └─→ notifyListeners() → Show outfit result
```

**Files:**

- `lib/screens/outfit_suggest_screen.dart` → UI và button
- `lib/providers/wardrobe_provider.dart` → `suggestOutfit()`
- `lib/services/gemini_service.dart` → `suggestOutfit()`
- `lib/models/outfit.dart` → Outfit model
- `lib/models/weather.dart` → `toAIDescription()`

**Key Methods:**

```dart
// outfit_suggest_screen.dart
onPressed: () => wardrobeProvider.suggestOutfit(selectedOccasion)

// wardrobe_provider.dart (line ~285)
Future<void> suggestOutfit(String occasion) async

// gemini_service.dart (line ~300)
Future<String> suggestOutfit(...) async
```

---

### 15. Chấm Điểm Color Harmony

**Trigger:** User chọn 2 items và click "Đánh giá"

**Flow:**

```
ColorHarmonyScreen
  │
  ├─→ User select item 1
  ├─→ User select item 2
  ├─→ Click "Đánh giá độ hợp màu"
  │
  └─→ wardrobeProvider.evaluateColorHarmony(item1, item2)
      │
      └─→ GeminiService.evaluateColorHarmony(item1, item2)
          │
          ├─→ Build prompt:
          │   """
          │   Đánh giá độ hài hòa màu sắc:
          │   - Item 1: {type} màu {color}
          │   - Item 2: {type} màu {color}
          │
          │   Trả về JSON:
          │   {
          │     "score": 0-100,
          │     "level": "excellent|good|fair|poor",
          │     "reasoning": "Lý do...",
          │     "tips": "Gợi ý cải thiện..."
          │   }
          │   """
          │
          ├─→ _model.generateContent(prompt)
          │
          ├─→ Parse JSON response
          │
          └─→ Return ColorHarmonyResult(
                score: score,
                level: level,
                reasoning: reasoning,
                tips: tips
              )
              │
              └─→ ColorHarmonyScreen show result
```

**Files:**

- `lib/screens/color_harmony_screen.dart` → UI
- `lib/providers/wardrobe_provider.dart` → `evaluateColorHarmony()`
- `lib/services/gemini_service.dart` → `evaluateColorHarmony()`
- `lib/models/clothing_item.dart` → ClothingItem data

**Key Methods:**

```dart
// color_harmony_screen.dart
onPressed: () async {
  final result = await wardrobeProvider.evaluateColorHarmony(item1, item2);
  // Show result
}

// wardrobe_provider.dart (line ~358)
Future<ColorHarmonyResult?> evaluateColorHarmony(...) async

// gemini_service.dart (line ~400)
Future<String> evaluateColorHarmony(ClothingItem item1, ClothingItem item2) async
```

---

### 16. Dọn Tủ Đồ (Cleanup Suggestions)

**Trigger:** User vào WardrobeCleanupScreen

**Flow:**

```
WardrobeCleanupScreen (initState)
  │
  └─→ wardrobeProvider.getCleanupSuggestions()
      │
      └─→ GeminiService.getCleanupSuggestions(_items)
          │
          ├─→ Check: if items.isEmpty → return null
          │
          ├─→ Build prompt với danh sách items:
          │   """
          │   Phân tích tủ đồ và đề xuất:
          │   - Items trùng lặp
          │   - Items ít sử dụng (wearCount thấp)
          │   - Items không phù hợp (out of season)
          │   - Gợi ý optimize
          │
          │   Danh sách items:
          │   [Item 1: type|color|wearCount|lastWorn]
          │   [Item 2: ...]
          │   """
          │
          ├─→ _model.generateContent(prompt)
          │
          ├─→ Parse response (plain text, không phải JSON)
          │
          └─→ Return suggestions text
              │
              └─→ WardrobeCleanupScreen display suggestions
```

**Files:**

- `lib/screens/wardrobe_cleanup_screen.dart`
- `lib/providers/wardrobe_provider.dart` → `getCleanupSuggestions()`
- `lib/services/gemini_service.dart` → `getCleanupSuggestions()`

**Key Methods:**

```dart
// wardrobe_cleanup_screen.dart (initState)
Future.microtask(() async {
  final suggestions = await wardrobeProvider.getCleanupSuggestions();
  setState(() => _suggestions = suggestions);
});

// wardrobe_provider.dart (line ~364)
Future<String?> getCleanupSuggestions() async

// gemini_service.dart (line ~500)
Future<String> getCleanupSuggestions(List<ClothingItem> items) async
```

---

### 17. Load Weather Data

**Trigger:** HomeScreen initState hoặc user change location

**Flow:**

```
HomeScreen (initState) / ProfileScreen (change location)
  │
  └─→ wardrobeProvider.loadWeather(city: cityName)
      │
      └─→ WeatherService.getCurrentWeather(city: city)
          │
          ├─→ Check cache:
          │   if (_cachedWeather != null && !expired) → return cached
          │
          ├─→ Build API URL:
          │   baseUrl/weather?q={city}&appid={apiKey}&units=metric&lang=vi
          │
          ├─→ http.get(url)
          │   │
          │   └─→ Timeout: 10 seconds
          │
          ├─→ Parse JSON response:
          │   WeatherInfo(
          │     cityName: json['name'],
          │     temperature: json['main']['temp'],
          │     description: json['weather'][0]['description'],
          │     iconUrl: constructIconUrl(json['weather'][0]['icon']),
          │     ...
          │   )
          │
          ├─→ Cache result với timestamp
          │
          └─→ WardrobeProvider._weather = weatherInfo
              └─→ notifyListeners() → Weather widget update
```

**Files:**

- `lib/screens/home_screen.dart` → initState
- `lib/screens/profile_screen.dart` → Change location
- `lib/providers/wardrobe_provider.dart` → `loadWeather()`
- `lib/services/weather_service.dart` → `getCurrentWeather()`
- `lib/models/weather.dart` → WeatherInfo model

**Key Methods:**

```dart
// home_screen.dart (initState)
Future.microtask(() {
  wardrobeProvider.loadWeather();
});

// wardrobe_provider.dart (line ~130)
Future<void> loadWeather({String? city}) async

// weather_service.dart (line ~30)
Future<WeatherInfo> getCurrentWeather({String? city}) async
```

---

## D. NAVIGATION FLOWS

### 18. Navigate giữa Tabs (Bottom Nav)

**Trigger:** User tap vào tab trong BottomNavigationBar

**Flow:**

```
HomeScreen
  │
  ├─→ BottomNavigationBar currentIndex = _selectedIndex
  │
  ├─→ User tap tab:
  │   ├─→ Tab 0: Tủ đồ (WardrobeScreen)
  │   ├─→ Tab 1: Gợi ý (OutfitSuggestScreen)
  │   ├─→ Tab 2: Hợp màu (ColorHarmonyScreen)
  │   └─→ Tab 3: Hồ sơ (ProfileScreen)
  │
  └─→ setState(() => _selectedIndex = newIndex)
      │
      └─→ Body rebuild with _screens[_selectedIndex]
```

**Files:**

- `lib/screens/home_screen.dart` → BottomNavigationBar

**Key Code:**

```dart
// home_screen.dart (line ~100)
final _screens = [
  WardrobeScreen(),
  OutfitSuggestScreen(),
  ColorHarmonyScreen(),
  ProfileScreen(),
];

BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: (index) => setState(() => _selectedIndex = index),
)
```

---

### 19. Navigate tới Add Item

**Trigger:** User click FAB "+" trong WardrobeScreen hoặc HomeScreen

**Flow:**

```
WardrobeScreen / HomeScreen
  │
  ├─→ FloatingActionButton onPressed
  │
  └─→ Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddItemScreen())
      )
      │
      ├─→ AddItemScreen shows
      │
      └─→ [User complete add item flow]
          │
          └─→ Navigator.pop() → Back to WardrobeScreen
```

**Files:**

- `lib/screens/wardrobe_screen.dart` → FAB
- `lib/screens/home_screen.dart` → FAB
- `lib/screens/add_item_screen.dart`

**Key Code:**

```dart
// wardrobe_screen.dart / home_screen.dart
FloatingActionButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => AddItemScreen()),
  ),
  child: Icon(Icons.add),
)
```

---

### 20. Navigate tới Item Detail

**Trigger:** User tap ClothingCard

**Flow:**

```
WardrobeScreen / OutfitSuggestScreen
  │
  ├─→ ClothingCard(item: item, onTap: ...)
  │
  └─→ Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ItemDetailScreen(item: item)
        )
      )
      │
      ├─→ ItemDetailScreen shows
      │
      └─→ User có thể:
          ├─→ View details
          ├─→ Toggle favorite
          ├─→ Mark as worn
          ├─→ Delete → Navigator.pop()
          └─→ Back button → Navigator.pop()
```

**Files:**

- `lib/screens/wardrobe_screen.dart` → Grid items
- `lib/screens/outfit_suggest_screen.dart` → Outfit items
- `lib/widgets/clothing_card.dart`
- `lib/screens/item_detail_screen.dart`

**Key Code:**

```dart
// wardrobe_screen.dart
ClothingCard(
  item: items[index],
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => ItemDetailScreen(item: items[index])),
  ),
)
```

---

## E. PROFILE & SETTINGS FLOWS

### 21. Load Profile Info

**Trigger:** User vào ProfileScreen

**Flow:**

```
ProfileScreen (build)
  │
  ├─→ Consumer<AuthProvider>
  │   └─→ authProvider.currentUser
  │       ├─→ displayName
  │       ├─→ email
  │       └─→ photoURL
  │
  └─→ Consumer<WardrobeProvider>
      └─→ wardrobeProvider.items
          │
          ├─→ Total items: items.length
          │
          └─→ Count by type:
              ├─→ Áo: items.where((i) => i.type.category == 'Áo').length
              ├─→ Quần: items.where((i) => i.type.category == 'Quần').length
              └─→ ...
```

**Files:**

- `lib/screens/profile_screen.dart`
- `lib/providers/auth_provider.dart` → currentUser
- `lib/providers/wardrobe_provider.dart` → items

**Key Code:**

```dart
// profile_screen.dart (line ~100+)
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    final user = authProvider.currentUser;
    return Column(children: [
      Text(user?.displayName ?? 'User'),
      Text(user?.email ?? ''),
    ]);
  }
)

Consumer<WardrobeProvider>(
  builder: (context, wardrobeProvider, _) {
    final totalItems = wardrobeProvider.items.length;
    return Text('Tổng: $totalItems món');
  }
)
```

---

### 22. Change Style Preference

**Trigger:** User chọn radio button style preference

**Flow:**

```
ProfileScreen
  │
  ├─→ User select style radio:
  │   ├─→ Regular (Thông thường)
  │   ├─→ Minimalist (Tối giản)
  │   └─→ Bold (Nổi bật)
  │
  └─→ wardrobeProvider.setStylePreference(newPreference)
      │
      ├─→ _stylePreference = preference
      │
      └─→ notifyListeners()
          └─→ [Sẽ ảnh hưởng đến AI suggest outfit sau này]
```

**Files:**

- `lib/screens/profile_screen.dart` → Radio buttons
- `lib/providers/wardrobe_provider.dart` → `setStylePreference()`
- `lib/models/clothing_item.dart` → StylePreference enum

**Key Methods:**

```dart
// profile_screen.dart (line ~300+)
Radio<StylePreference>(
  value: StylePreference.regular,
  groupValue: wardrobeProvider.stylePreference,
  onChanged: (value) {
    wardrobeProvider.setStylePreference(value!);
  },
)

// wardrobe_provider.dart (line ~280)
void setStylePreference(StylePreference preference)
```

---

### 23. Change Weather Location

**Trigger:** User nhập city mới và click "Cập nhật"

**Flow:**

```
ProfileScreen
  │
  ├─→ User nhập tên thành phố vào TextField
  ├─→ Click "Cập nhật thời tiết"
  │
  └─→ wardrobeProvider.changeWeatherLocation(cityName)
      │
      ├─→ WeatherService.clearCache()
      │   └─→ _cachedWeather = null
      │
      └─→ loadWeather(city: city)
          └─→ [Flow giống #17 Load Weather Data]
```

**Files:**

- `lib/screens/profile_screen.dart` → TextField và button
- `lib/providers/wardrobe_provider.dart` → `changeWeatherLocation()`
- `lib/services/weather_service.dart` → `clearCache()`, `getCurrentWeather()`

**Key Methods:**

```dart
// profile_screen.dart (line ~400+)
TextField(
  controller: _cityController,
  decoration: InputDecoration(labelText: 'Thành phố'),
)

ElevatedButton(
  onPressed: () {
    wardrobeProvider.changeWeatherLocation(_cityController.text);
  },
  child: Text('Cập nhật thời tiết'),
)

// wardrobe_provider.dart (line ~145)
Future<void> changeWeatherLocation(String city) async
```

---

## 📊 TỔNG KẾT

### Thống kê Flows:

- **Authentication:** 4 flows
- **Wardrobe Management:** 8 flows
- **AI Features:** 5 flows
- **Navigation:** 3 flows
- **Profile & Settings:** 3 flows

**Tổng cộng: 23 luồng chính**

---

## 🎯 CÁCH SỬ DỤNG FILE NÀY

### Khi đọc code:

1. **Tìm flow cần trace** trong mục lục
2. **Đọc flow diagram** để hiểu tổng quan
3. **Mở files theo thứ tự** được liệt kê
4. **Tìm methods** với line numbers gợi ý
5. **F12 (Go to definition)** để jump giữa các files

### Khi debug:

1. **Xác định flow bị lỗi** (ví dụ: "Thêm item không hoạt động")
2. **Mở flow #6 hoặc #7** để xem từng bước
3. **Đặt breakpoint** ở từng step trong flow
4. **Chạy lại** và theo dõi data flow

### Khi thêm feature mới:

1. **Tham khảo flow tương tự** (ví dụ: muốn thêm "Share outfit" → xem flow #14)
2. **Copy structure** của flow đó
3. **Modify** theo nhu cầu

---

**💡 Tips:** Bookmark file này và dùng Ctrl+F để tìm nhanh flow cần trace!
