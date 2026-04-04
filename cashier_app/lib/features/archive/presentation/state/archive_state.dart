import 'package:cashier_app/features/archive/domain/entities/archived_file.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class ArchiveState extends Equatable {
  const ArchiveState();
}

class ArchiveInitial extends ArchiveState {
  const ArchiveInitial();

  @override
  List<Object?> get props => [];
}

class ArchiveLoaded extends ArchiveState {
  const ArchiveLoaded({
    required this.receipts,
    required this.reports,
  });

  final List<ArchivedFile> receipts;
  final List<ArchivedFile> reports;

  @override
  List<Object?> get props => [receipts, reports];
}

class ArchiveError extends ArchiveState {
  const ArchiveError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
