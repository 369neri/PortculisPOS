import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class AppSettings extends Equatable {
  const AppSettings({
    this.businessName = 'My Business',
    this.taxRate = 0.0,
    this.currencySymbol = r'$',
    this.receiptFooter = 'Thank you for your business!',
    this.lastZReportAt,
    this.themeMode = 'system',
  });

  final String businessName;

  /// Tax rate as a percentage: 0.0 = no tax, 10.0 = 10 %.
  final double taxRate;

  final String currencySymbol;
  final String receiptFooter;

  /// When the last Z report was run; null = no Z ever.
  final DateTime? lastZReportAt;

  /// Theme mode: 'system', 'light', or 'dark'.
  final String themeMode;

  AppSettings copyWith({
    String? businessName,
    double? taxRate,
    String? currencySymbol,
    String? receiptFooter,
    DateTime? lastZReportAt,
    bool clearLastZReportAt = false,
    String? themeMode,
  }) =>
      AppSettings(
        businessName: businessName ?? this.businessName,
        taxRate: taxRate ?? this.taxRate,
        currencySymbol: currencySymbol ?? this.currencySymbol,
        receiptFooter: receiptFooter ?? this.receiptFooter,
        lastZReportAt:
            clearLastZReportAt ? null : (lastZReportAt ?? this.lastZReportAt),
        themeMode: themeMode ?? this.themeMode,
      );

  @override
  List<Object?> get props => [
        businessName,
        taxRate,
        currencySymbol,
        receiptFooter,
        lastZReportAt,
        themeMode,
      ];
}
