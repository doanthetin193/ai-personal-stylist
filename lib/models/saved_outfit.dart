import 'package:cloud_firestore/cloud_firestore.dart';

class SavedOutfit {
  final String id;
  final String userId;
  final String? name;
  final String? topId;
  final String? bottomId;
  final String? outerwearId;
  final String? footwearId;
  final List<String> accessoryIds;
  final String source; // 'tinder', 'ai', 'manual'
  final DateTime createdAt;

  SavedOutfit({
    required this.id,
    required this.userId,
    this.name,
    this.topId,
    this.bottomId,
    this.outerwearId,
    this.footwearId,
    this.accessoryIds = const [],
    required this.source,
    required this.createdAt,
  });

  factory SavedOutfit.fromJson(Map<String, dynamic> json, String id) {
    return SavedOutfit(
      id: id,
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String?,
      topId: json['topId'] as String?,
      bottomId: json['bottomId'] as String?,
      outerwearId: json['outerwearId'] as String?,
      footwearId: json['footwearId'] as String?,
      accessoryIds: (json['accessoryIds'] as List<dynamic>?)?.cast<String>() ?? [],
      source: json['source'] as String? ?? 'manual',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'topId': topId,
      'bottomId': bottomId,
      'outerwearId': outerwearId,
      'footwearId': footwearId,
      'accessoryIds': accessoryIds,
      'source': source,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
