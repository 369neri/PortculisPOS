import 'package:cashier_app/core/logging/app_logger.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/reports/domain/services/report_service.dart';
import 'package:cashier_app/features/reports/presentation/state/reports_state.dart';
import 'package:cashier_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit(this._txRepo, this._settingsRepo)
      : super(const ReportsInitial());

  final TransactionRepository _txRepo;
  final SettingsRepository _settingsRepo;

  Future<void> load() async {
    emit(const ReportsLoading());
    try {
      final settings = await _settingsRepo.getSettings();
      final allTx = await _txRepo.getAll();
      final report = ReportService.generate(
        allTx,
        from: settings.lastZReportAt,
        taxRate: settings.taxRate,
      );
      emit(ReportsReady(report: report, lastZAt: settings.lastZReportAt));
    } on Exception catch (e, st) {
      appLogger.e('Failed to load reports', error: e, stackTrace: st);
      emit(const ReportsError('Unable to load reports. Please try again.'));
    }
  }

  Future<void> closeDay() async {
    if (state is! ReportsReady) return;
    try {
      final settings = await _settingsRepo.getSettings();
      await _settingsRepo.saveSettings(
        settings.copyWith(lastZReportAt: DateTime.now()),
      );
      await load();
    } on Exception catch (e, st) {
      appLogger.e('Failed to close day', error: e, stackTrace: st);
      emit(const ReportsError('Unable to close the day. Please try again.'));
    }
  }
}
