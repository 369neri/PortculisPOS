import 'package:bloc_test/bloc_test.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:cashier_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:cashier_app/features/settings/presentation/state/settings_cubit.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Test double
// ---------------------------------------------------------------------------

class _FakeRepo implements SettingsRepository {
  AppSettings _stored = const AppSettings();

  @override
  Future<AppSettings> getSettings() async => _stored;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _stored = settings;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeRepo repo;

  setUp(() => repo = _FakeRepo());

  // SettingsLoading is the *initial* state (set via super()), not emitted.
  // blocTest only captures subsequent emit() calls.
  blocTest<SettingsCubit, SettingsState>(
    'emits SettingsReady after loading settings',
    build: () => SettingsCubit(repo),
    expect: () => const [
      SettingsReady(AppSettings()),
    ],
  );

  blocTest<SettingsCubit, SettingsState>(
    'update saves and emits SettingsReady with new settings',
    build: () => SettingsCubit(repo),
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero); // let _load complete
      await cubit.update(
        const AppSettings(businessName: 'ACME', taxRate: 10),
      );
    },
    expect: () => const [
      SettingsReady(AppSettings()),
      SettingsReady(AppSettings(businessName: 'ACME', taxRate: 10)),
    ],
  );

  test('update persists settings to repository', () async {
    final cubit = SettingsCubit(repo);
    await Future<void>.delayed(Duration.zero);
    const updated = AppSettings(businessName: 'Shop', taxRate: 7.5);
    await cubit.update(updated);
    expect(repo._stored, updated);
    await cubit.close();
  });
}
