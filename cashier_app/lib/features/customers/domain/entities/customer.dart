import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class Customer extends Equatable {
  const Customer({
    required this.name,
    this.id,
    this.phone = '',
    this.email = '',
    this.notes = '',
    this.createdAt,
  });

  final int? id;
  final String name;
  final String phone;
  final String email;
  final String notes;
  final DateTime? createdAt;

  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? notes,
    DateTime? createdAt,
  }) =>
      Customer(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [id, name, phone, email, notes, createdAt];
}
