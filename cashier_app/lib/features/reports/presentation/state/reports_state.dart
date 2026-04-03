import 'package:cashier_app/features/reports/domain/entities/sales_report.dart';
import 'package:equatable/equatable.dart';

sealed class ReportsState extends Equatable {
  const ReportsState();
}

final class ReportsInitial extends ReportsState {
  const ReportsInitial();
  @override
  List<Object?> get props => [];
}

final class ReportsLoading extends ReportsState {
  const ReportsLoading();
  @override
  List<Object?> get props => [];
}

final class ReportsReady extends ReportsState {
  const ReportsReady({
    required this.report,
    this.lastZAt,
  });

  final SalesReport report;

  /// When the last Z report was run; null = no Z ever.
  final DateTime? lastZAt;

  @override
  List<Object?> get props => [report, lastZAt];
}

final class ReportsError extends ReportsState {
  const ReportsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
