import 'dart:typed_data';

/// Interface for anything that can be printed (receipts, reports, etc.).
///
/// Implementers produce bytes for both thermal (ESC/POS) and PDF output.
/// A single "Print" action inspects which path is available and calls the
/// appropriate method.
abstract class Printable {
  /// ESC/POS byte payload for 58 mm / 80 mm thermal printers.
  ///
  /// Returns `null` when this printable type has no thermal representation
  /// (e.g. a multi-page inventory report).
  Future<Uint8List?> toThermal();

  /// Full PDF document bytes suitable for system print dialog or file export.
  Future<Uint8List> toPdf();
}
