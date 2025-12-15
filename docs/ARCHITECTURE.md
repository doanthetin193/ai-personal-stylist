# 🏗️ Kiến trúc ứng dụng AI Personal Stylist

## 📁 Cấu trúc thư mục

```
lib/
├── main.dart                 # Entry point, khởi tạo app
├── firebase_options.dart     # Cấu hình Firebase (auto-generated)
│
├── models/                   # 📦 Data Models
│   ├── clothing_item.dart    # Model quần áo
│   ├── outfit.dart           # Model outfit & color harmony
│   └── weather.dart          # Model thời tiết
│
├── providers/                # 🔄 State Management (ChangeNotifier)
│   ├── auth_provider.dart    # Quản lý authentication
│   └── wardrobe_provider.dart# Quản lý tủ đồ, outfit, weather
│
├── services/                 # 🔧 Business Logic & API
│   ├── firebase_service.dart # CRUD Firestore & Storage
│   ├── gemini_service.dart   # Tích hợp AI Gemini
│   └── weather_service.dart  # Lấy dữ liệu thời tiết
│
├── screens/                  # 📱 Các màn hình UI
│   ├── login_screen.dart     # Đăng nhập Google
│   ├── home_screen.dart      # Màn hình chính + Bottom Nav
│   ├── wardrobe_screen.dart  # Hiển thị tủ đồ
│   ├── add_item_screen.dart  # Thêm quần áo mới
│   ├── item_detail_screen.dart# Chi tiết món đồ
│   ├── outfit_suggest_screen.dart # Gợi ý outfit AI
│   ├── color_harmony_screen.dart  # Chấm điểm phối màu
│   ├── wardrobe_cleanup_screen.dart # Dọn tủ đồ AI
│   └── profile_screen.dart   # Cài đặt & thông tin user
│
├── widgets/                  # 🧩 Reusable Widgets
│   ├── clothing_card.dart    # Card hiển thị quần áo
│   ├── outfit_card.dart      # Card hiển thị outfit
│   ├── common_widgets.dart   # Weather, Occasion chips, etc.
│   └── loading_widgets.dart  # Shimmer loading effects
│
└── utils/                    # 🛠️ Utilities
    ├── theme.dart            # Colors, Gradients, ThemeData
    ├── constants.dart        # Occasions, API constants
    ├── helpers.dart          # Helper functions
    └── api_keys.dart         # API keys (gitignored)
```

---

## 🔄 Luồng dữ liệu (Data Flow)

### Tổng quan kiến trúc

```
┌─────────────────────────────────────────────────────────────┐
│                        UI LAYER                              │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐        │
│  │ Screens │  │ Screens │  │ Screens │  │ Widgets │        │
│  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘        │
│       │            │            │            │              │
│       └────────────┴─────┬──────┴────────────┘              │
│                          │                                   │
│                    Consumer<T>                               │
│                    context.read<T>()                         │
│                    context.watch<T>()                        │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                    STATE LAYER                               │
│  ┌─────────────────┐         ┌──────────────────────┐       │
│  │  AuthProvider   │         │  WardrobeProvider    │       │
│  │                 │         │                      │       │
│  │ • user          │         │ • items (List)       │       │
│  │ • status        │         │ • currentOutfit      │       │
│  │ • signIn()      │         │ • weather            │       │
│  │ • signOut()     │         │ • loadItems()        │       │
│  └────────┬────────┘         │ • suggestOutfit()    │       │
│           │                  │ • evaluateHarmony()  │       │
│           │                  └──────────┬───────────┘       │
└───────────┼─────────────────────────────┼───────────────────┘
            │                             │
┌───────────▼─────────────────────────────▼───────────────────┐
│                    SERVICE LAYER                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐  │
│  │ FirebaseService │  │  GeminiService  │  │WeatherService│ │
│  │                 │  │                 │  │             │  │
│  │ • signInGoogle  │  │ • analyzeImage  │  │ • getWeather│  │
│  │ • saveItem      │  │ • suggestOutfit │  │             │  │
│  │ • getItems      │  │ • evaluateColor │  │             │  │
│  │ • uploadImage   │  │                 │  │             │  │
│  └────────┬────────┘  └────────┬────────┘  └──────┬──────┘  │
└───────────┼─────────────────────┼─────────────────┼─────────┘
            │                     │                 │
┌───────────▼─────────────────────▼─────────────────▼─────────┐
│                    EXTERNAL SERVICES                         │
│                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  Firebase   │  │ Google AI   │  │  Open-Meteo API     │  │
│  │             │  │   Gemini    │  │  (Weather)          │  │
│  │ • Auth      │  │             │  │                     │  │
│  │ • Firestore │  │ • 2.0 Flash │  │ • Free, no API key  │  │
│  │ • Storage   │  │             │  │                     │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 Provider Pattern

App sử dụng **Provider** package cho state management với pattern:

### 1. Khởi tạo Providers trong `main.dart`

```dart
MultiProvider(
  providers: [
    // Services - Provider đơn giản (không cần notify)
    Provider<GeminiService>.value(value: _geminiService),
    Provider<WeatherService>.value(value: _weatherService),
    Provider<FirebaseService>.value(value: widget.firebaseService),
    
    // State Providers - ChangeNotifierProvider (có notify)
    ChangeNotifierProvider(
      create: (_) => AuthProvider(firebaseService),
    ),
    ChangeNotifierProvider(
      create: (_) => WardrobeProvider(
        firebaseService,
        geminiService,
        weatherService,
      ),
    ),
  ],
  child: MaterialApp(...),
)
```

### 2. Sử dụng trong Widgets

```dart
// Cách 1: Consumer - Rebuild widget khi state thay đổi
Consumer<WardrobeProvider>(
  builder: (context, wardrobe, child) {
    return ListView.builder(
      itemCount: wardrobe.items.length,
      itemBuilder: (_, i) => ClothingCard(item: wardrobe.items[i]),
    );
  },
)

// Cách 2: context.watch - Rebuild toàn bộ widget
Widget build(BuildContext context) {
  final wardrobe = context.watch<WardrobeProvider>();
  return Text('${wardrobe.items.length} items');
}

// Cách 3: context.read - Chỉ đọc, không rebuild
void _addItem() {
  context.read<WardrobeProvider>().addItem(newItem);
}
```

---

## 🔐 Authentication Flow

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│ LoginScreen  │────▶│ AuthProvider │────▶│FirebaseService│
└──────────────┘     └──────────────┘     └──────────────┘
       │                    │                    │
       │  1. User tap      │                    │
       │  "Sign in"        │                    │
       │                    │                    │
       │                    │  2. signInWithGoogle()
       │                    │ ──────────────────▶│
       │                    │                    │
       │                    │                    │ 3. Firebase Auth
       │                    │                    │    Google Sign In
       │                    │                    │
       │                    │  4. Return User   │
       │                    │◀──────────────────│
       │                    │                    │
       │  5. notifyListeners()                  │
       │     status = authenticated             │
       │                    │                    │
       ▼                    ▼                    │
┌──────────────┐                                │
│  HomeScreen  │  (AuthWrapper tự động navigate)│
└──────────────┘                                │
```

---

## 📦 Data Model Relationships

```
User (Firebase Auth)
  │
  └──▶ ClothingItem (nhiều items)
         │
         ├── id: String
         ├── userId: String ◀── Link với User
         ├── imageBase64: String (compressed, auto-encoded)
         ├── type: ClothingType (enum)
         ├── color: String
         ├── styles: List<ClothingStyle>
         ├── seasons: List<Season>
         └── wearCount: int

Outfit (Generated by AI)
  │
  ├── items: List<ClothingItem> ◀── Reference
  ├── occasion: String
  ├── weather: Weather
  ├── reasoning: String (AI explanation)
  └── score: int (1-100)

ColorHarmonyResult (AI Analysis)
  │
  ├── item1: ClothingItem
  ├── item2: ClothingItem
  ├── score: int (1-100)
  ├── analysis: String
  └── suggestions: List<String>
```

---

## 🖥️ Screen Navigation

```
                    ┌─────────────────┐
                    │  LoginScreen    │
                    └────────┬────────┘
                             │ (authenticated)
                             ▼
                    ┌─────────────────┐
          ┌────────│   HomeScreen    │────────┐
          │        │  (Bottom Nav)   │        │
          │        └────────┬────────┘        │
          │                 │                 │
          ▼                 ▼                 ▼
   ┌──────────┐     ┌──────────┐      ┌──────────┐
   │  Home    │     │ Wardrobe │      │  Outfit  │
   │   Tab    │     │   Tab    │      │   Tab    │
   └────┬─────┘     └────┬─────┘      └────┬─────┘
        │                │                 │
        │                ▼                 │
        │        ┌──────────────┐          │
        │        │ItemDetailScreen│         │
        │        └──────────────┘          │
        │                                  │
        ▼                                  ▼
┌───────────────┐                  ┌────────────────┐
│ AddItemScreen │                  │ColorHarmonyScreen│
└───────────────┘                  └────────────────┘
        │
        │ (from Profile)
        ▼
┌───────────────────┐
│WardrobeCleanupScreen│
└───────────────────┘
```

---

## 🔑 Các file quan trọng cần hiểu

| Thứ tự | File | Lý do |
|--------|------|-------|
| 1 | `main.dart` | Entry point, khởi tạo services & providers |
| 2 | `wardrobe_provider.dart` | Core logic - quản lý state chính |
| 3 | `gemini_service.dart` | Tích hợp AI - tính năng chính |
| 4 | `clothing_item.dart` | Data model chính |
| 5 | `home_screen.dart` | Navigation container |
| 6 | `firebase_service.dart` | Database operations |

---

## 📚 Tài liệu liên quan

- [MODELS.md](./MODELS.md) - Chi tiết về Data Models
- [PROVIDERS.md](./PROVIDERS.md) - Chi tiết về State Management
- [SERVICES.md](./SERVICES.md) - Chi tiết về Services
- [SCREENS.md](./SCREENS.md) - Chi tiết về các màn hình
- [WIDGETS.md](./WIDGETS.md) - Chi tiết về Widgets
- [THEME.md](./THEME.md) - Chi tiết về Theme/UI
- [AI_INTEGRATION.md](./AI_INTEGRATION.md) - Chi tiết về tích hợp AI

---

*Tài liệu được tạo: 30/11/2025*
