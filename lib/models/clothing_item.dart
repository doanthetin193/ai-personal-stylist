import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum cho loại quần áo
enum ClothingType {
  shirt,
  tshirt,
  pants,
  jeans,
  shorts,
  jacket,
  hoodie,
  dress,
  skirt,
  shoes,
  sneakers,
  accessory,
  bag,
  hat,
  other;

  String get displayName {
    switch (this) {
      case ClothingType.shirt:
        return 'Áo sơ mi';
      case ClothingType.tshirt:
        return 'Áo thun';
      case ClothingType.pants:
        return 'Quần tây';
      case ClothingType.jeans:
        return 'Quần jeans';
      case ClothingType.shorts:
        return 'Quần short';
      case ClothingType.jacket:
        return 'Áo khoác';
      case ClothingType.hoodie:
        return 'Áo hoodie';
      case ClothingType.dress:
        return 'Váy đầm';
      case ClothingType.skirt:
        return 'Chân váy';
      case ClothingType.shoes:
        return 'Giày';
      case ClothingType.sneakers:
        return 'Giày sneaker';
      case ClothingType.accessory:
        return 'Phụ kiện';
      case ClothingType.bag:
        return 'Túi xách';
      case ClothingType.hat:
        return 'Mũ/Nón';
      case ClothingType.other:
        return 'Khác';
    }
  }

  /// Phân loại để phối đồ
  String get category {
    switch (this) {
      case ClothingType.shirt:
      case ClothingType.tshirt:
        return 'top';
      case ClothingType.hoodie:
      case ClothingType.jacket:
        return 'outerwear';
      case ClothingType.pants:
      case ClothingType.jeans:
      case ClothingType.shorts:
      case ClothingType.skirt:
        return 'bottom';
      case ClothingType.dress:
        return 'dress';
      case ClothingType.shoes:
      case ClothingType.sneakers:
        return 'footwear';
      case ClothingType.bag:
        return 'bag';
      case ClothingType.hat:
        return 'hat';
      case ClothingType.accessory:
        return 'accessory';
      case ClothingType.other:
        return 'other';
    }
  }

  static ClothingType fromString(String value) {
    return ClothingType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ClothingType.other,
    );
  }
}

/// Enum cho style
enum ClothingStyle {
  casual,
  formal,
  streetwear,
  vintage,
  sporty,
  elegant,
  bohemian,
  minimalist;

  String get displayName {
    switch (this) {
      case ClothingStyle.casual:
        return 'Casual';
      case ClothingStyle.formal:
        return 'Formal';
      case ClothingStyle.streetwear:
        return 'Streetwear';
      case ClothingStyle.vintage:
        return 'Vintage';
      case ClothingStyle.sporty:
        return 'Sporty';
      case ClothingStyle.elegant:
        return 'Elegant';
      case ClothingStyle.bohemian:
        return 'Bohemian';
      case ClothingStyle.minimalist:
        return 'Minimalist';
    }
  }

  static ClothingStyle fromString(String value) {
    return ClothingStyle.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ClothingStyle.casual,
    );
  }
}

/// Enum cho mùa
enum Season {
  spring,
  summer,
  fall,
  winter;

  String get displayName {
    switch (this) {
      case Season.spring:
        return 'Xuân';
      case Season.summer:
        return 'Hè';
      case Season.fall:
        return 'Thu';
      case Season.winter:
        return 'Đông';
    }
  }

  static Season fromString(String value) {
    return Season.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => Season.summer,
    );
  }
}

/// Model chính cho item quần áo
class ClothingItem {
  final String id;
  final String userId;
  final String? imageBase64; // Lưu ảnh dạng Base64 vào Firestore
  final ClothingType type;
  final String color;
  final String? material;
  final List<ClothingStyle> styles;
  final List<Season> seasons;
  final String? brand;
  final String? notes;
  final DateTime createdAt;
  final DateTime? lastWorn;
  final int wearCount;
  final bool isFavorite;

  ClothingItem({
    required this.id,
    required this.userId,
    this.imageBase64,
    required this.type,
    required this.color,
    this.material,
    required this.styles,
    required this.seasons,
    this.brand,
    this.notes,
    required this.createdAt,
    this.lastWorn,
    this.wearCount = 0,
    this.isFavorite = false,
  });

  /// Tạo từ JSON (Firestore)
  factory ClothingItem.fromJson(Map<String, dynamic> json, String docId) {
    return ClothingItem(
      id: docId,
      userId: json['userId'] ?? '',
      imageBase64: json['imageBase64'],
      type: ClothingType.fromString(json['type'] ?? 'other'),
      color: json['color'] ?? 'unknown',
      material: json['material'],
      styles: (json['styles'] as List<dynamic>?)
              ?.map((s) => ClothingStyle.fromString(s.toString()))
              .toList() ??
          [ClothingStyle.casual],
      seasons: (json['seasons'] as List<dynamic>?)
              ?.map((s) => Season.fromString(s.toString()))
              .toList() ??
          [Season.summer],
      brand: json['brand'],
      notes: json['notes'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastWorn: (json['lastWorn'] as Timestamp?)?.toDate(),
      wearCount: json['wearCount'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  /// Chuyển sang JSON để lưu Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'imageBase64': imageBase64,
      'type': type.name,
      'color': color,
      'material': material,
      'styles': styles.map((s) => s.name).toList(),
      'seasons': seasons.map((s) => s.name).toList(),
      'brand': brand,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastWorn': lastWorn != null ? Timestamp.fromDate(lastWorn!) : null,
      'wearCount': wearCount,
      'isFavorite': isFavorite,
    };
  }

  /// Tạo description ngắn gọn cho AI
  String toAIDescription() {
    final styleStr = styles.map((s) => s.name).join(', ');
    final seasonStr = seasons.map((s) => s.name).join(', ');
    return 'ID:$id | ${type.name} | $color | $styleStr | Seasons: $seasonStr';
  }

  /// Copy with
  ClothingItem copyWith({
    String? id,
    String? userId,
    String? imageBase64,
    ClothingType? type,
    String? color,
    String? material,
    List<ClothingStyle>? styles,
    List<Season>? seasons,
    String? brand,
    String? notes,
    DateTime? createdAt,
    DateTime? lastWorn,
    int? wearCount,
    bool? isFavorite,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageBase64: imageBase64 ?? this.imageBase64,
      type: type ?? this.type,
      color: color ?? this.color,
      material: material ?? this.material,
      styles: styles ?? this.styles,
      seasons: seasons ?? this.seasons,
      brand: brand ?? this.brand,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      lastWorn: lastWorn ?? this.lastWorn,
      wearCount: wearCount ?? this.wearCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
