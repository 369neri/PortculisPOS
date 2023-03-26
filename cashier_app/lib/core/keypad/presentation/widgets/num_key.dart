import 'package:flutter/material.dart';

class NumKey extends StatelessWidget {
  final String _numberString;
  const NumKey(this._numberString, {super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      autofocus: false,
      clipBehavior: Clip.hardEdge,   
      onPressed: () {}, 
      child: Text(_numberString),
    );
  }
}