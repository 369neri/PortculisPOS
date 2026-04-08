import 'package:cashier_app/core/persistence/app_database.dart';
import 'package:cashier_app/features/auth/domain/entities/user.dart';
import 'package:cashier_app/features/auth/domain/repositories/user_repository.dart';
import 'package:cashier_app/features/auth/domain/services/pin_hasher.dart';
import 'package:drift/drift.dart' show Value;

class LocalUserDatasource implements UserRepository {
  LocalUserDatasource(this._dao);

  final UsersDao _dao;

  static const _maxAttempts = 3;
  static const _lockoutDuration = Duration(seconds: 30);

  @override
  Future<List<User>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<User?> findByUsername(String username) async {
    final row = await _dao.findByUsername(username);
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<void> save(User user) async {
    final salt = user.salt.isEmpty ? generateSalt() : user.salt;
    final hashedPin = hashPin(user.pin, salt: salt);
    if (user.id != null) {
      await _dao.updateUser(
        UsersTableCompanion(
          id: Value(user.id!),
          username: Value(user.username),
          displayName: Value(user.displayName),
          pin: Value(hashedPin),
          salt: Value(salt),
          role: Value(user.role),
          isActive: Value(user.isActive),
        ),
      );
    } else {
      await _dao.insertUser(
        UsersTableCompanion.insert(
          username: user.username,
          displayName: user.displayName,
          pin: hashedPin,
          salt: Value(salt),
          role: Value(user.role),
          isActive: Value(user.isActive),
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<void> delete(int id) => _dao.deleteUser(id);

  @override
  Future<bool> hasAnyUsers() async {
    final users = await _dao.getAll();
    return users.isNotEmpty;
  }

  @override
  Future<void> recordFailedAttempt(int userId) async {
    final rows = await _dao.getAll();
    final row = rows.where((r) => r.id == userId).firstOrNull;
    if (row == null) return;
    final attempts = row.failedAttempts + 1;
    final lockUntil =
        attempts >= _maxAttempts ? DateTime.now().add(_lockoutDuration) : null;
    await _dao.incrementFailedAttempts(userId, lockUntil: lockUntil);
  }

  @override
  Future<void> resetFailedAttempts(int userId) =>
      _dao.resetFailedAttempts(userId);

  User _toDomain(UsersTableData row) => User(
        id: row.id,
        username: row.username,
        displayName: row.displayName,
        pin: row.pin,
        salt: row.salt,
        role: row.role,
        isActive: row.isActive,
        failedAttempts: row.failedAttempts,
        lockedUntil: row.lockedUntil,
      );
}
