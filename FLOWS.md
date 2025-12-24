# 🗺️ CÁC LUỒNG XỬ LÝ TRONG APP

> **Mục đích:** Hiểu cách data và event flow trong app

> **Cập nhật:** 24/12/2024 - App đang sử dụng **Groq API** (Llama 4 Scout) thay vì Gemini

---

## 📋 MỤC LỤC

| Nhóm | Luồng |
|------|-------|
| **A. Authentication** | 1-4: Login, Logout |
| **B. Wardrobe CRUD** | 5-12: Load, Add, Update, Delete Items |
| **C. AI Features** | 13-17: Phân tích ảnh, Gợi ý outfit, Color Harmony |
| **D. Navigation** | 18-20: Tab navigation, Screen navigation |

---

## 🏗️ CẤU TRÚC CHUNG

Mọi luồng đều theo pattern:

```
User Action → Screen → Provider → Service → API
                              ↓
                       notifyListeners()
                              ↓
                         UI Rebuild
```

---

## A. AUTHENTICATION FLOWS

### 1. Khởi động App & Auto Login

**Trigger:** App được mở

```
main.dart
  │
  ├─→ Firebase.initializeApp()
  ├─→ FirebaseService.ensurePersistence()
  │
  └─→ MyApp → AuthWrapper
              │
              └─→ Consumer<AuthProvider>
                  │
                  ├─→ status == initial → Loading
                  ├─→ isAuthenticated → HomeScreen
                  └─→ else → LoginScreen
```

**Files:** `main.dart`, `lib/providers/auth_provider.dart`

---

### 2. Đăng nhập Google

**Trigger:** User tap "Đăng nhập với Google"

```
LoginScreen
  │
  └─→ authProvider.signInWithGoogle()
      │
      ├─→ _status = AuthStatus.authenticating
      ├─→ notifyListeners() → UI loading
      │
      └─→ _firebaseService.signInWithGoogle()
          │
          ├─→ GoogleSignIn().signIn()
          ├─→ FirebaseAuth.signInWithCredential()
          └─→ Return User
      │
      ├─→ _user = user
      ├─→ _status = AuthStatus.authenticated
      └─→ notifyListeners() → Navigate to HomeScreen
```

**Files:** `login_screen.dart`, `auth_provider.dart`, `firebase_service.dart`

---

### 3. Đăng nhập Email/Password

**Trigger:** User submit form email/password

```
LoginScreen
  │
  └─→ authProvider.signInWithEmail(email, password)
      │
      └─→ _firebaseService.signInWithEmail()
          │
          └─→ FirebaseAuth.signInWithEmailAndPassword()
```

---

### 4. Đăng xuất

**Trigger:** User tap "Đăng xuất" trong ProfileScreen

```
ProfileScreen
  │
  └─→ authProvider.signOut()
      │
      ├─→ _firebaseService.signOut()
      │   └─→ FirebaseAuth.signOut()
      │
      ├─→ _user = null
      ├─→ _status = AuthStatus.unauthenticated
      └─→ notifyListeners() → Navigate to LoginScreen
```

---

## B. WARDROBE MANAGEMENT FLOWS

### 5. Load Tủ Đồ (Lần đầu)

**Trigger:** HomeScreen's initState

```
HomeScreen.initState()
  │
  └─→ WidgetsBinding.addPostFrameCallback
      │
      └─→ wardrobeProvider.loadItems()
          │
          ├─→ _status = WardrobeStatus.loading
          ├─→ notifyListeners() → UI shimmer loading
          │
          └─→ _firebaseService.getItems(userId)
              │
              └─→ Firestore.collection('items')
                  .where('userId', ==, userId)
                  .orderBy('createdAt', descending)
                  .get()
          │
          ├─→ _items = items.map(ClothingItem.fromFirestore)
          ├─→ _status = WardrobeStatus.loaded
          └─→ notifyListeners() → UI hiện danh sách
```

**Files:** `home_screen.dart`, `wardrobe_provider.dart`, `firebase_service.dart`

---

### 6. Thêm Item (với AI Phân Tích)

**Trigger:** User chọn ảnh trong AddItemScreen

```
AddItemScreen
  │
  ├─→ _pickImage(source)
  │   │
  │   ├─→ ImagePicker.pickImage()
  │   ├─→ pickedFile.readAsBytes()
  │   └─→ setState: _imageBytes = bytes
  │
  └─→ _analyzeImage()
      │
      ├─→ setState: _isAnalyzing = true
      │
      └─→ _groqService.analyzeClothingImageBytes(bytes) ⭐
          │
          ├─→ base64Encode(bytes)
          │
          ├─→ HTTP POST to Groq API
          │   {
          │     'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
          │     'messages': [{
          │       'content': [
          │         {'type': 'text', 'text': AIPrompts.analyzeClothing},
          │         {'type': 'image_url', 'image_url': {...}}
          │       ]
          │     }]
          │   }
          │
          └─→ Parse JSON response
              {
                "type": "tshirt",
                "color": "trắng",
                "material": "cotton",
                "styles": ["casual"],
                "seasons": ["summer"]
              }
      │
      ├─→ Fill data vào form
      │   _selectedType = ClothingType.fromString(result['type'])
      │   _selectedColor = result['color']
      │   ...
      │
      └─→ setState: _isAnalyzing = false
```

**Files:** `add_item_screen.dart`, `groq_service.dart`, `constants.dart` (prompts)

---

### 7. Lưu Item vào Firebase

**Trigger:** User tap "Lưu" trong AddItemScreen

```
AddItemScreen
  │
  └─→ _saveItem()
      │
      ├─→ Validate form
      │
      └─→ wardrobeProvider.addItemFromBytes(
            bytes: _imageBytes,
            type: _selectedType,
            color: _selectedColor,
            ...
          )
          │
          ├─→ Create ClothingItem object
          │
          └─→ _firebaseService.addItem(item)
              │
              └─→ Firestore.collection('items').add(item.toJson())
          │
          ├─→ _items.insert(0, item)
          └─→ notifyListeners() → UI update
      │
      └─→ Navigator.pop() → Back to WardrobeScreen
```

---

### 8. Xem Chi Tiết Item

**Trigger:** User tap vào ClothingCard

```
WardrobeScreen
  │
  └─→ _navigateToDetail(item)
      │
      └─→ Navigator.push(ItemDetailScreen(item))
          │
          └─→ ItemDetailScreen hiển thị:
              - Ảnh lớn
              - Thông tin chi tiết
              - Buttons: Edit, Delete, Favorite
```

---

### 9. Xóa Item

**Trigger:** User tap "Xóa" trong ItemDetailScreen

```
ItemDetailScreen
  │
  └─→ _confirmDelete()
      │
      └─→ showDialog (confirm)
          │
          └─→ wardrobeProvider.deleteItem(item)
              │
              └─→ _firebaseService.deleteItem(item.id)
                  │
                  └─→ Firestore.doc(item.id).delete()
              │
              ├─→ _items.removeWhere(id == item.id)
              └─→ notifyListeners()
          │
          └─→ Navigator.pop() → Back to list
```

---

### 10. Toggle Favorite

**Trigger:** User tap heart icon

```
ClothingCard hoặc ItemDetailScreen
  │
  └─→ wardrobeProvider.toggleFavorite(item)
      │
      ├─→ item.isFavorite = !item.isFavorite
      │
      └─→ _firebaseService.updateItem(item)
          │
          └─→ Firestore.doc(item.id).update({'isFavorite': ...})
      │
      └─→ notifyListeners()
```

---

### 11. Filter Items

**Trigger:** User chọn filter chip

```
WardrobeScreen
  │
  └─→ wardrobeProvider.setFilterType(type) / setFilterCategory(cat)
      │
      ├─→ _filterType = type
      └─→ notifyListeners()
          │
          └─→ Getter `items` tự filter:
              _items.where((item) => 
                (_filterType == null || item.type == _filterType)
              )
```

---

## C. AI FEATURES FLOWS ⭐

### 13. AI Phân Tích Ảnh Quần Áo

> **Chi tiết đã giải thích ở Flow 6**

**Điểm quan trọng:**
- Service: `GroqService.analyzeClothingImageBytes()`
- Model: `meta-llama/llama-4-scout-17b-16e-instruct`
- Prompt: `AIPrompts.analyzeClothing` (trong constants.dart)
- Response: JSON với type, color, material, styles, seasons

---

### 14. Gợi Ý Outfit

**Trigger:** User chọn occasion và tap "Gợi ý outfit"

```
OutfitSuggestScreen
  │
  ├─→ User chọn occasion (work, date, party...)
  ├─→ Tap "Gợi ý outfit cho tôi"
  │
  └─→ wardrobeProvider.suggestOutfit(occasion)
      │
      ├─→ _isSuggestingOutfit = true
      ├─→ notifyListeners() → UI shimmer
      │
      ├─→ weatherContext = _weather.toAIDescription()
      │   "Temperature: 25°C, Humidity: 70%, Condition: Clear"
      │
      └─→ _groqService.suggestOutfit(
            wardrobe: _items,
            weatherContext: weatherContext,
            occasion: occasion,
            stylePreference: _stylePreference.aiDescription
          )
          │
          ├─→ Build wardrobeContext:
          │   "ID: abc | Type: top | Color: trắng | Styles: casual..."
          │   "ID: def | Type: bottom | Color: đen | Styles: formal..."
          │
          ├─→ Build prompt: AIPrompts.suggestOutfit(...)
          │
          └─→ HTTP POST to Groq API (model: llama-3.3-70b-versatile)
              │
              └─→ Response:
                  {
                    "top": "abc",
                    "bottom": "def",
                    "footwear": "ghi",
                    "accessories": [],
                    "reason": "Áo trắng phối quần đen..."
                  }
      │
      └─→ _buildOutfitFromSuggestion(suggestion, occasion)
          │
          ├─→ findItem("abc") → ClothingItem
          ├─→ findItem("def") → ClothingItem
          │
          └─→ Outfit(
                top: item1,
                bottom: item2,
                reason: "...",
                occasion: "Đi làm"
              )
      │
      ├─→ _currentOutfit = outfit
      ├─→ _isSuggestingOutfit = false
      └─→ notifyListeners() → UI hiện OutfitCard
```

**Files:** `outfit_suggest_screen.dart`, `wardrobe_provider.dart`, `groq_service.dart`

---

### 15. Chấm Điểm Color Harmony

**Trigger:** User chọn 2 items và tap "Đánh giá"

```
ColorHarmonyScreen
  │
  ├─→ User chọn item 1
  ├─→ User chọn item 2
  ├─→ Tap "Đánh giá độ hợp màu"
  │
  └─→ wardrobeProvider.evaluateColorHarmony(item1, item2)
      │
      └─→ _groqService.evaluateColorHarmony(item1, item2)
          │
          ├─→ Build prompt: AIPrompts.colorHarmony(
          │     item1.toAIDescription(),
          │     item2.toAIDescription()
          │   )
          │
          └─→ Response:
              {
                "score": 85,
                "reason": "Trắng và đen là combo classic...",
                "vibe": "Elegant",
                "tips": ["Thêm phụ kiện màu...", ...]
              }
      │
      └─→ ColorHarmonyResult.fromJson(response)
          │
          └─→ UI hiển thị score, reason, tips
```

---

### 16. Dọn Tủ Đồ (Cleanup Suggestions)

**Trigger:** User vào WardrobeCleanupScreen

```
WardrobeCleanupScreen
  │
  └─→ wardrobeProvider.getCleanupSuggestions()
      │
      └─→ _groqService.getCleanupSuggestions(_items)
          │
          ├─→ Build wardrobeContext từ tất cả items
          ├─→ Build prompt: AIPrompts.cleanupSuggestion(...)
          │
          └─→ Response:
              {
                "itemsToRemove": ["id1", "id2"],
                "reasons": ["Đồ cũ ít mặc", "Bị phai màu"],
                "tips": ["Donate đồ không mặc > 1 năm"]
              }
```

---

### 17. Load Weather Data

**Trigger:** HomeScreen initState hoặc refresh

```
HomeScreen
  │
  └─→ wardrobeProvider.loadWeather()
      │
      └─→ _weatherService.getCurrentWeather(city)
          │
          └─→ HTTP GET: OpenWeatherMap API
              │
              └─→ Response: {temp, humidity, condition, icon}
      │
      ├─→ _weather = WeatherInfo.fromJson(response)
      └─→ notifyListeners() → UI hiện weather widget
```

---

## D. NAVIGATION FLOWS

### 18. Navigate giữa Tabs (Bottom Nav)

```
HomeScreen
  │
  └─→ BottomNavigationBar
      │
      ├─→ index 0: WardrobeScreen
      ├─→ index 1: OutfitSuggestScreen
      ├─→ index 2: ColorHarmonyScreen
      └─→ index 3: ProfileScreen
      │
      └─→ setState: _currentIndex = index
          │
          └─→ IndexedStack hiển thị screen tương ứng
```

---

### 19. Navigate tới Add Item

```
WardrobeScreen (hoặc HomeScreen)
  │
  └─→ FloatingActionButton.onPressed
      │
      └─→ Navigator.push(AddItemScreen())
```

---

### 20. Navigate tới Item Detail

```
WardrobeScreen
  │
  └─→ ClothingCard.onTap
      │
      └─→ Navigator.push(ItemDetailScreen(item: item))
```

---

## 📊 SƠ ĐỒ TỔNG QUAN

```
┌─────────────────────────────────────────────────────────────────┐
│                           USER                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       SCREENS (UI)                               │
│  LoginScreen, HomeScreen, WardrobeScreen, AddItemScreen...      │
│  → Nhận input, hiển thị data, trigger actions                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   PROVIDERS (State Management)                   │
│            AuthProvider, WardrobeProvider                        │
│  → Giữ state, xử lý logic, gọi services, notify UI              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     SERVICES (API Layer)                         │
│       FirebaseService, GroqService, WeatherService               │
│  → Gọi external APIs, xử lý response                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     EXTERNAL APIs                                │
│         Firebase, Groq AI (Llama 4), OpenWeatherMap             │
└─────────────────────────────────────────────────────────────────┘
```

---

## 💡 MẸO TRACE CODE

1. **Bắt đầu từ UI trigger** (onPressed, onTap)
2. **Theo method call** vào Provider
3. **Theo tiếp** vào Service
4. **Xem API call** và response
5. **Quay lại** xem notifyListeners() trigger UI rebuild

**Dùng VS Code:**
- `Ctrl + Click` vào method name → nhảy đến định nghĩa
- `Ctrl + Shift + F` → tìm kiếm toàn project
- `F12` → Go to Definition

---

*Cập nhật: 24/12/2024*
