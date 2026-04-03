part of 'settings_cubit.dart';

@immutable
sealed class SettingsState extends Equatable {
  const SettingsState();
}

final class SettingsLoading extends SettingsState {
  const SettingsLoading();

  @override
  List<Object?> get props => [];
}

final class SettingsReady extends SettingsState {
  const SettingsReady(this.settings);

  final AppSettings settings;

  @override
  List<Object?> get props => [settings];
}
