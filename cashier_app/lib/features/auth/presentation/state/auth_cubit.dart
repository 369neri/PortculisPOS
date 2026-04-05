import 'package:cashier_app/features/auth/domain/entities/user.dart';
import 'package:cashier_app/features/auth/domain/repositories/user_repository.dart';
import 'package:cashier_app/features/auth/domain/services/pin_hasher.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

@immutable
sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// Initial — haven't checked yet.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// No users configured — skip login, act as admin.
class AuthDisabled extends AuthState {
  const AuthDisabled();
}

/// Awaiting PIN entry.
class AuthLocked extends AuthState {
  const AuthLocked({this.error});
  final String? error;
  @override
  List<Object?> get props => [error];
}

/// Logged in.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final User user;
  @override
  List<Object?> get props => [user];
}

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthInitial());

  final UserRepository _repo;

  /// Check if auth is needed. If no users exist, skip login.
  Future<void> init() async {
    final hasUsers = await _repo.hasAnyUsers();
    if (!hasUsers) {
      emit(const AuthDisabled());
    } else {
      emit(const AuthLocked());
    }
  }

  /// Attempt login with username + PIN.
  Future<void> login(String username, String pin) async {
    final user = await _repo.findByUsername(username);
    if (user == null || user.pin != hashPin(pin) || !user.isActive) {
      emit(const AuthLocked(error: 'Invalid credentials'));
      return;
    }
    emit(AuthAuthenticated(user));
  }

  void logout() {
    emit(const AuthLocked());
  }
}
