import 'package:cashier_app/core/di/service_locator.dart';
import 'package:cashier_app/features/billing/presentation/pages/sales_register_page.dart';
import 'package:cashier_app/features/billing/presentation/state/sales_register_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_cubit.dart';
import 'package:cashier_app/features/items/presentation/pages/item_catalog_page.dart';
import 'package:cashier_app/features/items/presentation/state/item_lookup_cubit.dart';
import 'package:cashier_app/features/pricing/presentation/state/keypad_cubit.dart';
import 'package:cashier_app/features/reports/presentation/pages/reports_page.dart';
import 'package:cashier_app/features/reports/presentation/state/reports_cubit.dart';
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
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
      ],
      child: MaterialApp(
        title: 'Portculis POS',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const _AppShell(),
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
    ReportsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) {
          setState(() => _selectedIndex = i);
          if (i == 2) {
            context.read<TransactionHistoryCubit>().load();
            context.read<ReportsCubit>().load();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale),
            label: 'Register',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Catalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
