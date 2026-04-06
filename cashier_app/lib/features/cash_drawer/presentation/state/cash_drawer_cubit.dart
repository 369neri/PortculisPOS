import 'package:cashier_app/core/logging/app_logger.dart';
import 'package:cashier_app/features/cash_drawer/domain/entities/cash_drawer_session.dart';
import 'package:cashier_app/features/cash_drawer/domain/repositories/cash_drawer_repository.dart';
import 'package:cashier_app/features/cash_drawer/presentation/state/cash_drawer_state.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CashDrawerCubit extends Cubit<CashDrawerState> {
  CashDrawerCubit(this._repository) : super(const CashDrawerInitial());

  final CashDrawerRepository _repository;

  Future<void> load() async {
    emit(const CashDrawerLoading());
    try {
      final active = await _repository.getActiveSession();
      if (active != null) {
        emit(CashDrawerOpen(active));
      } else {
        emit(const CashDrawerInitial());
      }
    } on Exception catch (e, st) {
      appLogger.e('Failed to load cash drawer', error: e, stackTrace: st);
      emit(const CashDrawerError('Unable to load cash drawer. Please try again.'));
    }
  }

  Future<void> openDrawer(Price openingBalance) async {
    try {
      final session = CashDrawerSession(
        openedAt: DateTime.now(),
        openingBalance: openingBalance,
      );
      final id = await _repository.openSession(session);
      final saved = await _repository.getActiveSession();
      emit(
        CashDrawerOpen(
          saved ??
              CashDrawerSession(
                id: id,
                openedAt: session.openedAt,
                openingBalance: openingBalance,
              ),
        ),
      );
    } on Exception catch (e, st) {
      appLogger.e('Failed to open cash drawer', error: e, stackTrace: st);
      emit(const CashDrawerError('Unable to open cash drawer. Please try again.'));
    }
  }

  Future<void> closeDrawer(Price countedBalance, {String? notes}) async {
    final current = state;
    if (current is! CashDrawerOpen) return;
    final session = current.session;
    if (session.id == null) return;

    try {
      final closed = CashDrawerSession(
        id: session.id,
        openedAt: session.openedAt,
        closedAt: DateTime.now(),
        openingBalance: session.openingBalance,
        closingBalance: countedBalance,
        notes: notes,
      );
      await _repository.closeSession(session.id!, closed);
      emit(CashDrawerClosed(closed));
    } on Exception catch (e, st) {
      appLogger.e('Failed to close cash drawer', error: e, stackTrace: st);
      emit(const CashDrawerError('Unable to close cash drawer. Please try again.'));
    }
  }

  Future<void> loadHistory() async {
    emit(const CashDrawerLoading());
    try {
      final sessions = await _repository.getAllSessions();
      emit(CashDrawerHistory(sessions));
    } on Exception catch (e, st) {
      appLogger.e('Failed to load cash drawer history', error: e, stackTrace: st);
      emit(const CashDrawerError('Unable to load history. Please try again.'));
    }
  }
}
