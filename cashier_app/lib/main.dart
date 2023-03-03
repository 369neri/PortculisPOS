import 'package:flutter/material.dart';
import './features/get_started/presentation/pages/select_workplace.dart';

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
  bool _workplaceSet = false;

  void _setWorkplace() {
    setState(() {
      _workplaceSet = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Widget getStartedWidget = SelectWorkplace();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0), 
        child: Center(
            child: getStartedWidget
          ),
        )
    );
  }
}
