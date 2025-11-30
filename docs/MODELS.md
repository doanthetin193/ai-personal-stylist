# Models - Data Models Documentation

> **File 2/8** - Tài liệu chi tiết về các Data Models trong AI Personal Stylist

## 📁 Vị trí: `lib/models/`

```
lib/models/
├── clothing_item.dart    # Model chính cho quần áo + các Enums
├── outfit.dart           # Model cho outfit và color harmony result
└── weather.dart          # Model cho thông tin thời tiết
```

---

## 1. ClothingItem Model (`clothing_item.dart`)

### 1.1 Enums

#### `ClothingType` - Loại quần áo

```dart
enum ClothingType {
  shirt,      // Áo sơ mi
  tshirt,     // Áo thun
  pants,      // Quần tây
  jeans,      // Quần jeans
  shorts,     // Quần short
  jacket,     // Áo khoác
  hoodie,     // Áo hoodie
  dress,      // Váy đầm
  skirt,      // Chân váy
  shoes,      // Giày
  sneakers,   // Giày sneaker
  accessory,  // Phụ kiện
  bag,        // Túi xách
  hat,        // Mũ/Nón
  other       // Khác
}
```

**Các methods quan trọng:**

| Method | Mô tả | Ví dụ |
|--------|-------|-------|
| `displayName` | Tên hiển thị tiếng Việt | `ClothingType.shirt.displayName` → `"Áo sơ mi"` |
| `category` | Phân loại để phối đồ | `ClothingType.shirt.category` → `"top"` |
| `fromString()` | Parse từ String | `ClothingType.fromString("shirt")` → `ClothingType.shirt` |

**Category mapping:**

```
┌─────────────────────────────────────────────────────┐
│ Category      │ ClothingTypes                       │
├─────────────────────────────────────────────────────┤
│ top           │ shirt, tshirt                       │
│ outerwear     │ hoodie, jacket                      │
│ bottom        │ pants, jeans, shorts, skirt         │
│ dress         │ dress                               │
│ footwear      │ shoes, sneakers                     │
│ bag           │ bag                                 │
│ hat           │ hat                                 │
│ accessory     │ accessory                           │
│ other         │ other                               │
└─────────────────────────────────────────────────────┘
```

---

#### `ClothingStyle` - Phong cách

```dart
enum ClothingStyle {
  casual,       // Thường ngày
  formal,       // Trang trọng
  streetwear,   // Đường phố
  vintage,      // Cổ điển
  sporty,       // Thể thao
  elegant,      // Thanh lịch
  bohemian,     // Bohemian
  minimalist    // Tối giản
}
```

**Methods:**
- `displayName` → Tên tiếng Anh (giữ nguyên vì là tên style quốc tế)
- `fromString()` → Parse từ String, default: `casual`

---

#### `Season` - Mùa phù hợp

```dart
enum Season {
  spring,   // Xuân
  summer,   // Hè
  fall,     // Thu
  winter    // Đông
}
```

**Methods:**
- `displayName` → Tên tiếng Việt (`"Xuân"`, `"Hè"`, `"Thu"`, `"Đông"`)
- `fromString()` → Parse từ String, default: `summer`

---

### 1.2 ClothingItem Class

**Model chính đại diện cho một item quần áo trong tủ đồ.**

#### Fields

| Field | Type | Required | Mô tả |
|-------|------|----------|-------|
| `id` | `String` | ✅ | Document ID từ Firestore |
| `userId` | `String` | ✅ | User ID sở hữu item |
| `imageUrl` | `String?` | ❌ | URL ảnh (deprecated, giữ backward compat) |
| `imageBase64` | `String?` | ❌ | Ảnh dạng Base64 lưu Firestore |
| `type` | `ClothingType` | ✅ | Loại quần áo |
| `color` | `String` | ✅ | Màu sắc (từ AI phân tích) |
| `material` | `String?` | ❌ | Chất liệu |
| `styles` | `List<ClothingStyle>` | ✅ | Danh sách style phù hợp |
| `seasons` | `List<Season>` | ✅ | Danh sách mùa phù hợp |
| `brand` | `String?` | ❌ | Thương hiệu |
| `notes` | `String?` | ❌ | Ghi chú thêm |
| `createdAt` | `DateTime` | ✅ | Ngày thêm vào tủ đồ |
| `lastWorn` | `DateTime?` | ❌ | Lần mặc cuối |
| `wearCount` | `int` | ✅ | Số lần mặc (default: 0) |
| `isFavorite` | `bool` | ✅ | Đánh dấu yêu thích (default: false) |

#### Methods

```dart
// Tạo từ Firestore document
factory ClothingItem.fromJson(Map<String, dynamic> json, String docId)

// Chuyển sang Map để lưu Firestore
Map<String, dynamic> toJson()

// Tạo mô tả ngắn cho AI
String toAIDescription()
// Output: "ID:abc123 | shirt | blue | casual, formal | Seasons: summer, spring"

// Copy với fields mới
ClothingItem copyWith({...})
```

#### JSON Structure (Firestore)

```json
{
  "userId": "user123",
  "imageBase64": "data:image/jpeg;base64,...",
  "type": "shirt",
  "color": "navy blue",
  "material": "cotton",
  "styles": ["casual", "formal"],
  "seasons": ["spring", "summer", "fall"],
  "brand": "Uniqlo",
  "notes": "Áo sơ mi công sở",
  "createdAt": "<Timestamp>",
  "lastWorn": "<Timestamp>",
  "wearCount": 5,
  "isFavorite": true
}
```

---

## 2. Outfit Model (`outfit.dart`)

### 2.1 Outfit Class

**Model đại diện cho một bộ outfit được AI gợi ý.**

#### Fields

| Field | Type | Required | Mô tả |
|-------|------|----------|-------|
| `id` | `String` | ✅ | ID duy nhất của outfit |
| `top` | `ClothingItem?` | ❌ | Áo (shirt, tshirt) |
| `bottom` | `ClothingItem?` | ❌ | Quần (pants, jeans, shorts, skirt) |
| `outerwear` | `ClothingItem?` | ❌ | Áo khoác (jacket, hoodie) |
| `footwear` | `ClothingItem?` | ❌ | Giày |
| `accessories` | `List<ClothingItem>` | ✅ | Phụ kiện (default: empty) |
| `occasion` | `String` | ✅ | Dịp/hoàn cảnh mặc |
| `reason` | `String` | ✅ | Lý do AI gợi ý outfit này |
| `colorScore` | `int?` | ❌ | Điểm phối màu (0-100) |
| `createdAt` | `DateTime` | ✅ | Thời điểm tạo |

#### Structure Diagram

```
┌─────────────────────────────────────────────┐
│                  OUTFIT                      │
├─────────────────────────────────────────────┤
│  ┌─────────┐  ┌───────────┐                 │
│  │   TOP   │  │ OUTERWEAR │   (optional)    │
│  │  shirt  │  │  jacket   │                 │
│  │ tshirt  │  │  hoodie   │                 │
│  └─────────┘  └───────────┘                 │
│                                             │
│  ┌──────────┐                               │
│  │  BOTTOM  │                               │
│  │  pants   │                               │
│  │  jeans   │                               │
│  │  shorts  │                               │
│  │  skirt   │                               │
│  └──────────┘                               │
│                                             │
│  ┌──────────┐  ┌─────────────┐              │
│  │ FOOTWEAR │  │ ACCESSORIES │  (list)      │
│  │  shoes   │  │ bag, hat... │              │
│  │ sneakers │  │             │              │
│  └──────────┘  └─────────────┘              │
├─────────────────────────────────────────────┤
│  occasion: "Đi làm"                         │
│  reason: "Phong cách formal..."             │
│  colorScore: 85                             │
└─────────────────────────────────────────────┘
```

#### Getters & Methods

```dart
// Lấy tất cả items trong outfit
List<ClothingItem> get allItems
// Trả về list gồm: top, bottom, outerwear, footwear, accessories

// Đếm số items
int get itemCount
// allItems.length

// Copy with new fields
Outfit copyWith({...})
```

---

### 2.2 ColorHarmonyResult Class

**Model cho kết quả phân tích Color Harmony từ AI.**

#### Fields

| Field | Type | Required | Mô tả |
|-------|------|----------|-------|
| `score` | `int` | ✅ | Điểm phối màu (0-100) |
| `reason` | `String` | ✅ | Lý do AI đánh giá |
| `vibe` | `String` | ✅ | Cảm giác tổng thể (vd: "Warm", "Cool", "Neutral") |
| `tips` | `List<String>` | ✅ | Gợi ý cải thiện (default: empty) |

#### Factory Constructor

```dart
factory ColorHarmonyResult.fromJson(Map<String, dynamic> json) {
  return ColorHarmonyResult(
    score: json['score'] ?? 50,           // Default 50 nếu không có
    reason: json['reason'] ?? 'Không có thông tin',
    vibe: json['vibe'] ?? 'Neutral',
    tips: (json['tips'] as List<dynamic>?)?.cast<String>() ?? [],
  );
}
```

#### JSON Structure (từ AI response)

```json
{
  "score": 85,
  "reason": "Sự kết hợp giữa áo xanh navy và quần beige tạo nên sự hài hòa tuyệt vời...",
  "vibe": "Professional Elegance",
  "tips": [
    "Thêm đồng hồ kim loại để hoàn thiện",
    "Có thể thay giày da nâu để tăng sự ấm áp"
  ]
}
```

---

## 3. WeatherInfo Model (`weather.dart`)

**Model cho thông tin thời tiết từ Open-Meteo API.**

### Fields

| Field | Type | Required | Mô tả |
|-------|------|----------|-------|
| `temperature` | `double` | ✅ | Nhiệt độ (°C) |
| `feelsLike` | `double` | ✅ | Nhiệt độ cảm nhận (°C) |
| `humidity` | `int` | ✅ | Độ ẩm (%) |
| `windSpeed` | `double` | ✅ | Tốc độ gió (m/s) |
| `description` | `String` | ✅ | Mô tả thời tiết |
| `icon` | `String` | ✅ | Mã icon thời tiết |
| `cityName` | `String` | ✅ | Tên thành phố |
| `timestamp` | `DateTime` | ✅ | Thời điểm lấy data |

### Getters

```dart
// Mô tả nhiệt độ bằng tiếng Việt
String get temperatureDescription
// < 15°C  → "Lạnh"
// < 22°C  → "Mát mẻ"
// < 28°C  → "Ấm áp"
// < 35°C  → "Nóng"
// >= 35°C → "Rất nóng"

// URL icon thời tiết
String get iconUrl
// "https://openweathermap.org/img/wn/{icon}@2x.png"

// Gợi ý quần áo dựa trên thời tiết
List<String> get clothingSuggestions
```

### Methods

```dart
// Tạo mô tả cho AI prompt
String toAIDescription()
```

**Output example:**
```
Weather: Partly cloudy
Temperature: 28°C (feels like 30°C)
Humidity: 75%
Wind: 3 m/s
Condition: Ấm áp
```

### Temperature → Clothing Logic

```
┌──────────────────────────────────────────────────────────┐
│ Nhiệt độ    │ Gợi ý                                      │
├──────────────────────────────────────────────────────────┤
│ < 15°C      │ Áo khoác dày, áo len, hoodie               │
│ 15-22°C     │ Áo khoác nhẹ                               │
│ > 30°C      │ Đồ thoáng mát, chất liệu cotton            │
│ Mưa         │ Áo mưa hoặc ô                              │
└──────────────────────────────────────────────────────────┘
```

---

## 4. Relationships Between Models

```
┌─────────────────────────────────────────────────────────────┐
│                     DATA RELATIONSHIPS                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   User                                                      │
│     │                                                       │
│     ▼                                                       │
│   ┌─────────────────┐                                       │
│   │  ClothingItem   │──────────────────┐                    │
│   │  (Many items)   │                  │                    │
│   └────────┬────────┘                  │                    │
│            │                           │                    │
│            │ grouped by category       │ selected items     │
│            ▼                           ▼                    │
│   ┌─────────────────┐         ┌─────────────────┐          │
│   │   Categories    │         │     Outfit      │          │
│   │   - top         │         │   (Combination) │          │
│   │   - bottom      │         │                 │          │
│   │   - outerwear   │         │ + occasion      │          │
│   │   - footwear    │         │ + reason (AI)   │          │
│   │   - accessory   │         │ + colorScore    │          │
│   └─────────────────┘         └────────┬────────┘          │
│                                        │                    │
│   ┌─────────────────┐                  │ analyzed          │
│   │   WeatherInfo   │──────────────────┘                    │
│   │ (Current weather)│  influences outfit suggestion        │
│   └─────────────────┘                                       │
│                                                             │
│   ┌─────────────────────┐                                   │
│   │ ColorHarmonyResult  │ ← AI analyzes Outfit colors       │
│   │   score, vibe, tips │                                   │
│   └─────────────────────┘                                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Usage Examples

### Tạo ClothingItem mới

```dart
final item = ClothingItem(
  id: 'item_001',
  userId: 'user_abc',
  imageBase64: 'data:image/jpeg;base64,...',
  type: ClothingType.shirt,
  color: 'navy blue',
  material: 'cotton',
  styles: [ClothingStyle.casual, ClothingStyle.formal],
  seasons: [Season.spring, Season.summer, Season.fall],
  brand: 'Uniqlo',
  createdAt: DateTime.now(),
);
```

### Parse ClothingItem từ Firestore

```dart
final doc = await firestore.collection('clothes').doc('item_001').get();
final item = ClothingItem.fromJson(doc.data()!, doc.id);
```

### Tạo Outfit từ các items

```dart
final outfit = Outfit(
  id: 'outfit_001',
  top: shirtItem,
  bottom: jeansItem,
  footwear: sneakersItem,
  accessories: [watchItem, bagItem],
  occasion: 'Đi làm',
  reason: 'Phong cách smart casual phù hợp môi trường công sở...',
  colorScore: 85,
  createdAt: DateTime.now(),
);
```

### Parse ColorHarmonyResult từ AI response

```dart
final json = jsonDecode(aiResponse);
final result = ColorHarmonyResult.fromJson(json);
print('Score: ${result.score}/100');
print('Vibe: ${result.vibe}');
```

---

## 📝 Notes

1. **imageBase64 vs imageUrl**: Hiện tại app lưu ảnh dưới dạng Base64 trực tiếp vào Firestore thay vì upload lên Storage. Field `imageUrl` giữ lại để backward compatibility.

2. **Default values**: Các enum đều có `fromString()` với giá trị default để tránh crash khi parse data không hợp lệ.

3. **AI Description**: Method `toAIDescription()` tạo text format đặc biệt để AI có thể hiểu và xử lý item.

4. **copyWith pattern**: Tất cả models đều có `copyWith()` để tạo bản copy với một số fields thay đổi (immutable pattern).

---

**Tiếp theo:** [PROVIDERS.md](./PROVIDERS.md) - State Management với Provider Pattern
