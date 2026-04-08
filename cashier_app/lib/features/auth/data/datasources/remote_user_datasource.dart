import 'package:cashier_app/core/network/api_client.dart';
import 'package:cashier_app/features/auth/domain/entities/user.dart';
import 'package:cashier_app/features/auth/domain/repositories/user_repository.dart';

/// Remote datasource that proxies [UserRepository] calls to the server API.
class RemoteUserDatasource implements UserRepository {
  RemoteUserDatasource(this._api);

  final ApiClient _api;

  @override
  Future<List<User>> getAll() async {
    final data = await _api.get('/api/auth/users');
    final list = data['users'] as List? ?? [];
    return list.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<User?> findByUsername(String username) async {
    final users = await getAll();
    return users.where((u) => u.username == username).firstOrNull;
  }

  @override
  Future<void> save(User user) async {
    // Server handles hashing — pass the raw PIN.
    await _api.post('/api/auth/users', {
      'username': user.username,
      'displayName': user.displayName,
      'pin': user.pin,
      'role': user.role,
    });
  }

  @override
  Future<void> delete(int id) => _api.delete('/api/auth/users/$id');

  @override
  Future<bool> hasAnyUsers() async {
    final users = await getAll();
    return users.isNotEmpty;
  }

  @override
  Future<void> recordFailedAttempt(int userId) async {
    // Handled server-side during login — no-op for remote.
  }

  @override
  Future<void> resetFailedAttempts(int userId) async {
    // Handled server-side during login — no-op for remote.
  }

  // ---------------------------------------------------------------------------
  // JSON helpers
  // ---------------------------------------------------------------------------

  static User _fromJson(Map<String, dynamic> m) => User(
        id: m['id'] as int?,
        username: m['username'] as String? ?? '',
        displayName: m['displayName'] as String? ?? '',
        pin: '', // Server never returns PINs.
        role: m['role'] as String? ?? 'cashier',
        isActive: m['isActive'] as bool? ?? true,
      );
}
