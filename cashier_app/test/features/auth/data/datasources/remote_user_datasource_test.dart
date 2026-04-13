import 'dart:convert';

import 'package:cashier_app/core/network/api_client.dart';
import 'package:cashier_app/features/auth/data/datasources/remote_user_datasource.dart';
import 'package:cashier_app/features/auth/domain/entities/user.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

ApiClient _fakeApi(Future<http.Response> Function(http.Request) handler) =>
    ApiClient(
      baseUrl: 'http://localhost:8080',
      httpClient: MockClient(handler),
    );

void main() {
  group('RemoteUserDatasource', () {
    test('getAll parses user list', () async {
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({
            'users': [
              {
                'id': 1,
                'username': 'admin',
                'displayName': 'Admin User',
                'role': 'admin',
                'isActive': true,
              },
              {
                'id': 2,
                'username': 'cashier1',
                'displayName': 'Jane',
                'role': 'cashier',
                'isActive': false,
              },
            ],
          }),
          200,
        ),
      );
      final ds = RemoteUserDatasource(api);
      final users = await ds.getAll();

      expect(users, hasLength(2));
      expect(users[0].username, 'admin');
      expect(users[0].displayName, 'Admin User');
      expect(users[0].role, 'admin');
      expect(users[0].isActive, isTrue);
      expect(users[1].isActive, isFalse);
      // PIN is never returned by the server.
      expect(users[0].pin, isEmpty);
    });

    test('findByUsername returns matching user', () async {
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({
            'users': [
              {
                'id': 1,
                'username': 'admin',
                'displayName': 'Admin',
                'role': 'admin',
              },
            ],
          }),
          200,
        ),
      );
      final ds = RemoteUserDatasource(api);
      final user = await ds.findByUsername('admin');
      expect(user, isNotNull);
      expect(user!.username, 'admin');
    });

    test('findByUsername returns null when not found', () async {
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({'users': <dynamic>[]}),
          200,
        ),
      );
      final ds = RemoteUserDatasource(api);
      expect(await ds.findByUsername('ghost'), isNull);
    });

    test('save posts user data', () async {
      http.Request? captured;
      final api = _fakeApi((req) async {
        captured = req;
        return http.Response(jsonEncode({'id': 3}), 200);
      });
      final ds = RemoteUserDatasource(api);
      await ds.save(const User(
        username: 'new',
        displayName: 'New User',
        pin: '1234',
        role: 'cashier',
      ),);

      expect(captured, isNotNull);
      expect(captured!.url.path, '/api/auth/users');
      final body = jsonDecode(captured!.body) as Map<String, dynamic>;
      expect(body['username'], 'new');
      expect(body['pin'], '1234');
    });

    test('delete sends DELETE request', () async {
      http.Request? captured;
      final api = _fakeApi((req) async {
        captured = req;
        return http.Response(jsonEncode({}), 200);
      });
      final ds = RemoteUserDatasource(api);
      await ds.delete(5);
      expect(captured!.method, 'DELETE');
      expect(captured!.url.path, '/api/auth/users/5');
    });

    test('hasAnyUsers returns true when list is non-empty', () async {
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({
            'users': [
              {'id': 1, 'username': 'a', 'displayName': 'A', 'role': 'admin'},
            ],
          }),
          200,
        ),
      );
      final ds = RemoteUserDatasource(api);
      expect(await ds.hasAnyUsers(), isTrue);
    });

    test('hasAnyUsers returns false when list is empty', () async {
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({'users': <dynamic>[]}),
          200,
        ),
      );
      final ds = RemoteUserDatasource(api);
      expect(await ds.hasAnyUsers(), isFalse);
    });
  });
}
