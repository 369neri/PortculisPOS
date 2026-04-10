import 'dart:convert';

import 'package:cashier_app/core/network/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('ApiClient', () {
    late ApiClient api;

    test('GET returns parsed JSON on 200', () async {
      api = ApiClient(
        baseUrl: 'http://localhost:8080',
        httpClient: MockClient(
          (req) async => http.Response(
            jsonEncode({'items': [1, 2, 3]}),
            200,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );
      final data = await api.get('/api/items/');
      expect(data['items'], [1, 2, 3]);
    });

    test('POST sends body and returns parsed JSON', () async {
      api = ApiClient(
        baseUrl: 'http://localhost:8080',
        httpClient: MockClient((req) async {
          expect(req.method, 'POST');
          final body = jsonDecode(req.body) as Map<String, dynamic>;
          expect(body['name'], 'test');
          return http.Response(jsonEncode({'id': 42}), 201);
        }),
      );
      final data = await api.post('/api/items/', {'name': 'test'});
      expect(data['id'], 42);
    });

    test('PUT sends body correctly', () async {
      api = ApiClient(
        baseUrl: 'http://localhost:8080',
        httpClient: MockClient((req) async {
          expect(req.method, 'PUT');
          return http.Response(jsonEncode({'ok': true}), 200);
        }),
      );
      final data = await api.put('/api/settings/', {'taxRate': 10.0});
      expect(data['ok'], true);
    });

    test('PATCH sends body correctly', () async {
      api = ApiClient(
        baseUrl: 'http://localhost:8080',
        httpClient: MockClient((req) async {
          expect(req.method, 'PATCH');
          return http.Response(jsonEncode({'ok': true}), 200);
        }),
      );
      final data = await api.patch('/api/items/1/stock', {'delta': -1});
      expect(data['ok'], true);
    });

    test('DELETE works', () async {
      api = ApiClient(
        baseUrl: 'http://localhost:8080',
        httpClient: MockClient((req) async {
          expect(req.method, 'DELETE');
          return http.Response(jsonEncode({'deleted': true}), 200);
        }),
      );
      final data = await api.delete('/api/items/1');
      expect(data['deleted'], true);
    });

    test('throws ApiException on 400', () async {
      api = ApiClient(
        baseUrl: 'http://localhost:8080',
        httpClient: MockClient(
          (req) async =>
              http.Response(jsonEncode({'error': 'bad request'}), 400),
        ),
      );
      expect(
        () => api.get('/api/items/'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 400)),
      );
    });

    test('throws ApiException on 401', () async {
      api = ApiClient(
        baseUrl: 'http://localhost:8080',
        httpClient: MockClient(
          (req) async =>
              http.Response(jsonEncode({'error': 'Unauthorized'}), 401),
        ),
      );
      expect(
        () => api.get('/api/items/'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.isUnauthorized, 'isUnauthorized', true),
        ),
      );
    });

    test('throws ApiException on 404', () async {
      api = ApiClient(
        baseUrl: 'http://localhost:8080',
        httpClient: MockClient(
          (req) async =>
              http.Response(jsonEncode({'error': 'Not found'}), 404),
        ),
      );
      expect(
        () => api.get('/api/items/999'),
        throwsA(
          isA<ApiException>().having((e) => e.isNotFound, 'isNotFound', true),
        ),
      );
    });

    test('sends Authorization header when token is set', () async {
      api = ApiClient(
        baseUrl: 'http://localhost:8080',
        httpClient: MockClient((req) async {
          expect(req.headers['authorization'], 'Bearer my-jwt-token');
          return http.Response(jsonEncode({}), 200);
        }),
      )
        ..token = 'my-jwt-token';
      await api.get('/api/items/');
    });

    test('does not send Authorization header when token is null', () async {
      api = ApiClient(
        baseUrl: 'http://localhost:8080',
        httpClient: MockClient((req) async {
          expect(req.headers.containsKey('authorization'), false);
          return http.Response(jsonEncode({}), 200);
        }),
      );
      await api.get('/api/items/');
    });

    test('isAuthenticated reflects token state', () {
      api = ApiClient(baseUrl: 'http://localhost:8080');
      expect(api.isAuthenticated, false);
      api.token = 'tok';
      expect(api.isAuthenticated, true);
      api.token = null;
      expect(api.isAuthenticated, false);
    });

    test('strips trailing slash from baseUrl', () async {
      api = ApiClient(
        baseUrl: 'http://localhost:8080/',
        httpClient: MockClient((req) async {
          expect(req.url.toString(), 'http://localhost:8080/api/items/');
          return http.Response(jsonEncode({}), 200);
        }),
      );
      await api.get('/api/items/');
    });
  });
}
