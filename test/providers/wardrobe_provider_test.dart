import 'package:flutter_test/flutter_test.dart';
import 'package:ai_personal_stylist/providers/wardrobe_provider.dart';

void main() {
  group('StylePreference', () {
    test('displayName returns Vietnamese names', () {
      expect(StylePreference.loose.displayName, 'Đồ rộng thoải mái');
      expect(StylePreference.regular.displayName, 'Vừa vặn');
      expect(StylePreference.fitted.displayName, 'Ôm body');
    });

    test('aiDescription returns English description for AI', () {
      expect(StylePreference.loose.aiDescription.contains('loose'), true);
      expect(StylePreference.loose.aiDescription.contains('oversized'), true);

      expect(StylePreference.regular.aiDescription.contains('regular'), true);
      expect(StylePreference.regular.aiDescription.contains('balanced'), true);

      expect(StylePreference.fitted.aiDescription.contains('fitted'), true);
      expect(StylePreference.fitted.aiDescription.contains('slim'), true);
    });

    test('all StylePreference values have displayName', () {
      for (final style in StylePreference.values) {
        expect(style.displayName.isNotEmpty, true);
      }
    });

    test('all StylePreference values have aiDescription', () {
      for (final style in StylePreference.values) {
        expect(style.aiDescription.isNotEmpty, true);
      }
    });
  });

  group('WardrobeStatus', () {
    test('all status values exist', () {
      expect(WardrobeStatus.values.contains(WardrobeStatus.initial), true);
      expect(WardrobeStatus.values.contains(WardrobeStatus.loading), true);
      expect(WardrobeStatus.values.contains(WardrobeStatus.loaded), true);
      expect(WardrobeStatus.values.contains(WardrobeStatus.error), true);
    });
  });
}
