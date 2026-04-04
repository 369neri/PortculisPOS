import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:cashier_app/features/settings/presentation/state/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  late TestDeps deps;

  setUp(() {
    deps = TestDeps();
  });

  tearDown(() => deps.dispose());

  group('Settings flow (full stack)', () {
    test('default settings are loaded on first run', () async {
      final cubit = SettingsCubit(deps.settingsRepo);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(cubit.state, isA<SettingsReady>());
      final settings = (cubit.state as SettingsReady).settings;
      expect(settings.businessName, 'My Business');
      expect(settings.taxRate, 0.0);
      expect(settings.currencySymbol, r'$');
      expect(settings.receiptFooter, 'Thank you for your business!');
      expect(settings.lastZReportAt, isNull);

      await cubit.close();
    });

    test('update settings persists across cubit instances', () async {
      final cubit1 = SettingsCubit(deps.settingsRepo);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await cubit1.update(
        const AppSettings(
          businessName: 'Portculis Cafe',
          taxRate: 8.5,
          currencySymbol: '€',
          receiptFooter: 'Merci beaucoup!',
        ),
      );

      final updated = (cubit1.state as SettingsReady).settings;
      expect(updated.businessName, 'Portculis Cafe');
      expect(updated.taxRate, 8.5);
      expect(updated.currencySymbol, '€');
      expect(updated.receiptFooter, 'Merci beaucoup!');
      await cubit1.close();

      // Create a new cubit that reads from the same DB
      final cubit2 = SettingsCubit(deps.settingsRepo);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final reloaded = (cubit2.state as SettingsReady).settings;
      expect(reloaded.businessName, 'Portculis Cafe');
      expect(reloaded.taxRate, 8.5);
      expect(reloaded.currencySymbol, '€');
      expect(reloaded.receiptFooter, 'Merci beaucoup!');
      await cubit2.close();
    });

    test('partial settings update preserves other fields', () async {
      final cubit = SettingsCubit(deps.settingsRepo);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Set a custom business name
      await cubit.update(
        const AppSettings(businessName: 'My Cafe', taxRate: 5),
      );

      // Update only the tax rate (via copyWith preserves business name)
      final current = (cubit.state as SettingsReady).settings;
      await cubit.update(current.copyWith(taxRate: 7.5));

      final result = (cubit.state as SettingsReady).settings;
      expect(result.businessName, 'My Cafe');
      expect(result.taxRate, 7.5);

      await cubit.close();
    });
  });
}
