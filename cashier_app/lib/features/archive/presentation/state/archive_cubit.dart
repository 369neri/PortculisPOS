import 'package:cashier_app/features/archive/domain/entities/archive_kind.dart';
import 'package:cashier_app/features/archive/domain/entities/archived_file.dart';
import 'package:cashier_app/features/archive/domain/services/archive_service.dart';
import 'package:cashier_app/features/archive/presentation/state/archive_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArchiveCubit extends Cubit<ArchiveState> {
  ArchiveCubit(this._service) : super(const ArchiveInitial());

  final ArchiveService _service;

  Future<void> load() async {
    try {
      final receipts = await _service.listByKind(ArchiveKind.receipt);
      final reports = await _service.listByKind(ArchiveKind.report);
      emit(ArchiveLoaded(receipts: receipts, reports: reports));
    } on Exception catch (e) {
      emit(ArchiveError(e.toString()));
    }
  }

  Future<void> delete(ArchivedFile file) async {
    await _service.delete(file);
    await load();
  }

  Future<void> clearAll(ArchiveKind kind) async {
    await _service.clearAll(kind);
    await load();
  }
}
