import 'dart:convert';

/// Helper để clean JSON từ AI response
String cleanJsonResponse(String raw) {
  String cleaned = raw.trim();
  
  // Remove markdown code blocks
  cleaned = cleaned.replaceAll(RegExp(r'```json\s*'), '');
  cleaned = cleaned.replaceAll(RegExp(r'```\s*'), '');
  
  // Remove leading/trailing whitespace
  cleaned = cleaned.trim();
  
  // Find JSON object boundaries
  final startIndex = cleaned.indexOf('{');
  final endIndex = cleaned.lastIndexOf('}');
  
  if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
    cleaned = cleaned.substring(startIndex, endIndex + 1);
  }
  
  return cleaned;
}

/// Parse JSON an toàn với fallback
Map<String, dynamic>? safeParseJson(String raw) {
  try {
    final cleaned = cleanJsonResponse(raw);
    return jsonDecode(cleaned) as Map<String, dynamic>;
  } catch (e) {
    print('JSON Parse Error: $e');
    print('Raw response: $raw');
    return null;
  }
}

/// Format temperature
String formatTemperature(double temp) {
  return '${temp.round()}°C';
}

/// Format date tiếng Việt
String formatDateVN(DateTime date) {
  final weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  final weekday = weekdays[date.weekday % 7];
  return '$weekday, ${date.day}/${date.month}/${date.year}';
}

/// Format relative time
String formatRelativeTime(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  
  if (diff.inDays == 0) {
    if (diff.inHours == 0) {
      return '${diff.inMinutes} phút trước';
    }
    return '${diff.inHours} giờ trước';
  } else if (diff.inDays == 1) {
    return 'Hôm qua';
  } else if (diff.inDays < 7) {
    return '${diff.inDays} ngày trước';
  } else if (diff.inDays < 30) {
    return '${(diff.inDays / 7).floor()} tuần trước';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Capitalize first letter
String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

/// Get color name in Vietnamese
/// Hỗ trợ cả input tiếng Anh và tiếng Việt
String getColorNameVN(String color) {
  // Nếu đã là tiếng Việt hoặc có nhiều từ (ví dụ "trắng sọc đen"), giữ nguyên
  if (color.contains(' ') || _isVietnameseColor(color)) {
    return capitalize(color);
  }
  
  final colorMap = {
    'red': 'Đỏ',
    'blue': 'Xanh dương',
    'green': 'Xanh lá',
    'yellow': 'Vàng',
    'orange': 'Cam',
    'purple': 'Tím',
    'pink': 'Hồng',
    'black': 'Đen',
    'white': 'Trắng',
    'gray': 'Xám',
    'grey': 'Xám',
    'brown': 'Nâu',
    'beige': 'Be',
    'navy': 'Xanh navy',
    'cream': 'Kem',
    'khaki': 'Kaki',
    'maroon': 'Đỏ đậm',
    'olive': 'Xanh olive',
    'teal': 'Xanh ngọc',
    'coral': 'San hô',
    'burgundy': 'Đỏ rượu',
  };
  
  return colorMap[color.toLowerCase()] ?? capitalize(color);
}

/// Kiểm tra xem màu có phải tiếng Việt không
bool _isVietnameseColor(String color) {
  final vietnameseColors = [
    'đỏ', 'xanh', 'vàng', 'cam', 'tím', 'hồng', 'đen', 'trắng', 
    'xám', 'nâu', 'be', 'kem', 'navy', 'sọc', 'kẻ', 'họa tiết'
  ];
  final lowerColor = color.toLowerCase();
  return vietnameseColors.any((vn) => lowerColor.contains(vn));
}

/// Get material name in Vietnamese
String getMaterialNameVN(String material) {
  final materialMap = {
    'cotton': 'Cotton',
    'denim': 'Denim/Bò',
    'polyester': 'Polyester',
    'leather': 'Da',
    'wool': 'Len',
    'silk': 'Lụa',
    'linen': 'Vải lanh',
    'synthetic': 'Tổng hợp',
    'unknown': 'Không xác định',
  };
  
  return materialMap[material.toLowerCase()] ?? capitalize(material);
}

/// Get greeting based on time
String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Chào buổi sáng';
  if (hour < 18) return 'Chào buổi chiều';
  return 'Chào buổi tối';
}

