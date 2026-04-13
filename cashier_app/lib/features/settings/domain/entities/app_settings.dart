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
    this.logoPath,
    this.autoBackupEnabled = false,
    this.lastBackupAt,
    this.printerType = 'none',
    this.printerAddress = '',
    this.taxInclusive = false,
    this.lastSyncedAt,
    this.serverUrl = '',
    this.deviceId = '',
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

  /// Path to the business logo image shown on receipts.
  final String? logoPath;

  /// Whether automatic backup after each transaction is enabled.
  final bool autoBackupEnabled;

  /// When the last automatic backup was created.
  final DateTime? lastBackupAt;

  /// Thermal printer connection type: 'none', 'network', or 'usb'.
  final String printerType;

  /// Printer address (IP:port for network, device path for USB).
  final String printerAddress;

  /// Whether displayed prices already include tax.
  final bool taxInclusive;

  /// When the last server sync completed.
  final DateTime? lastSyncedAt;

  /// Remote server URL for sync (empty = sync disabled).
  final String serverUrl;

  /// Unique device identifier for sync (auto-generated on first launch).
  final String deviceId;

  AppSettings copyWith({
    String? businessName,
    double? taxRate,
    String? currencySymbol,
    String? receiptFooter,
    DateTime? lastZReportAt,
    bool clearLastZReportAt = false,
    String? themeMode,
    String? logoPath,
    bool clearLogoPath = false,
    bool? autoBackupEnabled,
    DateTime? lastBackupAt,
    bool clearLastBackupAt = false,
    String? printerType,
    String? printerAddress,
    bool? taxInclusive,
    DateTime? lastSyncedAt,
    bool clearLastSyncedAt = false,
    String? serverUrl,
    String? deviceId,
  }) =>
      AppSettings(
        businessName: businessName ?? this.businessName,
        taxRate: taxRate ?? this.taxRate,
        currencySymbol: currencySymbol ?? this.currencySymbol,
        receiptFooter: receiptFooter ?? this.receiptFooter,
        lastZReportAt:
            clearLastZReportAt ? null : (lastZReportAt ?? this.lastZReportAt),
        themeMode: themeMode ?? this.themeMode,
        logoPath: clearLogoPath ? null : (logoPath ?? this.logoPath),
        autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
        lastBackupAt:
            clearLastBackupAt ? null : (lastBackupAt ?? this.lastBackupAt),
        printerType: printerType ?? this.printerType,
        printerAddress: printerAddress ?? this.printerAddress,
        taxInclusive: taxInclusive ?? this.taxInclusive,
        lastSyncedAt:
            clearLastSyncedAt ? null : (lastSyncedAt ?? this.lastSyncedAt),
        serverUrl: serverUrl ?? this.serverUrl,
        deviceId: deviceId ?? this.deviceId,
      );

  @override
  List<Object?> get props => [
        businessName,
        taxRate,
        currencySymbol,
        receiptFooter,
        lastZReportAt,
        themeMode,
        logoPath,
        autoBackupEnabled,
        lastBackupAt,
        printerType,
        printerAddress,
        taxInclusive,
        lastSyncedAt,
        serverUrl,
        deviceId,
      ];
}
