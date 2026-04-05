import 'package:cashier_app/core/di/service_locator.dart';
import 'package:cashier_app/core/layout/responsive_layout.dart';
import 'package:cashier_app/features/archive/presentation/pages/archive_page.dart';
import 'package:cashier_app/features/auth/presentation/pages/login_page.dart';
import 'package:cashier_app/features/auth/presentation/pages/user_management_page.dart';
import 'package:cashier_app/features/auth/presentation/state/auth_cubit.dart';
import 'package:cashier_app/features/billing/presentation/pages/sales_register_page.dart';
import 'package:cashier_app/features/billing/presentation/state/sales_register_cubit.dart';
import 'package:cashier_app/features/cash_drawer/presentation/state/cash_drawer_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_cubit.dart';
import 'package:cashier_app/features/customers/presentation/pages/customer_list_page.dart';
import 'package:cashier_app/features/customers/presentation/state/customer_cubit.dart';
import 'package:cashier_app/features/items/presentation/pages/item_catalog_page.dart';
import 'package:cashier_app/features/items/presentation/state/item_lookup_cubit.dart';
import 'package:cashier_app/features/pricing/presentation/state/keypad_cubit.dart';
import 'package:cashier_app/features/reports/presentation/pages/reports_page.dart';
import 'package:cashier_app/features/reports/presentation/state/reports_cubit.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:cashier_app/features/settings/presentation/pages/settings_page.dart';
import 'package:cashier_app/features/settings/presentation/state/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initServiceLocator();
  runApp(const PortculisApp());
}

class PortculisApp extends StatelessWidget {
  const PortculisApp({super.key});

  static const _seedColor = Colors.indigo;

  static ThemeMode _resolveThemeMode(AppSettings settings) {
    return switch (settings.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => sl<AuthCubit>()..init(),
        ),
        BlocProvider<SettingsCubit>(create: (_) => sl<SettingsCubit>()),
        BlocProvider<KeypadCubit>(create: (_) => sl<KeypadCubit>()),
        BlocProvider<SalesRegisterCubit>(
          create: (_) => sl<SalesRegisterCubit>(),
        ),
        BlocProvider<ItemLookupCubit>(
          create: (_) => sl<ItemLookupCubit>(),
        ),
        BlocProvider<CheckoutCubit>(create: (_) => sl<CheckoutCubit>()),
        BlocProvider<TransactionHistoryCubit>(
          create: (_) => sl<TransactionHistoryCubit>(),
        ),
        BlocProvider<ReportsCubit>(
          create: (_) => sl<ReportsCubit>(),
        ),
        BlocProvider<CashDrawerCubit>(
          create: (_) => sl<CashDrawerCubit>(),
        ),
        BlocProvider<CustomerCubit>(
          create: (_) => sl<CustomerCubit>(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (prev, curr) {
          if (prev is SettingsReady && curr is SettingsReady) {
            return prev.settings.themeMode != curr.settings.themeMode;
          }
          return true;
        },
        builder: (context, settingsState) {
          final themeMode = settingsState is SettingsReady
              ? _resolveThemeMode(settingsState.settings)
              : ThemeMode.system;

          return MaterialApp(
            title: 'Portculis POS',
            themeMode: themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: _seedColor,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            home: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                return switch (authState) {
                  AuthInitial() =>
                    const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    ),
                  AuthLocked() => const LoginPage(),
                  AuthDisabled() || AuthAuthenticated() =>
                    const _AppShell(),
                };
              },
            ),
          );
        },
      ),
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _selectedIndex = 0;

  static const _pages = <Widget>[
    SalesRegisterPage(),
    ItemCatalogPage(),
    CustomerListPage(),
    ReportsPage(),
    SettingsPage(),
    ArchivePage(),
    UserManagementPage(),
  ];

  static const _destinations = <({IconData icon, IconData selectedIcon, String label})>[
    (icon: Icons.point_of_sale_outlined, selectedIcon: Icons.point_of_sale, label: 'Register'),
    (icon: Icons.inventory_2_outlined, selectedIcon: Icons.inventory_2, label: 'Catalog'),
    (icon: Icons.people_outlined, selectedIcon: Icons.people, label: 'Customers'),
    (icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart, label: 'Reports'),
    (icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: 'Settings'),
    (icon: Icons.folder_outlined, selectedIcon: Icons.folder, label: 'Archive'),
    (icon: Icons.manage_accounts_outlined, selectedIcon: Icons.manage_accounts, label: 'Users'),
  ];

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
    if (index == 3) {
      context.read<TransactionHistoryCubit>().load();
      context.read<ReportsCubit>().load();
      context.read<CashDrawerCubit>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = isWideScreen(context);

    return Scaffold(
      body: wide ? _buildRailLayout() : _buildPageBody(),
      bottomNavigationBar: wide ? null : _buildBottomBar(),
    );
  }

  Widget _buildPageBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: KeyedSubtree(
        key: ValueKey(_selectedIndex),
        child: _pages[_selectedIndex],
      ),
    );
  }

  Widget _buildBottomBar() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      destinations: [
        for (final d in _destinations)
          NavigationDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: d.label,
          ),
      ],
    );
  }

  Widget _buildRailLayout() {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onDestinationSelected,
          labelType: NavigationRailLabelType.all,
          destinations: [
            for (final d in _destinations)
              NavigationRailDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: Text(d.label),
              ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: _buildPageBody()),
      ],
    );
  }
}
