import 'package:flutter/material.dart';

class NumKey extends StatelessWidget {
  final String _numberString;
  const NumKey(this._numberString, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(80.0, 80.0)
        ),
        autofocus: false,
        clipBehavior: Clip.hardEdge,   
        onPressed: () {}, 
        child: Text(_numberString, style: const TextStyle(fontSize: 20.0)),
      ),
    );
  }
}