# Widgets - Reusable UI Components Documentation

> **File 6/8** - Tài liệu chi tiết về các Widgets tái sử dụng

## 📁 Vị trí: `lib/widgets/`

```
lib/widgets/
├── clothing_card.dart     # ClothingImage, ClothingCard, ClothingCardMini
├── outfit_card.dart       # OutfitCard
├── common_widgets.dart    # WeatherWidget, OccasionChip, EmptyState, ScoreDisplay
└── loading_widgets.dart   # Shimmer loading widgets, AI animation
```

---

## 1. Clothing Widgets (`clothing_card.dart`)

### 1.1 ClothingImage

**Widget hiển thị ảnh từ Base64 hoặc URL.**

```dart
class ClothingImage extends StatelessWidget {
  final ClothingItem item;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
}
```

#### Logic hiển thị:

```
┌─────────────────────────────────────────────────────────┐
│                  ClothingImage Logic                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  item.imageBase64 != null?                              │
│     │                                                   │
│     ├── YES → base64Decode() → Image.memory()           │
│     │                                                   │
│     └── NO → item.imageUrl != null?                     │
│               │                                         │
│               ├── YES → CachedNetworkImage()            │
│               │                                         │
│               └── NO → errorWidget (placeholder)        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

#### Usage:

```dart
ClothingImage(
  item: clothingItem,
  fit: BoxFit.cover,
  placeholder: ShimmerWidget(),
  errorWidget: Icon(Icons.image_not_supported),
)
```

---

### 1.2 ClothingCard

**Card hiển thị item quần áo với gradient overlay.**

```dart
class ClothingCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onFavorite;
  final bool showFavorite;    // Hiện nút favorite?
  final bool isSelected;      // Đang được chọn?
}
```

#### UI Structure:

```
┌─────────────────────────────────────┐
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │        ITEM IMAGE           │   │
│  │     (ClothingImage)         │   │
│  │                             │   │
│  │                     [❤️]    │ ← Favorite button (top-right)
│  │                             │   │
│  │  ╔═══════════════════════╗  │   │
│  │  ║ Type: Áo sơ mi       ║  │ ← Gradient overlay (bottom)
│  │  ║ Color: Xanh navy     ║  │   │
│  │  ╚═══════════════════════╝  │   │
│  └─────────────────────────────┘   │
│                                     │
│  [✓] ← Selection indicator          │
│       (top-left, when isSelected)   │
└─────────────────────────────────────┘
```

#### Features:

| Feature | Description |
|---------|-------------|
| **Gradient Overlay** | Bottom gradient với type + color |
| **Favorite Button** | Toggle với animation |
| **Selection State** | Border highlight + check icon |
| **Shimmer Loading** | Placeholder khi load ảnh |

#### Usage:

```dart
ClothingCard(
  item: item,
  onTap: () => navigateToDetail(item),
  onLongPress: () => showOptions(item),
  onFavorite: () => toggleFavorite(item),
  showFavorite: true,
  isSelected: selectedItems.contains(item.id),
)
```

---

### 1.3 ClothingCardMini

**Card nhỏ gọn cho outfit display.**

```dart
class ClothingCardMini extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback? onTap;
  final double size;  // Default: 80
}
```

#### UI:

```
┌──────────┐
│          │
│   IMG    │  80x80 (default)
│          │
└──────────┘
```

#### Usage:

```dart
ClothingCardMini(
  item: item,
  size: 70,
  onTap: () => showItemDetail(item),
)
```

---

## 2. Outfit Widgets (`outfit_card.dart`)

### 2.1 OutfitCard

**Card hiển thị một outfit được AI gợi ý.**

```dart
class OutfitCard extends StatelessWidget {
  final Outfit outfit;
  final VoidCallback? onTap;
  final VoidCallback? onWear;
  final bool showActions;  // Hiện button "Mặc hôm nay"?
}
```

#### UI Structure:

```
┌─────────────────────────────────────────────┐
│  HEADER                                     │
│  [Occasion Tag]                    [Score]  │
│   "Đi làm"                          85 🎨   │
├─────────────────────────────────────────────┤
│  ITEMS GRID (Wrap)                          │
│                                             │
│  ┌────┐  ┌────┐  ┌────┐  ┌────┐            │
│  │ Áo │  │Quần│  │Khoác│ │Giày│            │
│  └────┘  └────┘  └────┘  └────┘            │
│   Áo     Quần    Khoác   Giày              │
├─────────────────────────────────────────────┤
│  REASON                                     │
│  ┌─────────────────────────────────────┐   │
│  │ ✨ Lý do AI gợi ý outfit này...     │   │
│  └─────────────────────────────────────┘   │
├─────────────────────────────────────────────┤
│  ACTION (optional)                          │
│  ┌─────────────────────────────────────┐   │
│  │         MẶC HÔM NAY                 │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

#### Score Color Logic:

```dart
Color _getScoreColor(int score) {
  if (score >= 80) return AppTheme.successColor;   // Green
  if (score >= 60) return AppTheme.accentColor;    // Teal
  if (score >= 40) return AppTheme.warningColor;   // Orange
  return AppTheme.errorColor;                       // Red
}
```

#### Items Display:

```dart
Widget _buildItemWithLabel(ClothingItem item, String label) {
  return Column(
    children: [
      ClothingCardMini(item: item, size: 70),
      Text(label),  // "Áo", "Quần", "Khoác", "Giày", "Phụ kiện"
    ],
  );
}
```

---

## 3. Common Widgets (`common_widgets.dart`)

### 3.1 WeatherWidget

**Hiển thị thông tin thời tiết.**

```dart
class WeatherWidget extends StatelessWidget {
  final WeatherInfo weather;
  final bool compact;  // Compact mode hay full mode?
}
```

#### Compact Mode:

```
┌──────────────────────────────┐
│  🌤️  28°C  Quy Nhon         │
└──────────────────────────────┘
```

#### Full Mode:

```
┌─────────────────────────────────────────┐
│  GRADIENT BACKGROUND                    │
│                                         │
│  🌤️       28°C                         │
│           Quy Nhon                      │
│                                         │
│  [🌡️ Cảm giác 30°C] [💧 70%] [💨 3m/s] │
│                                         │
│  "Nên chọn đồ thoáng mát"               │
└─────────────────────────────────────────┘
```

#### Weather Color Logic:

```dart
Color _getWeatherColor() {
  final temp = weather.temperature;
  if (temp < 15) return Color(0xFF5B86E5);  // Cold - Blue
  if (temp < 22) return Color(0xFF36D1DC);  // Cool - Cyan
  if (temp < 28) return Color(0xFF56CCF2);  // Warm - Light Blue
  if (temp < 35) return Color(0xFFF2994A);  // Hot - Orange
  return Color(0xFFEB5757);                  // Very Hot - Red
}
```

---

### 3.2 OccasionChip

**Chip để chọn occasion/dịp.**

```dart
class OccasionChip extends StatelessWidget {
  final String id;
  final String name;
  final String icon;       // Emoji icon
  final bool isSelected;
  final VoidCallback? onTap;
}
```

#### UI States:

```
Unselected:                    Selected:
┌──────────────────┐           ┌──────────────────┐
│  ☀️  Hàng ngày   │           │  ☀️  Hàng ngày   │ ← Gradient + Shadow
└──────────────────┘           └──────────────────┘
    Border: grey                   Background: primary
    Text: textPrimary              Text: white + bold
```

#### Usage:

```dart
OccasionChip(
  id: 'work',
  name: 'Đi làm',
  icon: '💼',
  isSelected: selectedOccasion == 'work',
  onTap: () => selectOccasion('work'),
)
```

---

### 3.3 EmptyState

**Widget hiển thị khi không có data.**

```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;  // Button action
}
```

#### UI:

```
┌─────────────────────────────────────────┐
│                                         │
│              ┌─────────┐                │
│              │  ICON   │                │
│              │   📦    │                │
│              └─────────┘                │
│                                         │
│         "Tủ đồ trống"                   │
│   "Thêm quần áo để bắt đầu"             │
│                                         │
│        [+ Thêm đồ mới]                  │
│                                         │
└─────────────────────────────────────────┘
```

#### Usage:

```dart
EmptyState(
  icon: Icons.checkroom,
  title: 'Tủ đồ trống',
  subtitle: 'Thêm quần áo để bắt đầu',
  action: ElevatedButton(
    onPressed: () => navigateToAddItem(),
    child: Text('+ Thêm đồ mới'),
  ),
)
```

---

### 3.4 ScoreDisplay

**Circular progress hiển thị điểm.**

```dart
class ScoreDisplay extends StatelessWidget {
  final int score;      // 0-100
  final String? label;
  final double size;    // Default: 80
}
```

#### UI:

```
      ╭──────────╮
     ╱            ╲
    │     85      │ ← Score number
    │             │
     ╲            ╱
      ╰──────────╯ ← Circular progress
      
      "Điểm phối màu" ← Label (optional)
```

#### Score Color:

```dart
Color _getScoreColor() {
  if (score >= 80) return AppTheme.successColor;   // Green
  if (score >= 60) return AppTheme.accentColor;    // Teal
  if (score >= 40) return AppTheme.warningColor;   // Orange
  return AppTheme.errorColor;                       // Red
}
```

---

## 4. Loading Widgets (`loading_widgets.dart`)

### 4.1 ShimmerCard

**Shimmer placeholder đơn lẻ.**

```dart
class ShimmerCard extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;  // Default: 16
}
```

#### Visual:

```
┌─────────────────┐
│ ░░░░░░░░░░░░░░░ │ ← Shimmer animation
│ ░░░░░░░░░░░░░░░ │    (light moving across)
│ ░░░░░░░░░░░░░░░ │
└─────────────────┘
```

---

### 4.2 ClothingGridShimmer

**Shimmer cho clothing grid.**

```dart
class ClothingGridShimmer extends StatelessWidget {
  final int itemCount;       // Default: 6
  final int crossAxisCount;  // Default: 2
}
```

#### Visual:

```
┌─────────┐  ┌─────────┐
│ ░░░░░░░ │  │ ░░░░░░░ │
│ ░░░░░░░ │  │ ░░░░░░░ │
└─────────┘  └─────────┘
┌─────────┐  ┌─────────┐
│ ░░░░░░░ │  │ ░░░░░░░ │
│ ░░░░░░░ │  │ ░░░░░░░ │
└─────────┘  └─────────┘
```

---

### 4.3 OutfitShimmer

**Shimmer cho outfit card loading.**

```dart
class OutfitShimmer extends StatelessWidget
```

#### Visual:

```
┌─────────────────────────────────────────┐
│  [░░░░░░]                    [░░░░]     │ ← Header
├─────────────────────────────────────────┤
│  ┌───┐  ┌───┐  ┌───┐  ┌───┐            │
│  │░░░│  │░░░│  │░░░│  │░░░│            │ ← Items
│  └───┘  └───┘  └───┘  └───┘            │
│  [░░]   [░░]   [░░]   [░░]             │
├─────────────────────────────────────────┤
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░       │ ← Reason
└─────────────────────────────────────────┘
```

---

### 4.4 AIAnalyzingAnimation

**Animation khi AI đang phân tích.**

```dart
class AIAnalyzingAnimation extends StatefulWidget {
  final String message;  // Default: 'AI đang phân tích...'
}
```

#### Visual:

```
┌─────────────────────────────────────────┐
│                                         │
│            ╭──────────╮                 │
│            │   ✨     │ ← Rotating icon │
│            │ gradient │                 │
│            ╰──────────╯                 │
│                                         │
│       "AI đang phân tích..."            │
│                                         │
│       ════════════════════              │ ← Linear progress
│                                         │
└─────────────────────────────────────────┘
```

#### Animation Logic:

```dart
AnimationController _controller = AnimationController(
  duration: Duration(seconds: 2),
)..repeat();

// Icon xoay 360°
Transform.rotate(
  angle: _controller.value * 2 * 3.14159,
  child: gradientIcon,
)
```

---

## 5. Widget Dependency Tree

```
┌─────────────────────────────────────────────────────────────────┐
│                    WIDGET DEPENDENCIES                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ClothingCard ──────► ClothingImage                             │
│       │                    │                                    │
│       │                    ├── Image.memory (Base64)            │
│       │                    └── CachedNetworkImage (URL)         │
│       │                                                         │
│       └──────► ShimmerCard (placeholder)                        │
│                                                                 │
│  ClothingCardMini ──► ClothingImage                             │
│                                                                 │
│  OutfitCard ─────────► ClothingCardMini                         │
│                            │                                    │
│                            └──► ClothingImage                   │
│                                                                 │
│  WeatherWidget ──────► CachedNetworkImage (weather icon)        │
│                                                                 │
│  Loading Widgets:                                               │
│  ├── ShimmerCard (base)                                         │
│  ├── ClothingGridShimmer ──► ShimmerCard                        │
│  ├── OutfitShimmer ──► Shimmer.fromColors                       │
│  └── AIAnalyzingAnimation ──► AnimationController               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 6. Usage Examples

### 6.1 Wardrobe Grid

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.75,
  ),
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    return ClothingCard(
      item: item,
      onTap: () => navigateToDetail(item),
      onFavorite: () => toggleFavorite(item),
    );
  },
)
```

### 6.2 Loading State

```dart
if (isLoading) {
  return ClothingGridShimmer(itemCount: 6);
}
if (items.isEmpty) {
  return EmptyState(
    icon: Icons.checkroom,
    title: 'Chưa có đồ',
  );
}
return ItemsGrid(items: items);
```

### 6.3 Outfit Display

```dart
if (isSuggestingOutfit) {
  return OutfitShimmer();
}
if (currentOutfit != null) {
  return OutfitCard(
    outfit: currentOutfit,
    onWear: () => markAllAsWorn(currentOutfit),
  );
}
```

### 6.4 AI Analysis

```dart
if (isAnalyzing) {
  return AIAnalyzingAnimation(
    message: 'AI đang phân tích ảnh...',
  );
}
```

---

## 📝 Summary

| Widget | File | Purpose |
|--------|------|---------|
| `ClothingImage` | clothing_card.dart | Hiển thị ảnh Base64/URL |
| `ClothingCard` | clothing_card.dart | Card item với gradient |
| `ClothingCardMini` | clothing_card.dart | Card nhỏ cho outfit |
| `OutfitCard` | outfit_card.dart | Hiển thị outfit suggestion |
| `WeatherWidget` | common_widgets.dart | Thời tiết compact/full |
| `OccasionChip` | common_widgets.dart | Chip chọn occasion |
| `EmptyState` | common_widgets.dart | Empty placeholder |
| `ScoreDisplay` | common_widgets.dart | Circular score |
| `ShimmerCard` | loading_widgets.dart | Shimmer placeholder |
| `ClothingGridShimmer` | loading_widgets.dart | Grid loading |
| `OutfitShimmer` | loading_widgets.dart | Outfit loading |
| `AIAnalyzingAnimation` | loading_widgets.dart | AI progress |

---

**Tiếp theo:** [THEME.md](./THEME.md) - Theme & Styling
