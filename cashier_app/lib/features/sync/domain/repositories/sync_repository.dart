import 'package:cashier_app/features/sync/data/datasources/remote_sync_datasource.dart';

abstract interface class SyncRepository {
  /// Push all local data to the remote server.
  ///
  /// Returns the server's sync timestamp.
  Future<DateTime> pushChanges({required String deviceId});

  /// Pull remote changes since [since] and merge into local storage.
  ///
  /// Returns the payload that was applied.
  Future<SyncPayload> pullAndMerge({
    required String deviceId,
    DateTime? since,
  });
}
