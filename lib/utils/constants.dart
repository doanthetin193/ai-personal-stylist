import 'api_keys.dart';

/// Constants cho toàn app
class AppConstants {
  // API Keys - Import từ file riêng (đã gitignore)
  static const String geminiApiKey = ApiKeys.geminiApiKey;
  static const String groqApiKey = ApiKeys.groqApiKey;
  static const String weatherApiKey = ApiKeys.weatherApiKey;

  // Weather API
  static const String weatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';
  static const String defaultCity = 'Quy Nhon';
  static const String defaultCountryCode = 'VN';

  // Firebase Collections
  static const String itemsCollection = 'items';
  static const String usersCollection = 'users';

  // Cache Duration
  static const Duration weatherCacheDuration = Duration(minutes: 30);

  // AI Settings
  static const Duration aiTimeout = Duration(seconds: 30);
}

/// Occasions/Events cho outfit
class Occasions {
  static const List<Map<String, String>> list = [
    {'id': 'daily', 'name': 'Hàng ngày', 'icon': '☀️'},
    {'id': 'work', 'name': 'Đi làm', 'icon': '💼'},
    {'id': 'date', 'name': 'Hẹn hò', 'icon': '💕'},
    {'id': 'party', 'name': 'Tiệc tùng', 'icon': '🎉'},
    {'id': 'sport', 'name': 'Thể thao', 'icon': '🏃'},
    {'id': 'travel', 'name': 'Du lịch', 'icon': '✈️'},
    {'id': 'formal', 'name': 'Sự kiện trang trọng', 'icon': '🎩'},
    {'id': 'beach', 'name': 'Đi biển', 'icon': '🏖️'},
    {'id': 'casual', 'name': 'Cafe/Đi chơi', 'icon': '☕'},
  ];

  static String getName(String id) {
    return list.firstWhere(
      (o) => o['id'] == id,
      orElse: () => {'name': 'Khác'},
    )['name']!;
  }
}

/// AI Prompts
class AIPrompts {
  /// Prompt phân tích ảnh quần áo - Cải thiện độ chính xác
  static const String analyzeClothing = '''
Bạn là chuyên gia thời trang. Phân tích kỹ ảnh này và trả về JSON chính xác.

ĐẦU TIÊN - KIỂM TRA ẢNH:
- Nếu ảnh KHÔNG PHẢI quần áo/giày dép/phụ kiện thời trang → is_clothing = false
- Ví dụ ảnh KHÔNG hợp lệ: đồ ăn, phong cảnh, con người (không có quần áo rõ ràng), đồ vật, con vật, xe cộ, v.v.
- Chỉ chấp nhận: áo, quần, váy, giày, dép, túi xách, mũ nón, phụ kiện thời trang

QUAN TRỌNG - PHÂN BIỆT LOẠI ÁO:
- "tshirt": Áo thun (cổ tròn hoặc cổ tim, KHÔNG có cổ lật, KHÔNG có nút, thường làm từ cotton mềm)
- "polo": Áo polo (có cổ lật/bẻ, CHỈ CÓ 2-3 NÚT Ở NGỰC, vải pique/cotton, thường có logo)
- "shirt": Áo sơ mi (có cổ áo cứng/lật, có HÀNG NÚT DÀI TỪ CỔ ĐẾN GẤU ÁO, vải cứng hơn)
- "hoodie": Áo hoodie (có mũ trùm đầu)
- "jacket": Áo khoác (mặc ngoài, có khóa kéo hoặc nút)

QUAN TRỌNG - MÀU SẮC:
- Nếu áo có NHIỀU MÀU (sọc, kẻ caro, họa tiết), ghi tất cả màu chính, ví dụ: "trắng sọc đen", "đen trắng", "xanh kẻ caro trắng"
- Nếu áo có họa tiết/hoa văn, mô tả: "trắng họa tiết đen", "xanh navy hoa trắng"
- Dùng tiếng Việt cho màu sắc

Trả về JSON với format CHÍNH XÁC như sau:
{
  "is_clothing": true/false,
  "type": "shirt|tshirt|polo|pants|jeans|shorts|jacket|hoodie|dress|skirt|shoes|sneakers|accessory|bag|hat|other",
  "color": "màu chính bằng tiếng Việt",
  "material": "cotton|denim|polyester|leather|wool|silk|linen|synthetic|unknown",
  "styles": ["casual", "formal", "streetwear", "vintage", "sporty", "elegant", "minimalist"],
  "seasons": ["spring", "summer", "fall", "winter"]
}

Quy tắc:
- is_clothing: TRUE nếu là quần áo/giày dép/phụ kiện, FALSE nếu không phải
- Nếu is_clothing = false, các field khác có thể để giá trị mặc định
- type: Chọn CHÍNH XÁC loại quần áo
- color: Tiếng Việt, mô tả đầy đủ nếu có nhiều màu/họa tiết
- material: Dự đoán chất liệu dựa trên hình ảnh
- styles: Mảng 1-3 phong cách phù hợp
- seasons: Mảng các mùa phù hợp để mặc

CHỈ TRẢ VỀ JSON. Không markdown, không giải thích, không text thừa.
''';

  /// Prompt phối đồ
  static String suggestOutfit({
    required String wardrobeContext,
    required String weatherContext,
    required String occasion,
    String? stylePreference,
    String? genderProfile,
    String? styleProfile,
  }) {
    final styleContext = stylePreference != null
        ? '\nSTYLE PREFERENCE:\n$stylePreference\n'
        : '';
    final genderContext = genderProfile != null
        ? '\nUSER GENDER PROFILE:\n$genderProfile\n'
        : '';
    final styleProfileContext = styleProfile != null
        ? '\nUSER STYLE PROFILE:\n$styleProfile\n'
        : '';
    return '''
You are a professional fashion stylist. Based on the wardrobe items and conditions below, suggest the best outfit.

WARDROBE ITEMS:
$wardrobeContext

WEATHER:
$weatherContext

OCCASION: $occasion
$styleProfileContext
$genderContext
$styleContext

PRIORITY ORDER (highest to lowest):
1) USER STYLE PROFILE
2) USER GENDER PROFILE
3) STYLE PREFERENCE (fit only, secondary)

If any signals conflict, follow the higher-priority one.
Select items that:
1. Match the weather conditions
2. Are appropriate for the occasion
3. Have harmonious colors
4. Create a cohesive style
5. Respect the user's style profile (masculine/feminine/unisex/flexible)
6. Respect the user's gender profile (if provided)
7. Use style preference only to fine-tune fit/silhouette

Return ONLY a valid JSON object:
{
  "top": "item_id or null",
  "bottom": "item_id or null",
  "outerwear": "item_id or null",
  "footwear": "item_id or null",
  "accessories": ["item_id", ...] or [],
  "reason": "Brief explanation in Vietnamese why these items work together (2-3 sentences)"
}

Rules:
- Use exact item IDs from the wardrobe
- If no suitable item exists for a category, use null
- For dress/fullbody items, put in "top" and set "bottom" to null
- If style profile is masculine, avoid selecting dress/skirt items
- If style profile is unisex, prioritize neutral pieces and avoid extreme styling
- If style profile is flexible, you may mix masculine/feminine pieces when harmonious
- Use style preference only as a fit refinement (loose/regular/fitted), never to override style profile
- Reason should mention color harmony, style match, and weather appropriateness

Return ONLY the JSON. No markdown, no extra text.
''';
  }

  /// Prompt chấm điểm hợp màu
  static String colorHarmony(String item1Desc, String item2Desc) {
    return '''
As a color theory expert, evaluate the color harmony between these two clothing items:

Item 1: $item1Desc
Item 2: $item2Desc

Return ONLY a valid JSON object:
{
  "score": 0-100,
  "reason": "Explanation in Vietnamese why these colors work or don't work together",
  "vibe": "The overall aesthetic vibe (e.g., 'Classic & Elegant', 'Bold & Modern', 'Earthy & Natural')",
  "tips": ["Tip 1 in Vietnamese", "Tip 2 in Vietnamese"]
}

Scoring guide:
- 90-100: Perfect harmony, trending combination
- 70-89: Good match, works well together
- 50-69: Acceptable, could be improved
- 30-49: Clashing, not recommended
- 0-29: Very poor combination

Return ONLY the JSON. No markdown, no extra text.
''';
  }

  /// Prompt gợi ý dọn tủ đồ
  static String cleanupSuggestion(String wardrobeContext) {
    return '''
As a wardrobe organization expert, analyze this wardrobe and suggest items that could be removed or donated.

WARDROBE ITEMS:
$wardrobeContext

Identify:
1. Duplicate items (same type and similar color)
2. Items that don't match any style in the wardrobe
3. Seasonal items that may not be needed

Return ONLY a valid JSON object:
{
  "duplicates": [
    {"ids": ["id1", "id2"], "reason": "Why they're duplicates in Vietnamese"}
  ],
  "mismatched": [
    {"id": "item_id", "reason": "Why it doesn't fit in Vietnamese"}
  ],
  "suggestions": ["General tip 1 in Vietnamese", "General tip 2 in Vietnamese"]
}

Return ONLY the JSON. No markdown, no extra text.
''';
  }
}
