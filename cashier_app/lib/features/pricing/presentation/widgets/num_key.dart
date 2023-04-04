import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/keypad_cubit.dart';

class NumKey extends StatelessWidget {
  final String _numberString;

  const NumKey(this._numberString, {super.key});

  @override
  Widget build(BuildContext context) {
    var keypadCubit = BlocProvider.of<KeypadCubit>(context);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(80.0, 80.0)
        ),
        autofocus: false,
        clipBehavior: Clip.hardEdge,   
        onPressed: () => keypadCubit.addNumber(_numberString), 
        child: Text(_numberString, style: const TextStyle(fontSize: 20.0)),
      ),
    );
  }
}