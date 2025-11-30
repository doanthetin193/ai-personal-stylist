# Screens - UI Screens Documentation

> **File 5/8** - Tài liệu chi tiết về các màn hình trong app

## 📁 Vị trí: `lib/screens/`

```
lib/screens/
├── login_screen.dart           # Màn hình đăng nhập
├── home_screen.dart            # Màn hình chính + Bottom Navigation
├── wardrobe_screen.dart        # Quản lý tủ đồ
├── add_item_screen.dart        # Thêm quần áo mới + AI analysis
├── item_detail_screen.dart     # Chi tiết item
├── outfit_suggest_screen.dart  # Gợi ý outfit từ AI
├── color_harmony_screen.dart   # Chấm điểm phối màu
├── wardrobe_cleanup_screen.dart # Gợi ý dọn tủ
└── profile_screen.dart         # Hồ sơ người dùng
```

---

## 1. Navigation Flow

```
┌──────────────────────────────────────────────────────────────────────┐
│                        NAVIGATION FLOW                                │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│   ┌──────────────┐                                                    │
│   │ LoginScreen  │ ◄─── User chưa đăng nhập                           │
│   └──────┬───────┘                                                    │
│          │ signIn success                                             │
│          ▼                                                            │
│   ┌──────────────────────────────────────────────────────────┐       │
│   │                    HomeScreen                             │       │
│   │  ┌─────────────────────────────────────────────────────┐ │       │
│   │  │              Bottom Navigation Bar                   │ │       │
│   │  │  [Home] [Tủ đồ] [+Add] [Phối đồ] [Profile]          │ │       │
│   │  └─────────────────────────────────────────────────────┘ │       │
│   │                                                          │       │
│   │  Tab 0: _HomeTab (Overview)                              │       │
│   │  Tab 1: WardrobeScreen                                   │       │
│   │  Tab 2: OutfitSuggestScreen                              │       │
│   │  Tab 3: ProfileScreen                                    │       │
│   └─────────────────────┬────────────────────────────────────┘       │
│                         │                                             │
│         ┌───────────────┼───────────────┬───────────────┐            │
│         ▼               ▼               ▼               ▼            │
│   ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────────┐    │
│   │AddItem    │  │ItemDetail │  │ColorHarmony│  │WardrobeCleanup│    │
│   │Screen     │  │Screen     │  │Screen     │  │Screen         │    │
│   └───────────┘  └───────────┘  └───────────┘  └───────────────┘    │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 2. LoginScreen (`login_screen.dart`)

### 2.1 Mục đích

Màn hình đăng nhập với nhiều phương thức auth.

### 2.2 UI Components

```
┌─────────────────────────────────────────┐
│          GRADIENT BACKGROUND            │
│      (Purple → Pink → Orange)           │
├─────────────────────────────────────────┤
│                                         │
│            ┌─────────────┐              │
│            │    LOGO     │              │
│            │  checkroom  │              │
│            └─────────────┘              │
│                                         │
│        "AI Personal Stylist"            │
│      "Phong cách thời trang..."         │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │    🔵 Đăng nhập với Google      │   │
│   └─────────────────────────────────┘   │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │    ✉️ Đăng nhập với Email       │   │
│   └─────────────────────────────────┘   │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │    👤 Dùng thử không cần TK     │   │
│   └─────────────────────────────────┘   │
│                                         │
│         © 2025 AI Personal Stylist      │
└─────────────────────────────────────────┘
```

### 2.3 State

```dart
bool _showEmailForm = false;      // Hiện form email?
bool _isRegisterMode = false;     // Đăng ký hay đăng nhập?
bool _obscurePassword = true;     // Ẩn password?
TextEditingController _emailController;
TextEditingController _passwordController;
GlobalKey<FormState> _formKey;
```

### 2.4 Auth Methods

| Button | Method | Flow |
|--------|--------|------|
| Google | `signInWithGoogle()` | Popup chọn account → Home |
| Email | `signInWithEmail()` / `registerWithEmail()` | Form validation → Auth → Home |
| Anonymous | `signInAnonymously()` | Direct → Home (demo mode) |

### 2.5 Features

- **Gradient Background**: Purple → Pink → Orange
- **Form Validation**: Email format, password length
- **Error Display**: Vietnamese error messages
- **Mode Toggle**: Đăng nhập ↔ Đăng ký

---

## 3. HomeScreen (`home_screen.dart`)

### 3.1 Mục đích

Container chính với Bottom Navigation và 4 tabs.

### 3.2 Structure

```dart
Scaffold(
  body: IndexedStack(
    index: _currentIndex,
    children: [
      _HomeTab(),           // Tab 0: Overview
      WardrobeScreen(),     // Tab 1: Tủ đồ
      OutfitSuggestScreen(), // Tab 2: Phối đồ
      ProfileScreen(),      // Tab 3: Profile
    ],
  ),
  bottomNavigationBar: CustomBottomNav(),
)
```

### 3.3 Bottom Navigation

```
┌────────────────────────────────────────────────────┐
│  [Home]  [Tủ đồ]  [+ADD]  [Phối đồ]  [Profile]    │
│    0        1       ★        2          3          │
└────────────────────────────────────────────────────┘
                      ▲
            Floating Add Button (mở AddItemScreen)
```

### 3.4 _HomeTab - Overview

**UI Sections:**

1. **Premium Header**
   - Avatar với gradient border
   - Greeting text
   - Settings icon

2. **Weather Card**
   - Temperature, city name
   - Weather icon và description
   - AI suggestion text

3. **Quick Actions Grid**
   ```
   ┌──────────────┬──────────────┐
   │  Tủ đồ       │  Phối đồ     │
   │  (Wardrobe)  │  (Outfit)    │
   ├──────────────┼──────────────┤
   │  Hợp màu     │  Dọn tủ      │
   │  (Color)     │  (Cleanup)   │
   └──────────────┴──────────────┘
   ```

4. **Recent Items Section**
   - "Đồ mới thêm" với "Xem tất cả"
   - Horizontal scroll list (3 items)

### 3.5 Data Loading

```dart
@override
void initState() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    wardrobeProvider.loadItems();
    wardrobeProvider.loadWeather();
  });
}
```

---

## 4. WardrobeScreen (`wardrobe_screen.dart`)

### 4.1 Mục đích

Quản lý và hiển thị tất cả quần áo trong tủ đồ.

### 4.2 UI Components

```
┌─────────────────────────────────────────┐
│  PREMIUM HEADER                         │
│  [Icon] Tủ đồ của tôi                   │
│         Quản lý trang phục của bạn      │
├─────────────────────────────────────────┤
│  CATEGORY FILTER (Horizontal Scroll)    │
│  [Tất cả] [Áo] [Quần] [Khoác] [Váy]... │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────┐  ┌─────────┐               │
│  │  Item   │  │  Item   │               │
│  │  Card   │  │  Card   │   GridView    │
│  └─────────┘  └─────────┘   2 columns   │
│  ┌─────────┐  ┌─────────┐               │
│  │  Item   │  │  Item   │               │
│  │  Card   │  │  Card   │               │
│  └─────────┘  └─────────┘               │
│                                         │
└─────────────────────────────────────────┘
```

### 4.3 Category Filter

```dart
final List<Map<String, dynamic>> _categories = [
  {'id': 'all', 'name': 'Tất cả', 'icon': Icons.grid_view},
  {'id': 'top', 'name': 'Áo', 'icon': Icons.checkroom},
  {'id': 'bottom', 'name': 'Quần', 'icon': Icons.straighten},
  {'id': 'outerwear', 'name': 'Khoác', 'icon': Icons.dry_cleaning},
  {'id': 'dress', 'name': 'Váy', 'icon': Icons.dry},
  {'id': 'footwear', 'name': 'Giày', 'icon': Icons.ice_skating},
  {'id': 'bag', 'name': 'Túi', 'icon': Icons.shopping_bag},
  {'id': 'hat', 'name': 'Mũ', 'icon': Icons.face_retouching_natural},
  {'id': 'accessory', 'name': 'Phụ kiện', 'icon': Icons.watch},
];
```

### 4.4 Item Actions

- **Tap item** → Navigate to `ItemDetailScreen`
- **Long press** → Show options (Edit, Delete, Favorite)

### 4.5 Empty State

Hiện khi tủ đồ trống với button "Thêm đồ đầu tiên".

---

## 5. AddItemScreen (`add_item_screen.dart`)

### 5.1 Mục đích

Thêm quần áo mới với AI analysis.

### 5.2 Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      ADD ITEM FLOW                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Step 1: Pick Image                                         │
│  ┌─────────────────┐                                        │
│  │   Chọn ảnh từ   │ → ImagePicker (Gallery/Camera)         │
│  │    thư viện     │                                        │
│  └─────────────────┘                                        │
│           │                                                 │
│           ▼                                                 │
│  Step 2: AI Analysis                                        │
│  ┌─────────────────┐                                        │
│  │  Đang phân tích │ → GeminiService.analyzeClothingImage() │
│  │      ...        │                                        │
│  └─────────────────┘                                        │
│           │                                                 │
│           ▼                                                 │
│  Step 3: Review & Edit                                      │
│  ┌─────────────────┐                                        │
│  │ Kết quả AI:     │                                        │
│  │ - Type: shirt   │ ← User có thể chỉnh sửa                │
│  │ - Color: blue   │                                        │
│  │ - Style: casual │                                        │
│  └─────────────────┘                                        │
│           │                                                 │
│           ▼                                                 │
│  Step 4: Save                                               │
│  ┌─────────────────┐                                        │
│  │    Lưu vào      │ → WardrobeProvider.addItemFromBytes()  │
│  │    tủ đồ        │                                        │
│  └─────────────────┘                                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 5.3 State

```dart
XFile? _pickedFile;              // File đã chọn
Uint8List? _imageBytes;          // Bytes của ảnh
bool _isAnalyzing = false;       // Đang phân tích?
bool _isSaving = false;          // Đang lưu?
Map<String, dynamic>? _analysisResult;  // Kết quả AI

// Editable fields (user có thể sửa)
ClothingType? _selectedType;
String? _selectedColor;
String? _selectedMaterial;
List<ClothingStyle> _selectedStyles = [];
List<Season> _selectedSeasons = [];
```

### 5.4 Editable Fields

Sau khi AI phân tích, user có thể chỉnh sửa:
- **Type**: Dropdown với tất cả ClothingType
- **Color**: TextField
- **Material**: Dropdown
- **Styles**: Multi-select chips
- **Seasons**: Multi-select chips

---

## 6. ItemDetailScreen (`item_detail_screen.dart`)

### 6.1 Mục đích

Hiển thị chi tiết một item quần áo.

### 6.2 UI Components

```
┌─────────────────────────────────────────┐
│  SLIVER APP BAR (Expandable)            │
│  ┌─────────────────────────────────┐    │
│  │                                 │    │
│  │         ITEM IMAGE              │    │
│  │       (Hero Animation)          │    │
│  │                                 │    │
│  │  [←Back]              [❤️][⋮]  │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│  ITEM INFO                              │
│                                         │
│  Type: Áo sơ mi                         │
│  Color: Xanh navy                       │
│  Material: Cotton                       │
│                                         │
│  Styles: [Casual] [Formal]              │
│  Seasons: [Xuân] [Hè] [Thu]             │
│                                         │
│  ─────────────────────────────────      │
│  Thống kê:                              │
│  • Số lần mặc: 5                        │
│  • Lần mặc cuối: 25/11/2025             │
│  • Ngày thêm: 01/11/2025                │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │      Đánh dấu đã mặc hôm nay    │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

### 6.3 Actions

| Action | Method |
|--------|--------|
| Toggle Favorite | `wardrobeProvider.toggleFavorite(item)` |
| Mark as Worn | `wardrobeProvider.markAsWorn(item)` |
| Edit | Navigate to edit screen |
| Delete | Confirm dialog → `wardrobeProvider.deleteItem()` |

### 6.4 Hero Animation

```dart
Hero(
  tag: 'item-${item.id}',
  child: ClothingImage(item: item),
)
```

Tạo smooth transition từ WardrobeScreen → ItemDetailScreen.

---

## 7. OutfitSuggestScreen (`outfit_suggest_screen.dart`)

### 7.1 Mục đích

AI gợi ý outfit dựa trên thời tiết và dịp.

### 7.2 UI Flow

```
┌─────────────────────────────────────────┐
│  PREMIUM HEADER                         │
│  [Icon] Gợi ý Outfit                    │
│         AI phân tích và gợi ý cho bạn   │
├─────────────────────────────────────────┤
│  WEATHER CARD                           │
│  🌤️ 28°C - Quy Nhon                    │
├─────────────────────────────────────────┤
│  STYLE PREFERENCE                       │
│  [Đồ rộng] [Vừa vặn] [Ôm body]         │
├─────────────────────────────────────────┤
│  OCCASION SELECTOR                      │
│  [Hàng ngày] [Đi làm] [Hẹn hò]...      │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────┐    │
│  │        TẠO OUTFIT               │    │
│  └─────────────────────────────────┘    │
│                                         │
│  OUTFIT RESULT (sau khi generate)       │
│  ┌─────────────────────────────────┐    │
│  │  OutfitCard                      │    │
│  │  - Top, Bottom, Footwear...     │    │
│  │  - Lý do gợi ý                  │    │
│  │  - Color score                  │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

### 7.3 Occasions

```dart
// Từ constants.dart
[
  {'id': 'daily', 'name': 'Hàng ngày', 'icon': '☀️'},
  {'id': 'work', 'name': 'Đi làm', 'icon': '💼'},
  {'id': 'date', 'name': 'Hẹn hò', 'icon': '💕'},
  {'id': 'party', 'name': 'Tiệc tùng', 'icon': '🎉'},
  {'id': 'sport', 'name': 'Thể thao', 'icon': '🏃'},
  {'id': 'travel', 'name': 'Du lịch', 'icon': '✈️'},
  {'id': 'formal', 'name': 'Sự kiện trang trọng', 'icon': '🎩'},
  {'id': 'beach', 'name': 'Đi biển', 'icon': '🏖️'},
  {'id': 'casual', 'name': 'Cafe/Đi chơi', 'icon': '☕'},
]
```

### 7.4 Generation Flow

```dart
Future<void> _generateOutfit() async {
  final outfit = await wardrobeProvider.suggestOutfit(
    _selectedOccasion ?? _customOccasion!
  );
  // outfit chứa: top, bottom, outerwear, footwear, accessories, reason
}
```

---

## 8. ColorHarmonyScreen (`color_harmony_screen.dart`)

### 8.1 Mục đích

Chấm điểm phối màu giữa 2 items.

### 8.2 UI Flow

```
┌─────────────────────────────────────────┐
│  APP BAR: Chấm điểm hợp màu             │
├─────────────────────────────────────────┤
│  INSTRUCTIONS                           │
│  "Chọn 2 món đồ để AI đánh giá..."     │
├─────────────────────────────────────────┤
│  ITEM SELECTORS                         │
│  ┌──────────────┐  ┌──────────────┐     │
│  │   Item 1     │  │   Item 2     │     │
│  │   [Select]   │  │   [Select]   │     │
│  └──────────────┘  └──────────────┘     │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────┐    │
│  │         ĐÁNH GIÁ                │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│  RESULT (sau khi evaluate)              │
│  ┌─────────────────────────────────┐    │
│  │  Score: 85/100 ⭐⭐⭐⭐            │    │
│  │  Vibe: "Classic & Elegant"      │    │
│  │  Reason: "Màu navy và be..."    │    │
│  │  Tips: [Tip 1] [Tip 2]          │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

### 8.3 State

```dart
ClothingItem? _item1;
ClothingItem? _item2;
bool _isEvaluating = false;
ColorHarmonyResult? _result;
```

### 8.4 Item Selector

Mở bottom sheet với grid các items để chọn.

---

## 9. WardrobeCleanupScreen (`wardrobe_cleanup_screen.dart`)

### 9.1 Mục đích

AI gợi ý dọn dẹp tủ đồ - tìm đồ trùng, không hợp style.

### 9.2 UI Flow

```
┌─────────────────────────────────────────┐
│  APP BAR: Dọn tủ đồ        [Xóa (n)] 🗑️│
├─────────────────────────────────────────┤
│  INFO CARD                              │
│  "AI sẽ phân tích và gợi ý..."         │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────┐    │
│  │    PHÂN TÍCH TỦ ĐỒ             │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│  RESULTS (sau khi analyze)              │
│                                         │
│  📋 Đồ trùng lặp                        │
│  ┌─────────────────────────────────┐    │
│  │ [✓] Item1 + Item2               │    │
│  │     "2 áo sơ mi xanh tương tự"  │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ⚠️ Không hợp style                     │
│  ┌─────────────────────────────────┐    │
│  │ [✓] Item3                       │    │
│  │     "Không match với tủ đồ"     │    │
│  └─────────────────────────────────┘    │
│                                         │
│  💡 Gợi ý chung                         │
│  • "Nên bổ sung thêm..."               │
│  • "Tủ đồ thiên về casual..."          │
└─────────────────────────────────────────┘
```

### 9.3 State

```dart
bool _isAnalyzing = false;
Map<String, dynamic>? _suggestions;  // AI result
Set<String> _selectedForRemoval = {};  // Items được chọn để xóa
```

### 9.4 Bulk Delete

```dart
// App bar action khi có items được chọn
TextButton.icon(
  onPressed: _confirmRemoval,
  label: Text('Xóa (${_selectedForRemoval.length})'),
)
```

---

## 10. ProfileScreen (`profile_screen.dart`)

### 10.1 Mục đích

Hiển thị thông tin user và settings.

### 10.2 UI Components

```
┌─────────────────────────────────────────┐
│  HEADER (Gradient)                      │
│  ┌─────────────────────────────────┐    │
│  │         AVATAR                  │    │
│  │     John Doe                    │    │
│  │   john@email.com               │    │
│  │                                 │    │
│  │  [Tổng đồ: 25] [Loại: 8] [❤️: 5]│    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│  MENU OPTIONS                           │
│                                         │
│  📊 Thống kê tủ đồ                      │
│  🎨 Chấm điểm hợp màu                   │
│  🗑️ Dọn tủ đồ                           │
│  ⚙️ Cài đặt                             │
│  ℹ️ Về ứng dụng                         │
│                                         │
│  ─────────────────────────────────      │
│                                         │
│  🚪 Đăng xuất                           │
│                                         │
│         © 2025 AI Personal Stylist      │
└─────────────────────────────────────────┘
```

### 10.3 Stats Display

```dart
Row(
  children: [
    _buildStat(label: 'Tổng đồ', value: allItems.length),
    _buildStat(label: 'Loại đồ', value: itemsByType.length),
    _buildStat(label: 'Yêu thích', value: favorites.length),
  ],
)
```

### 10.4 Menu Options

| Option | Navigation/Action |
|--------|-------------------|
| Thống kê tủ đồ | Show stats dialog |
| Chấm điểm hợp màu | → ColorHarmonyScreen |
| Dọn tủ đồ | → WardrobeCleanupScreen |
| Cài đặt | → Settings dialog |
| Về ứng dụng | → About dialog |
| Đăng xuất | `authProvider.signOut()` |

---

## 11. Common Patterns

### 11.1 Gradient Backgrounds

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFCE7F3),  // Light pink
        AppTheme.backgroundColor,
      ],
      stops: [0.0, 0.3],
    ),
  ),
)
```

### 11.2 Premium Headers

```dart
Container(
  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
  child: Row(
    children: [
      // Gradient icon container
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [...],
        ),
        child: Icon(...),
      ),
      const SizedBox(width: 16),
      // Title + subtitle
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Title', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text('Subtitle', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    ],
  ),
)
```

### 11.3 Consumer Pattern

```dart
Consumer<WardrobeProvider>(
  builder: (context, wardrobe, _) {
    if (wardrobe.isLoading) return LoadingWidget();
    if (wardrobe.items.isEmpty) return EmptyState();
    return ItemsList(items: wardrobe.items);
  },
)
```

---

## 📝 Summary

| Screen | Lines | Purpose |
|--------|-------|---------|
| `login_screen.dart` | ~438 | Authentication |
| `home_screen.dart` | ~629 | Main container + Navigation |
| `wardrobe_screen.dart` | ~462 | Wardrobe management |
| `add_item_screen.dart` | ~754 | Add item + AI analysis |
| `item_detail_screen.dart` | ~414 | Item details |
| `outfit_suggest_screen.dart` | ~484 | AI outfit suggestion |
| `color_harmony_screen.dart` | ~539 | Color matching score |
| `wardrobe_cleanup_screen.dart` | ~721 | Cleanup suggestions |
| `profile_screen.dart` | ~765 | User profile |

---

**Tiếp theo:** [WIDGETS.md](./WIDGETS.md) - Reusable UI Components
