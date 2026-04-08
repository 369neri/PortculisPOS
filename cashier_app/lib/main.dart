import 'dart:async';

import 'package:cashier_app/core/di/service_locator.dart';
import 'package:cashier_app/core/layout/responsive_layout.dart';
import 'package:cashier_app/core/logging/app_logger.dart';
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
import 'package:cashier_app/features/sync/presentation/state/sync_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      appLogger.e(
        'FlutterError: ${details.exceptionAsString()}',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    initServiceLocator();
    runApp(const PortculisApp());
  }, (error, stack) {
    appLogger.e('Uncaught exception', error: error, stackTrace: stack);
  });
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
        BlocProvider<SyncCubit>(
          create: (_) => sl<SyncCubit>(),
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
            builder: (context, child) => _ErrorBoundary(child: child!),
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
  DateTime _lastActivity = DateTime.now();
  static const _idleTimeout = Duration(minutes: 15);
  late final Timer _idleTimer;

  @override
  void initState() {
    super.initState();
    _idleTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _checkIdle(),
    );
  }

  @override
  void dispose() {
    _idleTimer.cancel();
    super.dispose();
  }

  // All available pages with admin-only flags.
  static const _allEntries = <({Widget page, IconData icon, IconData selectedIcon, String label, bool adminOnly})>[
    (page: SalesRegisterPage(), icon: Icons.point_of_sale_outlined, selectedIcon: Icons.point_of_sale, label: 'Register', adminOnly: false),
    (page: ItemCatalogPage(), icon: Icons.inventory_2_outlined, selectedIcon: Icons.inventory_2, label: 'Catalog', adminOnly: false),
    (page: CustomerListPage(), icon: Icons.people_outlined, selectedIcon: Icons.people, label: 'Customers', adminOnly: false),
    (page: ReportsPage(), icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart, label: 'Reports', adminOnly: false),
    (page: SettingsPage(), icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: 'Settings', adminOnly: true),
    (page: ArchivePage(), icon: Icons.folder_outlined, selectedIcon: Icons.folder, label: 'Archive', adminOnly: true),
    (page: UserManagementPage(), icon: Icons.manage_accounts_outlined, selectedIcon: Icons.manage_accounts, label: 'Users', adminOnly: true),
  ];

  bool get _isAdmin {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) return authState.user.isAdmin;
    // When auth is disabled, treat as admin (full access).
    return true;
  }

  List<({Widget page, IconData icon, IconData selectedIcon, String label, bool adminOnly})> get _visibleEntries {
    if (_isAdmin) return _allEntries;
    return _allEntries.where((e) => !e.adminOnly).toList();
  }

  void _onDestinationSelected(int index) {
    _lastActivity = DateTime.now();
    setState(() => _selectedIndex = index);
    final entries = _visibleEntries;
    if (index < entries.length && entries[index].label == 'Reports') {
      context.read<TransactionHistoryCubit>().load();
      context.read<ReportsCubit>().load();
      context.read<CashDrawerCubit>().load();
    }
  }

  void _recordActivity() => _lastActivity = DateTime.now();

  void _checkIdle() {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;
    if (DateTime.now().difference(_lastActivity) > _idleTimeout) {
      context.read<AuthCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = isWideScreen(context);
    final entries = _visibleEntries;
    // Clamp index in case role changed.
    if (_selectedIndex >= entries.length) _selectedIndex = 0;

    final authState = context.watch<AuthCubit>().state;
    final showLock = authState is AuthAuthenticated;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _recordActivity,
      onPanDown: (_) => _recordActivity(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(entries[_selectedIndex].label),
          actions: [
            if (showLock)
              IconButton(
                icon: const Icon(Icons.lock_outline),
                tooltip: 'Lock',
                onPressed: () => context.read<AuthCubit>().logout(),
              ),
          ],
        ),
        body: wide ? _buildRailLayout(entries) : _buildPageBody(entries),
        bottomNavigationBar: wide ? null : _buildBottomBar(entries),
      ),
    );
  }

  Widget _buildPageBody(List<({Widget page, IconData icon, IconData selectedIcon, String label, bool adminOnly})> entries) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: KeyedSubtree(
        key: ValueKey(_selectedIndex),
        child: entries[_selectedIndex].page,
      ),
    );
  }

  Widget _buildBottomBar(List<({Widget page, IconData icon, IconData selectedIcon, String label, bool adminOnly})> entries) {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      destinations: [
        for (final d in entries)
          NavigationDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: d.label,
          ),
      ],
    );
  }

  Widget _buildRailLayout(List<({Widget page, IconData icon, IconData selectedIcon, String label, bool adminOnly})> entries) {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onDestinationSelected,
          labelType: NavigationRailLabelType.all,
          destinations: [
            for (final d in entries)
              NavigationRailDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: Text(d.label),
              ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: _buildPageBody(entries)),
      ],
    );
  }
}

class _ErrorBoundary extends StatefulWidget {
  const _ErrorBoundary({required this.child});

  final Widget child;

  @override
  State<_ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<_ErrorBoundary> {
  FlutterErrorDetails? _error;

  @override
  void initState() {
    super.initState();
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      original?.call(details);
      if (mounted) setState(() => _error = details);
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Material(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!.exceptionAsString(),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => setState(() => _error = null),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widget.child;
  }
}
