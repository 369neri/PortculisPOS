import 'dart:io';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:cashier_app/features/archive/domain/entities/archive_kind.dart';
import 'package:cashier_app/features/archive/domain/entities/archived_file.dart';
import 'package:cashier_app/features/archive/domain/services/archive_service.dart';
import 'package:cashier_app/features/archive/presentation/state/archive_cubit.dart';
import 'package:cashier_app/features/archive/presentation/state/archive_state.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/reports/domain/entities/sales_report.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Test double
// ---------------------------------------------------------------------------

class _FakeArchiveService extends ArchiveService {
  _FakeArchiveService() : super(baseDir: () async => Directory.systemTemp);

  List<ArchivedFile> receipts = [];
  List<ArchivedFile> reports = [];
  Exception? error;
  int deleteCalls = 0;
  int clearAllCalls = 0;

  @override
  Future<List<ArchivedFile>> listByKind(ArchiveKind kind) async {
    if (error != null) throw error!;
    return kind == ArchiveKind.receipt ? receipts : reports;
  }

  @override
  Future<void> delete(ArchivedFile file) async {
    if (error != null) throw error!;
    deleteCalls++;
  }

  @override
  Future<void> clearAll(ArchiveKind kind) async {
    if (error != null) throw error!;
    clearAllCalls++;
    if (kind == ArchiveKind.receipt) {
      receipts = [];
    } else {
      reports = [];
    }
  }

  @override
  Future<File> saveReceiptPdf(Uint8List bytes, Transaction tx) async =>
      throw UnimplementedError();

  @override
  Future<File> saveReportPdf(
    Uint8List bytes,
    SalesReport report, {
    bool isZ = false,
  }) async =>
      throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final _receipt = ArchivedFile(
  path: '/tmp/receipts/receipt_001.pdf',
  displayName: 'receipt_001.pdf',
  savedAt: DateTime(2025, 7),
  kind: ArchiveKind.receipt,
);

final _report = ArchivedFile(
  path: '/tmp/reports/x_report_20250701.pdf',
  displayName: 'x_report_20250701.pdf',
  savedAt: DateTime(2025, 7),
  kind: ArchiveKind.report,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ArchiveCubit', () {
    late _FakeArchiveService service;

    setUp(() {
      service = _FakeArchiveService();
    });

    blocTest<ArchiveCubit, ArchiveState>(
      'load() emits ArchiveLoaded with receipts and reports',
      build: () {
        service
          ..receipts = [_receipt]
          ..reports = [_report];
        return ArchiveCubit(service);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        ArchiveLoaded(receipts: [_receipt], reports: [_report]),
      ],
    );

    blocTest<ArchiveCubit, ArchiveState>(
      'load() emits ArchiveLoaded with empty lists when nothing archived',
      build: () => ArchiveCubit(service),
      act: (cubit) => cubit.load(),
      expect: () => [
        const ArchiveLoaded(receipts: [], reports: []),
      ],
    );

    blocTest<ArchiveCubit, ArchiveState>(
      'load() emits ArchiveError when service throws',
      build: () {
        service.error = Exception('disk full');
        return ArchiveCubit(service);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<ArchiveError>(),
      ],
    );

    blocTest<ArchiveCubit, ArchiveState>(
      'delete() calls service.delete then reloads',
      build: () {
        service.receipts = [_receipt];
        return ArchiveCubit(service);
      },
      act: (cubit) => cubit.delete(_receipt),
      verify: (_) {
        expect(service.deleteCalls, equals(1));
      },
      expect: () => [
        // After delete, load() is called which re-fetches from fake
        ArchiveLoaded(receipts: [_receipt], reports: const []),
      ],
    );

    blocTest<ArchiveCubit, ArchiveState>(
      'clearAll() calls service.clearAll then reloads',
      build: () {
        service
          ..receipts = [_receipt]
          ..reports = [_report];
        return ArchiveCubit(service);
      },
      act: (cubit) => cubit.clearAll(ArchiveKind.receipt),
      verify: (_) {
        expect(service.clearAllCalls, equals(1));
      },
      expect: () => [
        // After clearAll, receipts is emptied by the fake, then load() emits
        ArchiveLoaded(receipts: const [], reports: [_report]),
      ],
    );
  });
}
