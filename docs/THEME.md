# Theme & Styling Documentation

> **File 7/8** - Tài liệu chi tiết về Theme, Colors, Typography và Helpers

## 📁 Vị trí: `lib/utils/`

```
lib/utils/
├── theme.dart      # AppTheme, AppDecorations
├── helpers.dart    # Utility functions
├── constants.dart  # App constants, AI prompts
└── api_keys.dart   # API keys (gitignored)
```

---

## 1. Color Palette (`theme.dart`)

### 1.1 Brand Colors

```dart
// Primary - Vibrant Purple
static const Color primaryColor = Color(0xFF7C3AED);

// Secondary - Pink  
static const Color secondaryColor = Color(0xFFEC4899);

// Accent - Cyan
static const Color accentColor = Color(0xFF06B6D4);
```

### 1.2 Color Visual

```
┌─────────────────────────────────────────────────────────────────┐
│                      COLOR PALETTE                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   PRIMARY        SECONDARY       ACCENT                         │
│   #7C3AED        #EC4899         #06B6D4                        │
│   ████████       ████████        ████████                       │
│   Purple         Pink            Cyan                           │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   BACKGROUND     SURFACE         ERROR                          │
│   #F1F5F9        #FAFAFA         #EF4444                        │
│   ████████       ████████        ████████                       │
│   Slate 100      Near White      Red                            │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   SUCCESS        WARNING         TEXT PRIMARY                   │
│   #10B981        #F59E0B         #1E293B                        │
│   ████████       ████████        ████████                       │
│   Emerald        Amber           Slate 800                      │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   TEXT SECONDARY                 TEXT LIGHT                     │
│   #64748B                        #94A3B8                        │
│   ████████                       ████████                       │
│   Slate 500                      Slate 400                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 1.3 All Colors Reference

| Color | Hex | Usage |
|-------|-----|-------|
| `primaryColor` | `#7C3AED` | Buttons, icons, highlights |
| `secondaryColor` | `#EC4899` | Accents, favorites, pink elements |
| `accentColor` | `#06B6D4` | Info, links, cyan elements |
| `backgroundColor` | `#F1F5F9` | Page backgrounds |
| `surfaceColor` | `#FAFAFA` | Cards, AppBar |
| `errorColor` | `#EF4444` | Errors, delete actions |
| `successColor` | `#10B981` | Success states, high scores |
| `warningColor` | `#F59E0B` | Warnings, medium scores |
| `textPrimary` | `#1E293B` | Main text |
| `textSecondary` | `#64748B` | Subtitle, descriptions |
| `textLight` | `#94A3B8` | Placeholder, disabled |

---

## 2. Gradients

### 2.1 Primary Gradient

```dart
static const LinearGradient primaryGradient = LinearGradient(
  colors: [
    Color(0xFF7C3AED),  // Purple
    Color(0xFFA855F7),  // Light Purple
    Color(0xFFEC4899),  // Pink
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

**Visual:**
```
┌─────────────────────────────────────────┐
│ Purple ═══════► Light Purple ═══════► Pink │
│ #7C3AED        #A855F7              #EC4899 │
└─────────────────────────────────────────┘
```

**Usage:** Buttons, headers, nav items, icons

### 2.2 Accent Gradient

```dart
static const LinearGradient accentGradient = LinearGradient(
  colors: [
    Color(0xFF06B6D4),  // Cyan
    Color(0xFF0EA5E9),  // Sky
    Color(0xFF6366F1),  // Indigo
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

**Visual:**
```
┌─────────────────────────────────────────┐
│ Cyan ═══════► Sky ═══════► Indigo       │
│ #06B6D4      #0EA5E9     #6366F1        │
└─────────────────────────────────────────┘
```

**Usage:** Secondary accents, info cards

---

## 3. Typography

### 3.1 Font Family

```dart
import 'package:google_fonts/google_fonts.dart';

// Tất cả text sử dụng Poppins font
GoogleFonts.poppins(...)
```

### 3.2 Text Styles Hierarchy

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `displayLarge` | 32px | Bold | Hero titles |
| `displayMedium` | 28px | Bold | Page titles |
| `displaySmall` | 24px | Bold | Section headers |
| `headlineMedium` | 20px | SemiBold | Card titles |
| `headlineSmall` | 18px | SemiBold | Subtitles |
| `titleLarge` | 16px | SemiBold | List item titles |
| `titleMedium` | 14px | Medium | Labels |
| `bodyLarge` | 16px | Normal | Body text |
| `bodyMedium` | 14px | Normal | Secondary text |
| `bodySmall` | 12px | Normal | Captions |
| `labelLarge` | 14px | SemiBold | Button text |

### 3.3 Visual Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  displayLarge (32px Bold)                                   │
│  ═══════════════════════                                    │
│                                                             │
│  displayMedium (28px Bold)                                  │
│  ════════════════════════                                   │
│                                                             │
│  displaySmall (24px Bold)                                   │
│  ═══════════════════════                                    │
│                                                             │
│  headlineMedium (20px SemiBold)                             │
│  ───────────────────────────                                │
│                                                             │
│  headlineSmall (18px SemiBold)                              │
│  ─────────────────────────                                  │
│                                                             │
│  titleLarge (16px SemiBold)                                 │
│  ─────────────────────                                      │
│                                                             │
│  bodyLarge (16px) - Regular body text                       │
│  bodyMedium (14px) - Secondary info                         │
│  bodySmall (12px) - Captions, timestamps                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Component Themes

### 4.1 AppBar Theme

```dart
appBarTheme: AppBarTheme(
  elevation: 0,
  centerTitle: true,
  backgroundColor: surfaceColor,
  foregroundColor: textPrimary,
  titleTextStyle: GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  ),
),
```

### 4.2 Button Themes

#### ElevatedButton

```dart
ElevatedButton.styleFrom(
  backgroundColor: primaryColor,
  foregroundColor: Colors.white,
  elevation: 2,
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  borderRadius: BorderRadius.circular(12),
)
```

**Visual:**
```
┌─────────────────────────────┐
│       BUTTON TEXT           │  Background: primaryColor
│                             │  Text: white
└─────────────────────────────┘  Border radius: 12
```

#### OutlinedButton

```dart
OutlinedButton.styleFrom(
  foregroundColor: primaryColor,
  side: BorderSide(color: primaryColor),
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  borderRadius: BorderRadius.circular(12),
)
```

**Visual:**
```
┌─────────────────────────────┐
│       BUTTON TEXT           │  Border: primaryColor
│                             │  Text: primaryColor
└─────────────────────────────┘  Background: transparent
```

### 4.3 Input Theme

```dart
InputDecorationTheme(
  filled: true,
  fillColor: Colors.grey.shade100,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: primaryColor, width: 2),
  ),
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
)
```

**States:**
```
Normal:                    Focused:
┌─────────────────────┐    ┌═════════════════════┐
│  Placeholder...     │    ║  Input text...      ║ ← Primary border
└─────────────────────┘    └═════════════════════┘
   Grey background            + Purple border
```

### 4.4 Chip Theme

```dart
ChipThemeData(
  backgroundColor: Colors.grey.shade100,
  selectedColor: primaryColor.withValues(alpha: 0.2),
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  borderRadius: BorderRadius.circular(20),
)
```

**States:**
```
Normal:           Selected:
┌────────────┐    ┌────────────┐
│   Label    │    │   Label    │ ← Light purple bg
└────────────┘    └────────────┘
  Grey bg           + check icon
```

---

## 5. AppDecorations

### 5.1 Card Decoration

```dart
static BoxDecoration get cardDecoration => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(20),
  boxShadow: [
    BoxShadow(
      color: AppTheme.primaryColor.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ],
);
```

**Visual:**
```
                    ╭─────────────────────────────╮
                    │                             │
                    │       CARD CONTENT          │
                    │                             │
                    ╰─────────────────────────────╯
                      ░░░░░░░░░░░░░░░░░░░░░░░░░
                       ↑ Purple-tinted shadow
```

**Features:**
- White background
- 20px border radius
- Dual shadow (purple tint + black subtle)
- Premium, elevated look

---

## 6. Helpers (`helpers.dart`)

### 6.1 JSON Helpers

#### `cleanJsonResponse()` - Clean AI response

```dart
String cleanJsonResponse(String raw) {
  // Remove markdown code blocks
  cleaned = cleaned.replaceAll(RegExp(r'```json\s*'), '');
  cleaned = cleaned.replaceAll(RegExp(r'```\s*'), '');
  
  // Find JSON boundaries
  final startIndex = cleaned.indexOf('{');
  final endIndex = cleaned.lastIndexOf('}');
  
  return cleaned.substring(startIndex, endIndex + 1);
}
```

**Use case:** AI đôi khi trả về markdown, cần clean.

#### `safeParseJson()` - Safe JSON parsing

```dart
Map<String, dynamic>? safeParseJson(String raw) {
  try {
    final cleaned = cleanJsonResponse(raw);
    return jsonDecode(cleaned);
  } catch (e) {
    print('JSON Parse Error: $e');
    return null;
  }
}
```

---

### 6.2 Format Helpers

#### `formatTemperature()`

```dart
String formatTemperature(double temp) {
  return '${temp.round()}°C';
}
// 28.5 → "29°C"
```

#### `formatDateVN()`

```dart
String formatDateVN(DateTime date) {
  final weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  return '$weekday, ${date.day}/${date.month}/${date.year}';
}
// → "T7, 30/11/2025"
```

#### `formatRelativeTime()`

```dart
String formatRelativeTime(DateTime date)
// < 1 hour: "5 phút trước"
// < 24 hours: "3 giờ trước"
// Yesterday: "Hôm qua"
// < 7 days: "3 ngày trước"
// < 30 days: "2 tuần trước"
// Else: "30/11/2025"
```

---

### 6.3 Text Helpers

#### `capitalize()`

```dart
String capitalize(String text) {
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}
// "hello WORLD" → "Hello world"
```

#### `getGreeting()`

```dart
String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Chào buổi sáng';
  if (hour < 18) return 'Chào buổi chiều';
  return 'Chào buổi tối';
}
```

---

### 6.4 Translation Helpers

#### `getColorNameVN()` - Color translation

```dart
String getColorNameVN(String color)
```

**Logic:**
```
┌─────────────────────────────────────────────────────────────┐
│ Input đã tiếng Việt hoặc có nhiều từ?                       │
│ (vd: "trắng sọc đen", "xanh navy")                         │
│                                                             │
│   YES → capitalize() và return                              │
│                                                             │
│   NO → Lookup trong colorMap                                │
│        'red' → 'Đỏ'                                         │
│        'blue' → 'Xanh dương'                                │
│        'navy' → 'Xanh navy'                                 │
│        ...                                                  │
│        Not found → capitalize(original)                     │
└─────────────────────────────────────────────────────────────┘
```

**Color Map:**

| English | Vietnamese |
|---------|------------|
| red | Đỏ |
| blue | Xanh dương |
| green | Xanh lá |
| yellow | Vàng |
| orange | Cam |
| purple | Tím |
| pink | Hồng |
| black | Đen |
| white | Trắng |
| gray/grey | Xám |
| brown | Nâu |
| beige | Be |
| navy | Xanh navy |
| cream | Kem |
| khaki | Kaki |
| maroon | Đỏ đậm |
| olive | Xanh olive |
| teal | Xanh ngọc |
| coral | San hô |
| burgundy | Đỏ rượu |

#### `getMaterialNameVN()` - Material translation

```dart
String getMaterialNameVN(String material)
```

| English | Vietnamese |
|---------|------------|
| cotton | Cotton |
| denim | Denim/Bò |
| polyester | Polyester |
| leather | Da |
| wool | Len |
| silk | Lụa |
| linen | Vải lanh |
| synthetic | Tổng hợp |
| unknown | Không xác định |

---

## 7. Usage Examples

### 7.1 Apply Theme

```dart
// main.dart
MaterialApp(
  theme: AppTheme.lightTheme,
  home: HomeScreen(),
)
```

### 7.2 Use Colors

```dart
Container(
  color: AppTheme.primaryColor,
  child: Text(
    'Hello',
    style: TextStyle(color: AppTheme.textPrimary),
  ),
)
```

### 7.3 Use Gradients

```dart
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.primaryGradient,
    borderRadius: BorderRadius.circular(16),
  ),
  child: ...,
)
```

### 7.4 Use Card Decoration

```dart
Container(
  decoration: AppDecorations.cardDecoration,
  padding: EdgeInsets.all(16),
  child: ...,
)
```

### 7.5 Format Values

```dart
Text(formatTemperature(28.5));     // "29°C"
Text(formatDateVN(DateTime.now())); // "T7, 30/11/2025"
Text(getColorNameVN('navy'));       // "Xanh navy"
Text(getGreeting());                // "Chào buổi sáng"
```

---

## 8. Design Principles

### 8.1 Color Usage Guidelines

```
┌─────────────────────────────────────────────────────────────┐
│ Element              │ Color                                │
├─────────────────────────────────────────────────────────────┤
│ Primary CTA          │ primaryColor / primaryGradient       │
│ Secondary actions    │ secondaryColor                       │
│ Info/Links           │ accentColor                          │
│ Page backgrounds     │ backgroundColor                      │
│ Cards/Surfaces       │ white / surfaceColor                 │
│ Errors               │ errorColor                           │
│ Success              │ successColor                         │
│ Warnings             │ warningColor                         │
│ Main text            │ textPrimary                          │
│ Secondary text       │ textSecondary                        │
│ Disabled/Placeholder │ textLight                            │
└─────────────────────────────────────────────────────────────┘
```

### 8.2 Spacing Guidelines

```dart
// Consistent spacing values
4px  - Minimal spacing
8px  - Tight spacing
12px - Default spacing
16px - Standard padding
20px - Section padding
24px - Large padding
32px - Section gaps
```

### 8.3 Border Radius Guidelines

```dart
8px  - Small elements (chips, tags)
12px - Buttons, inputs
16px - Cards
20px - Large cards, bottom sheets
25px - Pills, rounded chips
36px - Avatars, circular elements
```

---

## 📝 Summary

| File | Purpose |
|------|---------|
| `theme.dart` | Colors, gradients, typography, component themes |
| `helpers.dart` | JSON parsing, formatting, translations |
| `constants.dart` | App constants, API URLs, AI prompts |
| `api_keys.dart` | API keys (gitignored) |

---

**Tiếp theo:** [AI_INTEGRATION.md](./AI_INTEGRATION.md) - Chi tiết tích hợp AI
