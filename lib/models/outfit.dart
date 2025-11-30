import 'clothing_item.dart';

/// Model cho một outfit được gợi ý
class Outfit {
  final String id;
  final ClothingItem? top;
  final ClothingItem? bottom;
  final ClothingItem? outerwear;
  final ClothingItem? footwear;
  final List<ClothingItem> accessories;
  final String occasion;
  final String reason;
  final int? colorScore;
  final DateTime createdAt;

  Outfit({
    required this.id,
    this.top,
    this.bottom,
    this.outerwear,
    this.footwear,
    this.accessories = const [],
    required this.occasion,
    required this.reason,
    this.colorScore,
    required this.createdAt,
  });

  /// Lấy tất cả items trong outfit
  List<ClothingItem> get allItems {
    final items = <ClothingItem>[];
    if (top != null) items.add(top!);
    if (bottom != null) items.add(bottom!);
    if (outerwear != null) items.add(outerwear!);
    if (footwear != null) items.add(footwear!);
    items.addAll(accessories);
    return items;
  }

  /// Số lượng items
  int get itemCount => allItems.length;

  /// Copy with
  Outfit copyWith({
    String? id,
    ClothingItem? top,
    ClothingItem? bottom,
    ClothingItem? outerwear,
    ClothingItem? footwear,
    List<ClothingItem>? accessories,
    String? occasion,
    String? reason,
    int? colorScore,
    DateTime? createdAt,
  }) {
    return Outfit(
      id: id ?? this.id,
      top: top ?? this.top,
      bottom: bottom ?? this.bottom,
      outerwear: outerwear ?? this.outerwear,
      footwear: footwear ?? this.footwear,
      accessories: accessories ?? this.accessories,
      occasion: occasion ?? this.occasion,
      reason: reason ?? this.reason,
      colorScore: colorScore ?? this.colorScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Model cho Color Harmony Result
class ColorHarmonyResult {
  final int score;
  final String reason;
  final String vibe;
  final List<String> tips;

  ColorHarmonyResult({
    required this.score,
    required this.reason,
    required this.vibe,
    this.tips = const [],
  });

  factory ColorHarmonyResult.fromJson(Map<String, dynamic> json) {
    return ColorHarmonyResult(
      score: json['score'] ?? 50,
      reason: json['reason'] ?? 'Không có thông tin',
      vibe: json['vibe'] ?? 'Neutral',
      tips: (json['tips'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}
