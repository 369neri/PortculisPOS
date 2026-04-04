import 'package:cashier_app/features/cash_drawer/domain/entities/cash_drawer_session.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class CashDrawerState extends Equatable {
  const CashDrawerState();
}

final class CashDrawerInitial extends CashDrawerState {
  const CashDrawerInitial();

  @override
  List<Object?> get props => [];
}

final class CashDrawerLoading extends CashDrawerState {
  const CashDrawerLoading();

  @override
  List<Object?> get props => [];
}

final class CashDrawerOpen extends CashDrawerState {
  const CashDrawerOpen(this.session);

  final CashDrawerSession session;

  @override
  List<Object?> get props => [session];
}

/// Emitted after a drawer is closed, with the final session data.
final class CashDrawerClosed extends CashDrawerState {
  const CashDrawerClosed(this.session);

  final CashDrawerSession session;

  @override
  List<Object?> get props => [session];
}

final class CashDrawerHistory extends CashDrawerState {
  const CashDrawerHistory(this.sessions);

  final List<CashDrawerSession> sessions;

  @override
  List<Object?> get props => [sessions];
}

final class CashDrawerError extends CashDrawerState {
  const CashDrawerError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
