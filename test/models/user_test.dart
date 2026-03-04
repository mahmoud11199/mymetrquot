import 'package:flutter_test/flutter_test.dart';
import 'package:mymetrquot/models/user.dart';

void main() {
  group('User.fromJson', () {
    test('parses required values', () {
      final user = User.fromJson({
        'id': 4,
        'username': 'driver_1',
        'role': 'driver',
      });

      expect(user.id, 4);
      expect(user.username, 'driver_1');
      expect(user.role, 'driver');
    });

    test('applies empty-string fallbacks for nullable string fields', () {
      final user = User.fromJson({
        'id': 5,
      });

      expect(user.id, 5);
      expect(user.username, '');
      expect(user.role, '');
    });
  });
}
