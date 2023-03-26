import 'package:cashier_app/core/keypad/presentation/widgets/num_keypad.dart';
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

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const NumKeypad());
  }
}
