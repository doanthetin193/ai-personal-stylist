import 'package:cloud_firestore/cloud_firestore.dart';

import 'clothing_item.dart';
import 'outfit.dart';
import 'weather.dart';

enum PlanActivityType {
  leisure,
  work,
  travel,
  outdoor,
  indoor;

  String get displayName {
    switch (this) {
      case PlanActivityType.leisure:
        return 'Đi chơi';
      case PlanActivityType.work:
        return 'Công việc';
      case PlanActivityType.travel:
        return 'Du lịch';
      case PlanActivityType.outdoor:
        return 'Ngoài trời';
      case PlanActivityType.indoor:
        return 'Trong nhà';
    }
  }

  String get firestoreValue => name;

  static PlanActivityType fromString(String? value) {
    if (value == null || value.isEmpty) return PlanActivityType.leisure;
    return PlanActivityType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => PlanActivityType.leisure,
    );
  }
}

class PlanForecastSnapshot {
  final DateTime targetDate;
  final double minTemp;
  final double maxTemp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final double rainProbability;
  final String description;
  final String cityName;
  final DateTime generatedAt;
  final int daysAhead;

  PlanForecastSnapshot({
    required this.targetDate,
    required this.minTemp,
    required this.maxTemp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.rainProbability,
    required this.description,
    required this.cityName,
    required this.generatedAt,
    required this.daysAhead,
  });

  factory PlanForecastSnapshot.fromForecastInfo(ForecastInfo forecast) {
    return PlanForecastSnapshot(
      targetDate: forecast.targetDate,
      minTemp: forecast.minTemp,
      maxTemp: forecast.maxTemp,
      feelsLike: forecast.feelsLike,
      humidity: forecast.humidity,
      windSpeed: forecast.windSpeed,
      rainProbability: forecast.rainProbability,
      description: forecast.description,
      cityName: forecast.cityName,
      generatedAt: forecast.generatedAt,
      daysAhead: forecast.daysAhead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetDate': Timestamp.fromDate(targetDate),
      'minTemp': minTemp,
      'maxTemp': maxTemp,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'rainProbability': rainProbability,
      'description': description,
      'cityName': cityName,
      'generatedAt': Timestamp.fromDate(generatedAt),
      'daysAhead': daysAhead,
    };
  }

  factory PlanForecastSnapshot.fromJson(Map<String, dynamic> json) {
    return PlanForecastSnapshot(
      targetDate:
          (json['targetDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      minTemp: ((json['minTemp'] ?? 0) as num).toDouble(),
      maxTemp: ((json['maxTemp'] ?? 0) as num).toDouble(),
      feelsLike: ((json['feelsLike'] ?? 0) as num).toDouble(),
      humidity: ((json['humidity'] ?? 0) as num).toInt(),
      windSpeed: ((json['windSpeed'] ?? 0) as num).toDouble(),
      rainProbability: ((json['rainProbability'] ?? 0) as num).toDouble().clamp(
        0.0,
        1.0,
      ),
      description: (json['description'] ?? '').toString(),
      cityName: (json['cityName'] ?? '').toString(),
      generatedAt:
          (json['generatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      daysAhead: ((json['daysAhead'] ?? 0) as num).toInt(),
    );
  }

  double get avgTemp => (minTemp + maxTemp) / 2;
}

class PlannedOutfitOption {
  final String key;
  final String title;
  final String scenarioNote;
  final String reason;
  final String? topId;
  final String? bottomId;
  final String? outerwearId;
  final String? footwearId;
  final List<String> accessoryIds;

  PlannedOutfitOption({
    required this.key,
    required this.title,
    required this.scenarioNote,
    required this.reason,
    this.topId,
    this.bottomId,
    this.outerwearId,
    this.footwearId,
    this.accessoryIds = const [],
  });

  factory PlannedOutfitOption.fromOutfit({
    required String key,
    required String title,
    required String scenarioNote,
    required Outfit outfit,
  }) {
    return PlannedOutfitOption(
      key: key,
      title: title,
      scenarioNote: scenarioNote,
      reason: outfit.reason,
      topId: outfit.top?.id,
      bottomId: outfit.bottom?.id,
      outerwearId: outfit.outerwear?.id,
      footwearId: outfit.footwear?.id,
      accessoryIds: outfit.accessories.map((e) => e.id).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'title': title,
      'scenarioNote': scenarioNote,
      'reason': reason,
      'topId': topId,
      'bottomId': bottomId,
      'outerwearId': outerwearId,
      'footwearId': footwearId,
      'accessoryIds': accessoryIds,
    };
  }

  factory PlannedOutfitOption.fromJson(Map<String, dynamic> json) {
    return PlannedOutfitOption(
      key: (json['key'] ?? 'primary').toString(),
      title: (json['title'] ?? 'Phương án').toString(),
      scenarioNote: (json['scenarioNote'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      topId: json['topId']?.toString(),
      bottomId: json['bottomId']?.toString(),
      outerwearId: json['outerwearId']?.toString(),
      footwearId: json['footwearId']?.toString(),
      accessoryIds: (json['accessoryIds'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Outfit toOutfit({
    required List<ClothingItem> wardrobe,
    required String occasion,
  }) {
    ClothingItem? byId(String? id) {
      if (id == null || id.isEmpty) return null;
      final matches = wardrobe.where((item) => item.id == id);
      return matches.isNotEmpty ? matches.first : null;
    }

    final accessories = accessoryIds
        .map(byId)
        .whereType<ClothingItem>()
        .toList();

    return Outfit(
      id: '${key}_${DateTime.now().microsecondsSinceEpoch}',
      top: byId(topId),
      bottom: byId(bottomId),
      outerwear: byId(outerwearId),
      footwear: byId(footwearId),
      accessories: accessories,
      occasion: occasion,
      reason: reason,
      createdAt: DateTime.now(),
    );
  }
}

class SmartOutfitPlan {
  final String id;
  final String userId;
  final DateTime eventDateTime;
  final String location;
  final PlanActivityType activityType;
  final String? customActivity;
  final String? dressCode;
  final PlanForecastSnapshot forecastSnapshot;
  final List<PlannedOutfitOption> options;
  final List<String> prepChecklist;
  final bool needsAdjustment;
  final String? adjustmentReason;
  final List<String> completedAutoCheckpoints;
  final String? lastAutoUpdateCheckpoint;
  final DateTime? lastAutoUpdatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  SmartOutfitPlan({
    required this.id,
    required this.userId,
    required this.eventDateTime,
    required this.location,
    required this.activityType,
    this.customActivity,
    this.dressCode,
    required this.forecastSnapshot,
    required this.options,
    required this.prepChecklist,
    required this.needsAdjustment,
    this.adjustmentReason,
    required this.completedAutoCheckpoints,
    this.lastAutoUpdateCheckpoint,
    this.lastAutoUpdatedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  String get eventLabel {
    final dd = eventDateTime.day.toString().padLeft(2, '0');
    final mm = eventDateTime.month.toString().padLeft(2, '0');
    final hh = eventDateTime.hour.toString().padLeft(2, '0');
    final mn = eventDateTime.minute.toString().padLeft(2, '0');
    return '$dd/$mm ${eventDateTime.year} • $hh:$mn';
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'eventDateTime': Timestamp.fromDate(eventDateTime),
      'location': location,
      'activityType': activityType.firestoreValue,
      'customActivity': customActivity,
      'dressCode': dressCode,
      'forecastSnapshot': forecastSnapshot.toJson(),
      'options': options.map((e) => e.toJson()).toList(),
      'prepChecklist': prepChecklist,
      'needsAdjustment': needsAdjustment,
      'adjustmentReason': adjustmentReason,
      'completedAutoCheckpoints': completedAutoCheckpoints,
      'lastAutoUpdateCheckpoint': lastAutoUpdateCheckpoint,
      'lastAutoUpdatedAt': lastAutoUpdatedAt != null
          ? Timestamp.fromDate(lastAutoUpdatedAt!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory SmartOutfitPlan.fromJson(Map<String, dynamic> json, String docId) {
    return SmartOutfitPlan(
      id: docId,
      userId: (json['userId'] ?? '').toString(),
      eventDateTime:
          (json['eventDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: (json['location'] ?? '').toString(),
      activityType: PlanActivityType.fromString(
        json['activityType']?.toString(),
      ),
      customActivity: json['customActivity']?.toString(),
      dressCode: json['dressCode']?.toString(),
      forecastSnapshot: PlanForecastSnapshot.fromJson(
        (json['forecastSnapshot'] as Map<String, dynamic>? ?? {}),
      ),
      options: (json['options'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(PlannedOutfitOption.fromJson)
          .toList(),
      prepChecklist: (json['prepChecklist'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      needsAdjustment: (json['needsAdjustment'] ?? false) == true,
      adjustmentReason: json['adjustmentReason']?.toString(),
      completedAutoCheckpoints:
          (json['completedAutoCheckpoints'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
      lastAutoUpdateCheckpoint: json['lastAutoUpdateCheckpoint']?.toString(),
      lastAutoUpdatedAt: (json['lastAutoUpdatedAt'] as Timestamp?)?.toDate(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  SmartOutfitPlan copyWith({
    String? id,
    String? userId,
    DateTime? eventDateTime,
    String? location,
    PlanActivityType? activityType,
    String? customActivity,
    String? dressCode,
    PlanForecastSnapshot? forecastSnapshot,
    List<PlannedOutfitOption>? options,
    List<String>? prepChecklist,
    bool? needsAdjustment,
    String? adjustmentReason,
    List<String>? completedAutoCheckpoints,
    String? lastAutoUpdateCheckpoint,
    DateTime? lastAutoUpdatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SmartOutfitPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventDateTime: eventDateTime ?? this.eventDateTime,
      location: location ?? this.location,
      activityType: activityType ?? this.activityType,
      customActivity: customActivity ?? this.customActivity,
      dressCode: dressCode ?? this.dressCode,
      forecastSnapshot: forecastSnapshot ?? this.forecastSnapshot,
      options: options ?? this.options,
      prepChecklist: prepChecklist ?? this.prepChecklist,
      needsAdjustment: needsAdjustment ?? this.needsAdjustment,
      adjustmentReason: adjustmentReason ?? this.adjustmentReason,
      completedAutoCheckpoints:
          completedAutoCheckpoints ?? this.completedAutoCheckpoints,
      lastAutoUpdateCheckpoint:
          lastAutoUpdateCheckpoint ?? this.lastAutoUpdateCheckpoint,
      lastAutoUpdatedAt: lastAutoUpdatedAt ?? this.lastAutoUpdatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
