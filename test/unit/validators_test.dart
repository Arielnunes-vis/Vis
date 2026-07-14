import 'package:flutter_test/flutter_test.dart';
import 'package:vis/core/validators/validators.dart';

void main() {
  group('Validators.email', () {
    test('aceita e-mail válido', () {
      expect(Validators.email('gabi@vis.app'), isNull);
    });
    test('rejeita e-mail inválido', () {
      expect(Validators.email('gabi'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });
  });

  group('Validators.password', () {
    test('exige mínimo de 8 caracteres', () {
      expect(Validators.password('1234567'), isNotNull);
      expect(Validators.password('12345678'), isNull);
    });
  });

  group('Validators.strongPassword', () {
    test('exige letras e números', () {
      expect(Validators.strongPassword('abcdefgh'), isNotNull);
      expect(Validators.strongPassword('abcd1234'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('valida coincidência', () {
      expect(Validators.confirmPassword('abcd1234', 'abcd1234'), isNull);
      expect(Validators.confirmPassword('abcd1234', 'outro'), isNotNull);
    });
  });
}
