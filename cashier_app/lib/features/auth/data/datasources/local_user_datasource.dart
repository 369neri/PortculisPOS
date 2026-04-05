import 'package:cashier_app/core/persistence/app_database.dart';
import 'package:cashier_app/features/auth/domain/entities/user.dart';
import 'package:cashier_app/features/auth/domain/repositories/user_repository.dart';
import 'package:drift/drift.dart' show Value;

class LocalUserDatasource implements UserRepository {
  LocalUserDatasource(this._dao);

  final UsersDao _dao;

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
    if (user.id != null) {
      await _dao.updateUser(
        UsersTableCompanion(
          id: Value(user.id!),
          username: Value(user.username),
          displayName: Value(user.displayName),
          pin: Value(user.pin),
          role: Value(user.role),
          isActive: Value(user.isActive),
        ),
      );
    } else {
      await _dao.insertUser(
        UsersTableCompanion.insert(
          username: user.username,
          displayName: user.displayName,
          pin: user.pin,
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

  User _toDomain(UsersTableData row) => User(
        id: row.id,
        username: row.username,
        displayName: row.displayName,
        pin: row.pin,
        role: row.role,
        isActive: row.isActive,
      );
}
