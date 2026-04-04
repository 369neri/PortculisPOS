import 'package:cashier_app/features/archive/domain/entities/archive_kind.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Reference to a PDF saved in the local archive directory.
@immutable
class ArchivedFile extends Equatable {
  const ArchivedFile({
    required this.path,
    required this.displayName,
    required this.savedAt,
    required this.kind,
  });

  /// Absolute filesystem path to the PDF.
  final String path;

  /// Human-readable name shown in the UI (typically the filename minus path).
  final String displayName;

  /// Timestamp when the file was saved (derived from file stat mtime).
  final DateTime savedAt;

  /// Receipt or report.
  final ArchiveKind kind;

  @override
  List<Object?> get props => [path, displayName, savedAt, kind];
}
