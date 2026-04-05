import 'package:cashier_app/features/auth/domain/entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getAll();
  Future<User?> findByUsername(String username);
  Future<void> save(User user);
  Future<void> delete(int id);
  Future<bool> hasAnyUsers();
}
