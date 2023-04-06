import 'package:cashier_app/features/pricing/presentation/pages/price_entry.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CashierApp());
}

class CashierApp extends StatelessWidget {
  const CashierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portculis Cashier',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const MainPage(title: 'Portculis Cashier'),
    );
  }
}

class MainPage extends StatelessWidget {
  final String title;

  const MainPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const PriceEntryPage(key: Key('entry_page'),));
  }
}