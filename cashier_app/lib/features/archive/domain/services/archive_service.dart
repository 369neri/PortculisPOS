import 'dart:io';
import 'dart:typed_data';

import 'package:cashier_app/features/archive/domain/entities/archive_kind.dart';
import 'package:cashier_app/features/archive/domain/entities/archived_file.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/reports/domain/entities/sales_report.dart';
import 'package:path_provider/path_provider.dart' as pp;

/// Manages saving, listing, and deleting archived PDF files on disk.
class ArchiveService {
  /// Creates an [ArchiveService].
  ///
  /// Provide [baseDir] to override the root directory (useful for tests).
  /// When `null`, the platform application documents directory is used.
  ArchiveService({Future<Directory> Function()? baseDir})
      : _baseDir = baseDir ?? pp.getApplicationDocumentsDirectory;

  final Future<Directory> Function() _baseDir;

  static const _root = 'portculis_archive';

  // ── Save ──────────────────────────────────────────────────────────────

  /// Saves [bytes] as a receipt PDF and returns the created [File].
  Future<File> saveReceiptPdf(
    Uint8List bytes,
    Transaction transaction,
  ) async {
    final label = _sanitize(
      transaction.invoiceNumber ?? '${transaction.id ?? 0}',
    );
    final ts = _timestamp(transaction.createdAt);
    final name = 'receipt_${label}_$ts.pdf';
    return _write(ArchiveKind.receipt, name, bytes);
  }

  /// Saves [bytes] as a report PDF and returns the created [File].
  Future<File> saveReportPdf(
    Uint8List bytes,
    SalesReport report, {
    bool isZ = false,
  }) async {
    final prefix = isZ ? 'z' : 'x';
    final ts = _timestamp(report.periodEnd);
    final name = '${prefix}_report_$ts.pdf';
    return _write(ArchiveKind.report, name, bytes);
  }

  // ── List ──────────────────────────────────────────────────────────────

  /// Lists archived files of a given [kind], sorted newest-first.
  Future<List<ArchivedFile>> listByKind(ArchiveKind kind) async {
    final dir = await _kindDir(kind);
    if (!dir.existsSync()) return [];

    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.pdf'))
        .toList()
      ..sort((a, b) {
        final ma = a.statSync().modified;
        final mb = b.statSync().modified;
        return mb.compareTo(ma);
      });

    return files.map((f) {
      final stat = f.statSync();
      return ArchivedFile(
        path: f.path,
        displayName: f.uri.pathSegments.last,
        savedAt: stat.modified,
        kind: kind,
      );
    }).toList();
  }

  // ── Delete ────────────────────────────────────────────────────────────

  /// Deletes a single archived file.
  Future<void> delete(ArchivedFile file) async {
    final f = File(file.path);
    if (f.existsSync()) await f.delete();
  }

  /// Deletes all archived files for the given [kind].
  Future<void> clearAll(ArchiveKind kind) async {
    final dir = await _kindDir(kind);
    if (!dir.existsSync()) return;
    final files = dir.listSync().whereType<File>();
    for (final f in files) {
      await f.delete();
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  Future<Directory> _kindDir(ArchiveKind kind) async {
    final base = await _baseDir();
    final sub = kind == ArchiveKind.receipt ? 'receipts' : 'reports';
    return Directory('${base.path}/$_root/$sub');
  }

  Future<File> _write(
    ArchiveKind kind,
    String filename,
    Uint8List bytes,
  ) async {
    final dir = await _kindDir(kind);
    if (!dir.existsSync()) await dir.create(recursive: true);
    final file = File('${dir.path}/$filename');
    return file.writeAsBytes(bytes, flush: true);
  }

  /// Formats a [DateTime] as `YYYYMMdd_HHmmss_SSS`.
  static String _timestamp(DateTime dt) {
    final y = dt.year.toString();
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final ms = dt.millisecond.toString().padLeft(3, '0');
    return '$y$mo${d}_$h$mi${s}_$ms';
  }

  /// Replaces characters that are unsafe in filenames.
  static String _sanitize(String input) =>
      input.replaceAll(RegExp(r'[^\w\-]'), '_');
}
