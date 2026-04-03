import 'package:cashier_app/features/pricing/presentation/state/keypad_command.dart';
import 'package:cashier_app/features/pricing/presentation/widgets/command_key.dart';
import 'package:cashier_app/features/pricing/presentation/widgets/num_key.dart';
import 'package:flutter/material.dart';

class NumKeypad extends StatelessWidget {
  const NumKeypad({super.key});

  @override
  Widget build(BuildContext context) {
    return
      const Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              NumKey('1'),
              NumKey('2'),
              NumKey('3'),
              CommandKey(
                label: 'times',
                command: KeypadCommand.times,
                icon: Icons.numbers,
              ),
            ],
          ),
          Row(
            children: [
              NumKey('4'),
              NumKey('5'),
              NumKey('6'),
              CommandKey(
                label: 'clear',
                command: KeypadCommand.clear,
                icon: Icons.cancel_outlined,
                backgroundColor: Colors.red,
              ),
            ],
          ),
          Row(
            children: [
              NumKey('7'),
              NumKey('8'),
              NumKey('9'),
              CommandKey(
                label: 'back',
                command: KeypadCommand.edit,
                icon: Icons.arrow_back,
                backgroundColor: Colors.amber,
              ),
            ],
          ),
          Row(
            children: [
              NumKey('0'),
              NumKey('00'),
              NumKey('000'),
              CommandKey(
                label: 'enter',
                command: KeypadCommand.enter,
                icon: Icons.keyboard_return,
                backgroundColor: Colors.green,
              ),
            ],
          ),
        ],
      );
  }
}
