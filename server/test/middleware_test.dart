import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import 'package:server/auth/jwt.dart';
import 'package:server/config.dart';
import 'package:server/middleware/auth_middleware.dart';
import 'package:server/db/database.dart';

void main() {
  const secret = 'test-secret';

  group('authMiddleware', () {
    late Handler protectedHandler;

    setUp(() {
      AppConfig.initForTest(jwtSecret: secret);
      // Database is constructed but never connected — middleware only checks JWT.
      final db = Database(AppConfig.instance);
      protectedHandler = const Pipeline()
          .addMiddleware(authMiddleware(secret, db))
          .addHandler(_echoHandler);
    });

    test('allows public paths without token', () async {
      final request = Request('POST', Uri.parse('http://localhost/api/auth/login'));
      final response = await protectedHandler(request);
      expect(response.statusCode, equals(200));
    });

    test('allows health check without token', () async {
      final request = Request('GET', Uri.parse('http://localhost/health'));
      final response = await protectedHandler(request);
      expect(response.statusCode, equals(200));
    });

    test('allows OPTIONS without token (CORS preflight)', () async {
      final request = Request('OPTIONS', Uri.parse('http://localhost/api/items'));
      final response = await protectedHandler(request);
      expect(response.statusCode, equals(200));
    });

    test('rejects protected path without token', () async {
      final request = Request('GET', Uri.parse('http://localhost/api/items'));
      final response = await protectedHandler(request);
      expect(response.statusCode, equals(401));
      final body = jsonDecode(await response.readAsString());
      expect(body['error'], contains('Authorization'));
    });

    test('rejects invalid token', () async {
      final request = Request('GET', Uri.parse('http://localhost/api/items'),
          headers: {'authorization': 'Bearer garbage'});
      final response = await protectedHandler(request);
      expect(response.statusCode, equals(401));
    });

    test('passes with valid token and sets context', () async {
      final token = createToken(
        secret,
        userId: 5,
        tenantId: 'tid-abc',
        username: 'admin',
        role: 'admin',
      );
      final request = Request('GET', Uri.parse('http://localhost/api/items'),
          headers: {'authorization': 'Bearer $token'});
      final response = await protectedHandler(request);
      expect(response.statusCode, equals(200));

      final body = jsonDecode(await response.readAsString());
      expect(body['userId'], equals(5));
      expect(body['tenantId'], equals('tid-abc'));
      expect(body['role'], equals('admin'));
    });

    test('rejects token signed with wrong secret', () async {
      final token = createToken(
        'other-secret',
        userId: 1,
        tenantId: 'tid',
        username: 'u',
        role: 'admin',
      );
      final request = Request('GET', Uri.parse('http://localhost/api/items'),
          headers: {'authorization': 'Bearer $token'});
      final response = await protectedHandler(request);
      expect(response.statusCode, equals(401));
    });
  });
}

/// A handler that echoes the request context as JSON.
Response _echoHandler(Request request) {
  return Response.ok(
    jsonEncode({
      'userId': request.context['userId'],
      'tenantId': request.context['tenantId'],
      'role': request.context['role'],
    }),
    headers: {'content-type': 'application/json'},
  );
}
