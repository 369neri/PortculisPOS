import 'package:cashier_app/features/navigation/presentation/pages/hidden_menu_page.dart';
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
    return const Scaffold(
      body: HiddenMenu());
  }
}