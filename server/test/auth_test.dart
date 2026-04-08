import 'package:test/test.dart';

import 'package:server/auth/jwt.dart';

void main() {
  group('hashPin', () {
    test('produces consistent hash for same input', () {
      final h1 = hashPin('1234', 'salt123');
      final h2 = hashPin('1234', 'salt123');
      expect(h1, equals(h2));
    });

    test('different salt produces different hash', () {
      final h1 = hashPin('1234', 'salt1');
      final h2 = hashPin('1234', 'salt2');
      expect(h1, isNot(equals(h2)));
    });

    test('different pin produces different hash', () {
      final h1 = hashPin('1234', 'salt');
      final h2 = hashPin('5678', 'salt');
      expect(h1, isNot(equals(h2)));
    });

    test('hash is 64 hex chars (SHA-256)', () {
      final h = hashPin('1234', 'salt');
      expect(h.length, equals(64));
      expect(RegExp(r'^[a-f0-9]{64}$').hasMatch(h), isTrue);
    });
  });

  group('JWT', () {
    const secret = 'test-secret-key-for-unit-tests';

    test('createToken produces a valid token string', () {
      final token = createToken(
        secret,
        userId: 1,
        tenantId: 'tenant-abc',
        username: 'admin',
        role: 'admin',
      );
      expect(token, isNotEmpty);
      expect(token.split('.').length, equals(3)); // JWT has 3 parts
    });

    test('verifyToken returns payload for valid token', () {
      final token = createToken(
        secret,
        userId: 42,
        tenantId: 'tid-123',
        username: 'cashier1',
        role: 'cashier',
      );

      final payload = verifyToken(secret, token);
      expect(payload, isNotNull);
      expect(payload!['sub'], equals(42));
      expect(payload['tid'], equals('tid-123'));
      expect(payload['usr'], equals('cashier1'));
      expect(payload['rol'], equals('cashier'));
    });

    test('verifyToken returns null for wrong secret', () {
      final token = createToken(
        secret,
        userId: 1,
        tenantId: 'tid',
        username: 'u',
        role: 'admin',
      );
      final payload = verifyToken('wrong-secret', token);
      expect(payload, isNull);
    });

    test('verifyToken returns null for garbage token', () {
      expect(verifyToken(secret, 'not-a-token'), isNull);
      expect(verifyToken(secret, ''), isNull);
    });

    test('verifyToken returns null for tampered token', () {
      final token = createToken(
        secret,
        userId: 1,
        tenantId: 'tid',
        username: 'u',
        role: 'admin',
      );
      // Tamper with payload.
      final parts = token.split('.');
      parts[1] = '${parts[1]}X';
      final tampered = parts.join('.');
      expect(verifyToken(secret, tampered), isNull);
    });
  });
}
