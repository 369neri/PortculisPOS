import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class User extends Equatable {
  const User({
    required this.username,
    required this.displayName,
    required this.pin,
    required this.role,
    this.id,
    this.salt = '',
    this.failedAttempts = 0,
    this.lockedUntil,
    this.isActive = true,
  });

  final int? id;
  final String username;
  final String displayName;
  final String pin;
  final String salt;
  final String role; // 'admin', 'cashier'
  final bool isActive;
  final int failedAttempts;
  final DateTime? lockedUntil;

  bool get isAdmin => role == 'admin';

  bool get isLockedOut =>
      lockedUntil != null && DateTime.now().isBefore(lockedUntil!);

  @override
  List<Object?> get props => [
        id, username, displayName, pin, salt, role, isActive,
        failedAttempts, lockedUntil,
      ];
}
