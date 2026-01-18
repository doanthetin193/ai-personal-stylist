import 'package:flutter_test/flutter_test.dart';
import 'package:ai_personal_stylist/models/outfit.dart';
import 'package:ai_personal_stylist/models/clothing_item.dart';

void main() {
  group('Outfit', () {
    late ClothingItem topItem;
    late ClothingItem bottomItem;
    late ClothingItem footwearItem;

    setUp(() {
      topItem = ClothingItem(
        id: 'top-1',
        userId: 'user-123',
        type: ClothingType.shirt,
        color: 'white',
        styles: [ClothingStyle.casual],
        seasons: [Season.summer],
        createdAt: DateTime.now(),
      );

      bottomItem = ClothingItem(
        id: 'bottom-1',
        userId: 'user-123',
        type: ClothingType.jeans,
        color: 'blue',
        styles: [ClothingStyle.casual],
        seasons: [Season.summer],
        createdAt: DateTime.now(),
      );

      footwearItem = ClothingItem(
        id: 'footwear-1',
        userId: 'user-123',
        type: ClothingType.sneakers,
        color: 'white',
        styles: [ClothingStyle.casual],
        seasons: [Season.summer],
        createdAt: DateTime.now(),
      );
    });

    test('Outfit can be created with all items', () {
      final outfit = Outfit(
        id: 'outfit-1',
        top: topItem,
        bottom: bottomItem,
        footwear: footwearItem,
        occasion: 'Đi chơi',
        reason: 'Phong cách casual phù hợp',
        createdAt: DateTime.now(),
      );

      expect(outfit.top, topItem);
      expect(outfit.bottom, bottomItem);
      expect(outfit.footwear, footwearItem);
      expect(outfit.occasion, 'Đi chơi');
      expect(outfit.reason, 'Phong cách casual phù hợp');
    });

    test('Outfit can be created with optional items null', () {
      final outfit = Outfit(
        id: 'outfit-2',
        top: topItem,
        bottom: bottomItem,
        footwear: null,
        occasion: 'Ở nhà',
        reason: 'Đơn giản thoải mái',
        createdAt: DateTime.now(),
      );

      expect(outfit.top, topItem);
      expect(outfit.bottom, bottomItem);
      expect(outfit.footwear, isNull);
    });

    test('Outfit allItems list contains correct items', () {
      final outfit = Outfit(
        id: 'outfit-3',
        top: topItem,
        bottom: bottomItem,
        footwear: footwearItem,
        occasion: 'Test',
        reason: 'Test reason',
        createdAt: DateTime.now(),
      );

      final items = outfit.allItems;

      expect(items.length, 3);
      expect(items.contains(topItem), true);
      expect(items.contains(bottomItem), true);
      expect(items.contains(footwearItem), true);
    });

    test('Outfit allItems list excludes null items', () {
      final outfit = Outfit(
        id: 'outfit-4',
        top: topItem,
        bottom: null,
        footwear: null,
        occasion: 'Test',
        reason: 'Test reason',
        createdAt: DateTime.now(),
      );

      final items = outfit.allItems;

      expect(items.length, 1);
      expect(items.contains(topItem), true);
    });

    test('Outfit itemCount returns correct count', () {
      final outfit = Outfit(
        id: 'outfit-5',
        top: topItem,
        bottom: bottomItem,
        footwear: footwearItem,
        occasion: 'Test',
        reason: 'Test',
        createdAt: DateTime.now(),
      );

      expect(outfit.itemCount, 3);
    });
  });

  group('ColorHarmonyResult', () {
    test('ColorHarmonyResult can be created with all fields', () {
      final result = ColorHarmonyResult(
        score: 85,
        reason: 'Hai màu này phối hợp tốt',
        vibe: 'Casual & Balanced',
        tips: ['Thêm phụ kiện', 'Phù hợp đi chơi'],
      );

      expect(result.score, 85);
      expect(result.reason, 'Hai màu này phối hợp tốt');
      expect(result.vibe, 'Casual & Balanced');
      expect(result.tips.length, 2);
    });

    test('ColorHarmonyResult score is within valid range', () {
      final result = ColorHarmonyResult(
        score: 75,
        reason: 'Test',
        vibe: 'Test vibe',
        tips: [],
      );

      expect(result.score >= 0 && result.score <= 100, true);
    });

    test('ColorHarmonyResult can have empty tips', () {
      final result = ColorHarmonyResult(
        score: 50,
        reason: 'Average match',
        vibe: 'Neutral',
        tips: [],
      );

      expect(result.tips.isEmpty, true);
    });

    test('ColorHarmonyResult.fromJson works correctly', () {
      final json = {
        'score': 80,
        'reason': 'Good match',
        'vibe': 'Stylish',
        'tips': ['Tip 1', 'Tip 2'],
      };

      final result = ColorHarmonyResult.fromJson(json);

      expect(result.score, 80);
      expect(result.reason, 'Good match');
      expect(result.vibe, 'Stylish');
      expect(result.tips.length, 2);
    });

    test('ColorHarmonyResult.fromJson handles missing fields', () {
      final json = <String, dynamic>{};

      final result = ColorHarmonyResult.fromJson(json);

      expect(result.score, 50);
      expect(result.reason, 'Không có thông tin');
      expect(result.vibe, 'Neutral');
      expect(result.tips.isEmpty, true);
    });
  });
}
