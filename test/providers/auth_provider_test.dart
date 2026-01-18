import 'package:flutter_test/flutter_test.dart';
import 'package:ai_personal_stylist/providers/auth_provider.dart';

void main() {
  group('AuthStatus', () {
    test('all status values exist', () {
      expect(AuthStatus.values.contains(AuthStatus.initial), true);
      expect(AuthStatus.values.contains(AuthStatus.authenticated), true);
      expect(AuthStatus.values.contains(AuthStatus.unauthenticated), true);
      expect(AuthStatus.values.contains(AuthStatus.loading), true);
      expect(AuthStatus.values.contains(AuthStatus.error), true);
    });

    test('AuthStatus has correct number of values', () {
      expect(AuthStatus.values.length, 5);
    });
  });
}
