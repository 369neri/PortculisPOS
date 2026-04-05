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
    this.isActive = true,
  });

  final int? id;
  final String username;
  final String displayName;
  final String pin;
  final String role; // 'admin', 'cashier'
  final bool isActive;

  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [id, username, displayName, pin, role, isActive];
}
