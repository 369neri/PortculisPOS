import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:cashier_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsLoading()) {
    _load();
  }

  final SettingsRepository _repository;

  Future<void> _load() async {
    final settings = await _repository.getSettings();
    emit(SettingsReady(settings));
  }

  Future<void> update(AppSettings settings) async {
    await _repository.saveSettings(settings);
    emit(SettingsReady(settings));
  }
}
