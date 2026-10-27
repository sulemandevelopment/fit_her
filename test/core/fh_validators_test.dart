import 'package:fitness_zone_2/core/forms/fh_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FhValidators.email', () {
    test('rejects empty', () {
      expect(FhValidators.email(''), isNotNull);
      expect(FhValidators.email(null), isNotNull);
    });

    test('rejects invalid format', () {
      expect(FhValidators.email('not-an-email'), isNotNull);
    });

    test('accepts valid email', () {
      expect(FhValidators.email('user@example.com'), isNull);
    });
  });

  group('FhValidators.password', () {
    test('rejects short password', () {
      expect(FhValidators.password('123'), isNotNull);
    });

    test('accepts valid password', () {
      expect(FhValidators.password('secret1'), isNull);
    });
  });
}
