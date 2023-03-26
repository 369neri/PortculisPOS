import 'package:flutter/material.dart';

import 'num_key.dart';

class NumKeypad extends StatelessWidget {
  const NumKeypad({super.key});

  @override
  Widget build(BuildContext context) {
    return
      Row(
        children: [
          Column(
            children: const [
              NumKey('1'),
              NumKey('2'),
              NumKey('3'),
            ],
          ),
          Column(
            children: const [
              NumKey('4'),
              NumKey('5'),
              NumKey('6'),
            ],
          ),
          Column(
            children: const [
              NumKey('7'),
              NumKey('8'),
              NumKey('9'),
            ],
          ),
          Column(
            children: const [
              NumKey('0'),
              NumKey('00'),
              NumKey('000'),
            ],
          ),
        ],
      );
  }
}