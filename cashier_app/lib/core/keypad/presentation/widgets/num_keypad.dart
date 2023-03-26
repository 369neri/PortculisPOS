import 'package:flutter/material.dart';

import 'fun_key.dart';
import 'num_key.dart';

class NumKeypad extends StatelessWidget {
  const NumKeypad({super.key});

  @override
  Widget build(BuildContext context) {
    return
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: const [
              NumKey('1'),
              NumKey('2'),
              NumKey('3'),
              FunKey(
                label: 'times',
                icon: Icons.numbers,
              ),
            ],
          ),
          Row(
            children: const [
              NumKey('4'),
              NumKey('5'),
              NumKey('6'),
              FunKey(
                label: 'cancel',
                icon: Icons.cancel_outlined,
                backgroundColor: Colors.red,
              ),
            ],
          ),
          Row(
            children: const [
              NumKey('7'),
              NumKey('8'),
              NumKey('9'),
              FunKey(
                label: 'back',
                icon: Icons.arrow_back,
                backgroundColor: Colors.amber,
              ),
            ],
          ),
          Row(
            children: const [
              NumKey('0'),
              NumKey('00'),
              NumKey('000'),
              FunKey(
                label: 'enter',
                icon: Icons.keyboard_return,
                backgroundColor: Colors.green,
              ),
            ],
          ),
        ],
      );
  }
}