import 'package:cashier_app/features/pricing/presentation/widgets/num_keypad.dart';
import 'package:flutter/material.dart';

class PriceEntryPage extends StatelessWidget {
  const PriceEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: NumKeypad());
  }
}
