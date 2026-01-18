import 'package:flutter_test/flutter_test.dart';
import 'package:ai_personal_stylist/models/clothing_item.dart';

void main() {
  group('ClothingType', () {
    test('fromString returns correct type for valid input', () {
      expect(ClothingType.fromString('shirt'), ClothingType.shirt);
      expect(ClothingType.fromString('tshirt'), ClothingType.tshirt);
      expect(ClothingType.fromString('pants'), ClothingType.pants);
      expect(ClothingType.fromString('jeans'), ClothingType.jeans);
      expect(ClothingType.fromString('jacket'), ClothingType.jacket);
      expect(ClothingType.fromString('dress'), ClothingType.dress);
    });

    test('fromString is case insensitive', () {
      expect(ClothingType.fromString('SHIRT'), ClothingType.shirt);
      expect(ClothingType.fromString('Jeans'), ClothingType.jeans);
    });

    test('fromString returns other for invalid input', () {
      expect(ClothingType.fromString('invalid'), ClothingType.other);
      expect(ClothingType.fromString(''), ClothingType.other);
    });

    test('displayName returns Vietnamese names', () {
      expect(ClothingType.shirt.displayName, 'Áo sơ mi');
      expect(ClothingType.tshirt.displayName, 'Áo thun');
      expect(ClothingType.pants.displayName, 'Quần tây');
      expect(ClothingType.jeans.displayName, 'Quần jeans');
      expect(ClothingType.jacket.displayName, 'Áo khoác');
      expect(ClothingType.dress.displayName, 'Váy đầm');
      expect(ClothingType.shoes.displayName, 'Giày');
      expect(ClothingType.sneakers.displayName, 'Giày sneaker');
    });

    test('category returns correct group', () {
      expect(ClothingType.shirt.category, 'top');
      expect(ClothingType.tshirt.category, 'top');
      expect(ClothingType.pants.category, 'bottom');
      expect(ClothingType.jeans.category, 'bottom');
      expect(ClothingType.jacket.category, 'outerwear');
      expect(ClothingType.dress.category, 'dress');
      expect(ClothingType.shoes.category, 'footwear');
      expect(ClothingType.sneakers.category, 'footwear');
    });
  });

  group('ClothingStyle', () {
    test('fromString returns correct style', () {
      expect(ClothingStyle.fromString('casual'), ClothingStyle.casual);
      expect(ClothingStyle.fromString('formal'), ClothingStyle.formal);
      expect(ClothingStyle.fromString('streetwear'), ClothingStyle.streetwear);
    });

    test('fromString is case insensitive', () {
      expect(ClothingStyle.fromString('CASUAL'), ClothingStyle.casual);
      expect(ClothingStyle.fromString('Formal'), ClothingStyle.formal);
    });

    test('fromString returns casual for invalid input', () {
      expect(ClothingStyle.fromString('invalid'), ClothingStyle.casual);
    });

    test('displayName returns correct names', () {
      expect(ClothingStyle.casual.displayName, 'Casual');
      expect(ClothingStyle.formal.displayName, 'Formal');
      expect(ClothingStyle.streetwear.displayName, 'Streetwear');
      expect(ClothingStyle.vintage.displayName, 'Vintage');
      expect(ClothingStyle.sporty.displayName, 'Sporty');
      expect(ClothingStyle.elegant.displayName, 'Elegant');
    });
  });

  group('Season', () {
    test('fromString returns correct season', () {
      expect(Season.fromString('spring'), Season.spring);
      expect(Season.fromString('summer'), Season.summer);
      expect(Season.fromString('fall'), Season.fall);
      expect(Season.fromString('winter'), Season.winter);
    });

    test('fromString is case insensitive', () {
      expect(Season.fromString('SUMMER'), Season.summer);
      expect(Season.fromString('Winter'), Season.winter);
    });

    test('fromString returns summer for invalid input', () {
      expect(Season.fromString('invalid'), Season.summer);
    });

    test('displayName returns Vietnamese names', () {
      expect(Season.spring.displayName, 'Xuân');
      expect(Season.summer.displayName, 'Hè');
      expect(Season.fall.displayName, 'Thu');
      expect(Season.winter.displayName, 'Đông');
    });
  });

  group('ClothingItem', () {
    test('toJson and fromJson work correctly', () {
      final item = ClothingItem(
        id: 'test-id-123',
        userId: 'user-123',
        imageBase64: 'base64string',
        type: ClothingType.shirt,
        color: 'blue',
        material: 'cotton',
        styles: [ClothingStyle.casual, ClothingStyle.formal],
        seasons: [Season.spring, Season.summer],
        createdAt: DateTime(2026, 1, 18),
        wearCount: 5,
        isFavorite: true,
      );

      final json = item.toJson();

      expect(json['userId'], 'user-123');
      expect(json['imageBase64'], 'base64string');
      expect(json['type'], 'shirt');
      expect(json['color'], 'blue');
      expect(json['material'], 'cotton');
      expect(json['styles'], ['casual', 'formal']);
      expect(json['seasons'], ['spring', 'summer']);
      expect(json['wearCount'], 5);
      expect(json['isFavorite'], true);
    });

    test('toAIDescription returns correct format', () {
      final item = ClothingItem(
        id: 'test-id',
        userId: 'user-123',
        type: ClothingType.shirt,
        color: 'blue',
        styles: [ClothingStyle.casual],
        seasons: [Season.summer],
        createdAt: DateTime.now(),
      );

      final description = item.toAIDescription();

      expect(description.contains('ID:test-id'), true);
      expect(description.contains('shirt'), true);
      expect(description.contains('blue'), true);
      expect(description.contains('casual'), true);
      expect(description.contains('summer'), true);
    });

    test('copyWith creates new instance with updated values', () {
      final original = ClothingItem(
        id: 'test-id',
        userId: 'user-123',
        type: ClothingType.shirt,
        color: 'blue',
        styles: [ClothingStyle.casual],
        seasons: [Season.summer],
        createdAt: DateTime.now(),
        wearCount: 0,
        isFavorite: false,
      );

      final updated = original.copyWith(
        color: 'red',
        wearCount: 5,
        isFavorite: true,
      );

      // Original unchanged
      expect(original.color, 'blue');
      expect(original.wearCount, 0);
      expect(original.isFavorite, false);

      // Updated has new values
      expect(updated.color, 'red');
      expect(updated.wearCount, 5);
      expect(updated.isFavorite, true);

      // Other values preserved
      expect(updated.id, 'test-id');
      expect(updated.type, ClothingType.shirt);
    });

    test('fromJson creates ClothingItem from Firestore data', () {
      final json = {
        'userId': 'user-123',
        'imageBase64': 'base64string',
        'type': 'shirt',
        'color': 'blue',
        'material': 'cotton',
        'styles': ['casual', 'formal'],
        'seasons': ['spring', 'summer'],
        'wearCount': 5,
        'isFavorite': true,
      };

      final item = ClothingItem.fromJson(json, 'doc-id-123');

      expect(item.id, 'doc-id-123');
      expect(item.userId, 'user-123');
      expect(item.imageBase64, 'base64string');
      expect(item.type, ClothingType.shirt);
      expect(item.color, 'blue');
      expect(item.material, 'cotton');
      expect(item.styles.length, 2);
      expect(item.styles.contains(ClothingStyle.casual), true);
      expect(item.styles.contains(ClothingStyle.formal), true);
      expect(item.seasons.length, 2);
      expect(item.wearCount, 5);
      expect(item.isFavorite, true);
    });

    test('fromJson handles missing/null fields with defaults', () {
      final json = <String, dynamic>{'userId': 'user-123'};

      final item = ClothingItem.fromJson(json, 'doc-id');

      expect(item.id, 'doc-id');
      expect(item.userId, 'user-123');
      expect(item.type, ClothingType.other);
      expect(item.color, 'unknown');
      expect(item.styles, [ClothingStyle.casual]);
      expect(item.seasons, [Season.summer]);
      expect(item.wearCount, 0);
      expect(item.isFavorite, false);
    });
  });
}
