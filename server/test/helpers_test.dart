import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import 'package:server/helpers.dart';

void main() {
  group('readJson', () {
    test('parses valid JSON body', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/test'),
        body: jsonEncode({'key': 'value'}),
        headers: {'content-type': 'application/json'},
      );
      final result = await readJson(request);
      expect(result, isNotNull);
      expect(result!['key'], equals('value'));
    });

    test('returns null for empty body', () async {
      final request = Request('POST', Uri.parse('http://localhost/test'));
      final result = await readJson(request);
      expect(result, isNull);
    });

    test('returns null for non-JSON body', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/test'),
        body: 'not json',
      );
      final result = await readJson(request);
      expect(result, isNull);
    });

    test('returns null for JSON array (not map)', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/test'),
        body: jsonEncode([1, 2, 3]),
      );
      final result = await readJson(request);
      expect(result, isNull);
    });
  });

  group('jsonResponse', () {
    test('returns 200 with JSON content-type', () {
      final response = jsonResponse({'ok': true});
      expect(response.statusCode, equals(200));
      expect(response.headers['content-type'], equals('application/json'));
    });

    test('returns custom status code', () {
      final response = jsonResponse({'created': true}, status: 201);
      expect(response.statusCode, equals(201));
    });

    test('body is valid JSON', () async {
      final response = jsonResponse({'foo': 'bar'});
      final body = await response.readAsString();
      final decoded = jsonDecode(body);
      expect(decoded['foo'], equals('bar'));
    });
  });

  group('error responses', () {
    test('badRequest returns 400', () {
      final response = badRequest('oops');
      expect(response.statusCode, equals(400));
    });

    test('notFound returns 404', () {
      final response = notFound('gone');
      expect(response.statusCode, equals(404));
    });

    test('forbidden returns 403', () {
      final response = forbidden('nope');
      expect(response.statusCode, equals(403));
    });
  });

  group('context extractors', () {
    test('tenantId extracts from context', () {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/test'),
      ).change(context: {
        'tenantId': 'abc-123',
        'userId': 1,
        'role': 'admin',
      });
      expect(tenantId(request), equals('abc-123'));
    });

    test('userId extracts from context', () {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/test'),
      ).change(context: {
        'tenantId': 'abc',
        'userId': 42,
        'role': 'cashier',
      });
      expect(userId(request), equals(42));
    });

    test('userRole extracts from context', () {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/test'),
      ).change(context: {
        'tenantId': 'abc',
        'userId': 1,
        'role': 'cashier',
      });
      expect(userRole(request), equals('cashier'));
    });
  });
}
