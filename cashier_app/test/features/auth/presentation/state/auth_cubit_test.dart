import 'package:bloc_test/bloc_test.dart';
import 'package:cashier_app/features/auth/domain/entities/user.dart';
import 'package:cashier_app/features/auth/domain/repositories/user_repository.dart';
import 'package:cashier_app/features/auth/presentation/state/auth_cubit.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Test double
// ---------------------------------------------------------------------------

class _FakeUserRepo implements UserRepository {
  List<User> users = [];

  @override
  Future<List<User>> getAll() async => List.unmodifiable(users);

  @override
  Future<User?> findByUsername(String username) async {
    try {
      return users.firstWhere((u) => u.username == username);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(User user) async {}

  @override
  Future<void> delete(int id) async {}

  @override
  Future<bool> hasAnyUsers() async => users.isNotEmpty;
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _admin = User(
  id: 1,
  username: 'admin',
  displayName: 'Admin',
  pin: '1234',
  role: 'admin',
);

const _cashier = User(
  id: 2,
  username: 'cashier',
  displayName: 'Cashier',
  pin: '0000',
  role: 'cashier',
);

const _inactive = User(
  id: 3,
  username: 'fired',
  displayName: 'Gone',
  pin: '9999',
  role: 'cashier',
  isActive: false,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeUserRepo repo;

  setUp(() => repo = _FakeUserRepo());

  group('AuthCubit', () {
    test('initial state is AuthInitial', () {
      expect(AuthCubit(repo).state, const AuthInitial());
    });

    // -- init --

    blocTest<AuthCubit, AuthState>(
      'init emits AuthDisabled when no users exist',
      build: () => AuthCubit(repo),
      act: (c) => c.init(),
      expect: () => [const AuthDisabled()],
    );

    blocTest<AuthCubit, AuthState>(
      'init emits AuthLocked when users exist',
      build: () {
        repo.users = [_admin];
        return AuthCubit(repo);
      },
      act: (c) => c.init(),
      expect: () => [const AuthLocked()],
    );

    // -- login --

    blocTest<AuthCubit, AuthState>(
      'login emits AuthAuthenticated on valid credentials',
      build: () {
        repo.users = [_admin, _cashier];
        return AuthCubit(repo);
      },
      act: (c) => c.login('admin', '1234'),
      expect: () => [const AuthAuthenticated(_admin)],
    );

    blocTest<AuthCubit, AuthState>(
      'login emits AuthLocked with error on wrong PIN',
      build: () {
        repo.users = [_admin];
        return AuthCubit(repo);
      },
      act: (c) => c.login('admin', '0000'),
      expect: () => [
        isA<AuthLocked>().having((s) => s.error, 'error', isNotNull),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'login emits AuthLocked with error on unknown user',
      build: () {
        repo.users = [_admin];
        return AuthCubit(repo);
      },
      act: (c) => c.login('nobody', '1234'),
      expect: () => [
        isA<AuthLocked>().having((s) => s.error, 'error', isNotNull),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'login rejects inactive user',
      build: () {
        repo.users = [_inactive];
        return AuthCubit(repo);
      },
      act: (c) => c.login('fired', '9999'),
      expect: () => [
        isA<AuthLocked>().having((s) => s.error, 'error', isNotNull),
      ],
    );

    // -- logout --

    blocTest<AuthCubit, AuthState>(
      'logout emits AuthLocked',
      build: () {
        repo.users = [_admin];
        return AuthCubit(repo);
      },
      seed: () => const AuthAuthenticated(_admin),
      act: (c) => c.logout(),
      expect: () => [const AuthLocked()],
    );
  });
}
