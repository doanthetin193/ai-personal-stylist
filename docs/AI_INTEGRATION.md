# AI Integration - Gemini AI Documentation

> **File 8/8** - Tài liệu chi tiết về tích hợp Google Gemini AI

## 📁 Vị trí liên quan

```
lib/
├── services/gemini_service.dart    # Gemini API wrapper
├── utils/constants.dart            # AI Prompts
└── utils/helpers.dart              # JSON parsing utilities
```

---

## 1. Overview

### 1.1 AI Model

```dart
Model: gemini-2.0-flash
```

**Tại sao chọn Gemini 2.0 Flash?**
- ✅ Hỗ trợ Vision (phân tích ảnh)
- ✅ Nhanh và ổn định
- ✅ Chi phí hợp lý
- ✅ JSON output tốt

### 1.2 AI Features

```
┌─────────────────────────────────────────────────────────────────┐
│                        AI FEATURES                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. 📸 Image Analysis                                           │
│     Phân tích ảnh quần áo → type, color, material, styles      │
│                                                                 │
│  2. 👔 Outfit Suggestion                                        │
│     Gợi ý outfit dựa trên tủ đồ, thời tiết, dịp                │
│                                                                 │
│  3. 🎨 Color Harmony                                            │
│     Chấm điểm phối màu giữa 2 items                            │
│                                                                 │
│  4. 🧹 Wardrobe Cleanup                                         │
│     Gợi ý dọn tủ - tìm đồ trùng, không hợp style               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. GeminiService Setup

### 2.1 Initialization

```dart
class GeminiService {
  late final GenerativeModel _model;        // Text generation
  late final GenerativeModel _visionModel;  // Vision (image + text)
  bool _isInitialized = false;
  
  void initialize(String apiKey) {
    // Text model - cho outfit suggestion, cleanup
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,      // Creative but controlled
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );
    
    // Vision model - cho image analysis
    _visionModel = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3,      // Lower = more consistent JSON
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );
    
    _isInitialized = true;
  }
}
```

### 2.2 Model Configuration

| Config | Text Model | Vision Model | Purpose |
|--------|------------|--------------|---------|
| `temperature` | 0.7 | 0.3 | Vision thấp hơn để JSON ổn định |
| `topK` | 40 | 40 | Top K sampling |
| `topP` | 0.95 | 0.95 | Nucleus sampling |
| `maxOutputTokens` | 1024 | 1024 | Max response length |

### 2.3 Initialization Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    INITIALIZATION FLOW                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   main.dart                                                     │
│      │                                                          │
│      ▼                                                          │
│   Firebase.initializeApp()                                      │
│      │                                                          │
│      ▼                                                          │
│   geminiService.initialize(ApiKeys.geminiApiKey)                │
│      │                                                          │
│      ├── Check API key validity                                 │
│      ├── Create _model (text)                                   │
│      ├── Create _visionModel (vision)                           │
│      └── _isInitialized = true                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Feature 1: Image Analysis

### 3.1 Purpose

Phân tích ảnh quần áo và trích xuất thông tin.

### 3.2 API Method

```dart
Future<Map<String, dynamic>?> analyzeClothingImageBytes(
  Uint8List imageBytes
) async
```

### 3.3 Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                   IMAGE ANALYSIS FLOW                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   User picks image                                              │
│        │                                                        │
│        ▼                                                        │
│   imageBytes (Uint8List)                                        │
│        │                                                        │
│        ▼                                                        │
│   ┌─────────────────────────────────────────┐                   │
│   │           Gemini Vision API              │                   │
│   │                                          │                   │
│   │   Input:                                 │                   │
│   │   - TextPart: AIPrompts.analyzeClothing  │                   │
│   │   - DataPart: image/jpeg, imageBytes     │                   │
│   │                                          │                   │
│   │   Output: JSON string                    │                   │
│   └─────────────────────────────────────────┘                   │
│        │                                                        │
│        ▼                                                        │
│   safeParseJson(response)                                       │
│        │                                                        │
│        ▼                                                        │
│   Map<String, dynamic> result                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 3.4 Prompt: `analyzeClothing`

```
Bạn là chuyên gia thời trang. Phân tích kỹ ảnh quần áo này...

QUAN TRỌNG - PHÂN BIỆT LOẠI ÁO:
- "tshirt": Áo thun (cổ tròn/cổ tim, không nút)
- "shirt": Áo sơ mi (có cổ áo cứng, có nút)
- "hoodie": Áo hoodie (có mũ trùm)
- "jacket": Áo khoác

QUAN TRỌNG - MÀU SẮC:
- Nhiều màu: "trắng sọc đen", "xanh kẻ caro trắng"
- Họa tiết: "trắng họa tiết đen"
- Dùng tiếng Việt

Output JSON:
{
  "type": "shirt|tshirt|pants|...",
  "color": "màu tiếng Việt",
  "material": "cotton|denim|...",
  "styles": ["casual", "formal", ...],
  "seasons": ["spring", "summer", ...]
}
```

### 3.5 Output Schema

```typescript
{
  type: "shirt" | "tshirt" | "pants" | "jeans" | "shorts" | 
        "jacket" | "hoodie" | "dress" | "skirt" | "shoes" | 
        "sneakers" | "accessory" | "bag" | "hat" | "other",
  
  color: string,        // Vietnamese, e.g., "xanh navy", "trắng sọc đen"
  
  material: "cotton" | "denim" | "polyester" | "leather" | 
            "wool" | "silk" | "linen" | "synthetic" | "unknown",
  
  styles: string[],     // 1-3 styles: casual, formal, streetwear, 
                        // vintage, sporty, elegant, minimalist
  
  seasons: string[]     // spring, summer, fall, winter
}
```

### 3.6 Key Design Decisions

1. **Temperature 0.3**: Thấp để JSON output ổn định
2. **Vietnamese colors**: Dễ hiển thị UI, không cần translate
3. **Multi-color support**: "trắng sọc đen" thay vì chỉ "trắng"
4. **Type distinction**: Hướng dẫn rõ ràng phân biệt tshirt vs shirt

---

## 4. Feature 2: Outfit Suggestion

### 4.1 Purpose

Gợi ý outfit hoàn chỉnh từ tủ đồ dựa trên context.

### 4.2 API Method

```dart
Future<Map<String, dynamic>?> suggestOutfit({
  required List<ClothingItem> wardrobe,
  required String weatherContext,
  required String occasion,
  String? stylePreference,
}) async
```

### 4.3 Input Context

```
┌─────────────────────────────────────────────────────────────────┐
│                    SUGGESTION INPUTS                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. WARDROBE ITEMS                                              │
│     Generated from: item.toAIDescription()                      │
│     Format: "ID:abc123 | shirt | blue | casual | Seasons: ..." │
│                                                                 │
│  2. WEATHER CONTEXT                                             │
│     Generated from: weather.toAIDescription()                   │
│     Format: "Temperature: 28°C, Humidity: 70%, ..."            │
│                                                                 │
│  3. OCCASION                                                    │
│     User selected: "Đi làm", "Hẹn hò", "Tiệc tùng", etc.       │
│                                                                 │
│  4. STYLE PREFERENCE (optional)                                 │
│     "User prefers loose, relaxed clothing..."                  │
│     "User prefers fitted, slim clothing..."                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 4.4 Prompt: `suggestOutfit`

```
You are a professional fashion stylist...

WARDROBE ITEMS:
{wardrobeContext}

WEATHER:
{weatherContext}

OCCASION: {occasion}

STYLE PREFERENCE: (if provided)
{stylePreference}

Select items that:
1. Match the weather conditions
2. Are appropriate for the occasion
3. Have harmonious colors
4. Create a cohesive style
5. Respect user's style preference

Output JSON:
{
  "top": "item_id or null",
  "bottom": "item_id or null",
  "outerwear": "item_id or null",
  "footwear": "item_id or null",
  "accessories": ["item_id", ...],
  "reason": "Lý do bằng tiếng Việt"
}
```

### 4.5 Output Schema

```typescript
{
  top: string | null,         // Item ID cho áo
  bottom: string | null,      // Item ID cho quần
  outerwear: string | null,   // Item ID cho áo khoác
  footwear: string | null,    // Item ID cho giày
  accessories: string[],      // Array item IDs phụ kiện
  reason: string              // Vietnamese explanation
}
```

### 4.6 Selection Criteria

```
┌─────────────────────────────────────────────────────────────────┐
│                   AI SELECTION CRITERIA                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Priority 1: Weather Match                                      │
│  ─────────────────────────                                      │
│  • Hot (>30°C) → Light fabrics, shorts, tshirts                │
│  • Cold (<15°C) → Layers, jacket, hoodie                       │
│  • Rain → Water-resistant items                                │
│                                                                 │
│  Priority 2: Occasion Appropriateness                           │
│  ───────────────────────────────────                            │
│  • Work → Formal, smart casual                                 │
│  • Date → Elegant, attractive                                  │
│  • Sport → Sporty, comfortable                                 │
│                                                                 │
│  Priority 3: Color Harmony                                      │
│  ─────────────────────────                                      │
│  • Complementary colors                                        │
│  • Avoid clashing                                              │
│  • Consider skin tone (if known)                               │
│                                                                 │
│  Priority 4: Style Cohesion                                     │
│  ──────────────────────────                                     │
│  • All items same style family                                 │
│  • Consistent aesthetic                                        │
│                                                                 │
│  Priority 5: User Preference                                    │
│  ──────────────────────────                                     │
│  • Loose vs Fitted preference                                  │
│  • Favorite styles                                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. Feature 3: Color Harmony

### 5.1 Purpose

Đánh giá độ hài hòa màu sắc giữa 2 items.

### 5.2 API Method

```dart
Future<ColorHarmonyResult?> evaluateColorHarmony(
  ClothingItem item1,
  ClothingItem item2,
) async
```

### 5.3 Prompt: `colorHarmony`

```
As a color theory expert, evaluate the color harmony...

Item 1: {item1.toAIDescription()}
Item 2: {item2.toAIDescription()}

Scoring guide:
- 90-100: Perfect harmony, trending
- 70-89: Good match
- 50-69: Acceptable
- 30-49: Clashing
- 0-29: Very poor

Output JSON:
{
  "score": 0-100,
  "reason": "Vietnamese explanation",
  "vibe": "Overall aesthetic",
  "tips": ["Tip 1", "Tip 2"]
}
```

### 5.4 Output Schema

```typescript
{
  score: number,      // 0-100
  reason: string,     // Vietnamese explanation
  vibe: string,       // "Classic & Elegant", "Bold & Modern", etc.
  tips: string[]      // Vietnamese tips for improvement
}
```

### 5.5 Score Interpretation

```
┌─────────────────────────────────────────────────────────────────┐
│                    SCORE INTERPRETATION                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   90-100  ████████████████████  Perfect - Trending combo        │
│                                 🟢 Highly recommended           │
│                                                                 │
│   70-89   ████████████████      Good - Works well               │
│                                 🟢 Recommended                  │
│                                                                 │
│   50-69   ████████████          Acceptable - Could improve      │
│                                 🟡 OK with modifications        │
│                                                                 │
│   30-49   ████████              Clashing - Not recommended      │
│                                 🟠 Avoid if possible            │
│                                                                 │
│   0-29    ████                  Very Poor - Don't wear together │
│                                 🔴 Strongly avoid               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 6. Feature 4: Wardrobe Cleanup

### 6.1 Purpose

Phân tích tủ đồ và gợi ý items cần loại bỏ/donate.

### 6.2 API Method

```dart
Future<Map<String, dynamic>?> getCleanupSuggestions(
  List<ClothingItem> wardrobe,
) async
```

### 6.3 Prompt: `cleanupSuggestion`

```
As a wardrobe organization expert, analyze...

WARDROBE ITEMS:
{wardrobeContext}

Identify:
1. Duplicate items (same type + similar color)
2. Items that don't match wardrobe style
3. Seasonal items not needed

Output JSON:
{
  "duplicates": [
    {"ids": ["id1", "id2"], "reason": "Vietnamese reason"}
  ],
  "mismatched": [
    {"id": "item_id", "reason": "Vietnamese reason"}
  ],
  "suggestions": ["General tip 1", "General tip 2"]
}
```

### 6.4 Output Schema

```typescript
{
  duplicates: Array<{
    ids: string[],      // IDs of duplicate items
    reason: string      // Why they're duplicates
  }>,
  
  mismatched: Array<{
    id: string,         // Item ID
    reason: string      // Why it doesn't fit
  }>,
  
  suggestions: string[] // General organization tips
}
```

### 6.5 Analysis Criteria

```
┌─────────────────────────────────────────────────────────────────┐
│                   CLEANUP ANALYSIS                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  DUPLICATES                                                     │
│  ──────────                                                     │
│  • Same type (shirt, pants, etc.)                              │
│  • Similar color (both navy, both white, etc.)                 │
│  • Similar style (both formal, both casual)                    │
│                                                                 │
│  Example: 2 navy blue formal shirts                            │
│  → Keep 1, donate 1                                            │
│                                                                 │
│  MISMATCHED                                                     │
│  ──────────                                                     │
│  • Style outlier (1 streetwear in formal wardrobe)             │
│  • Color doesn't match anything                                │
│  • Seasonal item in wrong climate                              │
│                                                                 │
│  Example: 1 neon pink shirt in minimalist wardrobe             │
│  → Consider donating                                           │
│                                                                 │
│  GENERAL TIPS                                                   │
│  ────────────                                                   │
│  • "Nên bổ sung thêm quần màu trung tính"                      │
│  • "Tủ đồ thiên về casual, cân nhắc thêm formal"               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 7. JSON Response Handling

### 7.1 Problem

AI có thể trả về:
- JSON thuần túy
- JSON wrapped trong markdown (\`\`\`json ... \`\`\`)
- JSON với text thừa

### 7.2 Solution: `safeParseJson()`

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

String cleanJsonResponse(String raw) {
  // 1. Remove markdown code blocks
  cleaned = cleaned.replaceAll(RegExp(r'```json\s*'), '');
  cleaned = cleaned.replaceAll(RegExp(r'```\s*'), '');
  
  // 2. Find JSON boundaries
  final startIndex = cleaned.indexOf('{');
  final endIndex = cleaned.lastIndexOf('}');
  
  // 3. Extract JSON only
  return cleaned.substring(startIndex, endIndex + 1);
}
```

### 7.3 Flow

```
AI Response: "Here's the analysis:\n```json\n{...}\n```\nHope this helps!"
     │
     ▼
cleanJsonResponse()
     │
     ├── Remove "```json" and "```"
     ├── Find first "{" and last "}"
     └── Extract: "{...}"
     │
     ▼
jsonDecode()
     │
     ▼
Map<String, dynamic>
```

---

## 8. Error Handling

### 8.1 Common Errors

| Error | Cause | Handling |
|-------|-------|----------|
| Not initialized | API key invalid/missing | Return null, log warning |
| Empty response | AI failed to generate | Return null |
| JSON parse error | Malformed response | safeParseJson returns null |
| Timeout | Network/AI slow | 30s timeout, throw exception |

### 8.2 Error Flow

```dart
try {
  // Check initialization
  if (!_isInitialized) {
    print('❌ Gemini not initialized');
    return null;
  }
  
  // Call API with timeout
  final response = await _model.generateContent([...])
    .timeout(Duration(seconds: 30));
  
  // Check response
  if (response.text == null || response.text!.isEmpty) {
    print('❌ Empty response');
    return null;
  }
  
  // Parse JSON safely
  return safeParseJson(response.text!);
  
} catch (e) {
  print('❌ Error: $e');
  return null;
}
```

---

## 9. Performance Considerations

### 9.1 Timeouts

```dart
static const Duration aiTimeout = Duration(seconds: 30);
```

### 9.2 Image Size

```dart
// Trong WardrobeProvider
if (imageBytes.length > 100000) {  // > 100KB
  print('⚠️ Image is large, consider compressing');
}
```

### 9.3 Caching

- Không cache AI responses (mỗi request unique)
- Weather có cache 30 phút
- Items loaded 1 lần khi vào app

---

## 10. API Key Management

### 10.1 Structure

```
lib/utils/
├── constants.dart    # References api_keys.dart
└── api_keys.dart     # Actual keys (GITIGNORED)
```

### 10.2 api_keys.dart (Template)

```dart
class ApiKeys {
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  static const String weatherApiKey = 'YOUR_WEATHER_API_KEY';
}
```

### 10.3 Usage

```dart
// constants.dart
import 'api_keys.dart';

class AppConstants {
  static const String geminiApiKey = ApiKeys.geminiApiKey;
}

// main.dart
geminiService.initialize(AppConstants.geminiApiKey);
```

---

## 📝 Summary

| Feature | Model | Temperature | Output |
|---------|-------|-------------|--------|
| Image Analysis | Vision | 0.3 | type, color, material, styles, seasons |
| Outfit Suggestion | Text | 0.7 | top, bottom, outerwear, footwear, accessories, reason |
| Color Harmony | Text | 0.7 | score, reason, vibe, tips |
| Wardrobe Cleanup | Text | 0.7 | duplicates, mismatched, suggestions |

---

## 🔗 Related Files

- [SERVICES.md](./SERVICES.md) - GeminiService implementation
- [PROVIDERS.md](./PROVIDERS.md) - WardrobeProvider AI methods
- [SCREENS.md](./SCREENS.md) - UI screens using AI features

---

**Đây là file cuối cùng trong bộ documentation!**

📚 **Danh sách đầy đủ:**
1. [ARCHITECTURE.md](./ARCHITECTURE.md) - Kiến trúc tổng quan
2. [MODELS.md](./MODELS.md) - Data Models
3. [PROVIDERS.md](./PROVIDERS.md) - State Management
4. [SERVICES.md](./SERVICES.md) - Backend Services
5. [SCREENS.md](./SCREENS.md) - UI Screens
6. [WIDGETS.md](./WIDGETS.md) - Reusable Widgets
7. [THEME.md](./THEME.md) - Theme & Styling
8. [AI_INTEGRATION.md](./AI_INTEGRATION.md) - AI Integration (file này)
