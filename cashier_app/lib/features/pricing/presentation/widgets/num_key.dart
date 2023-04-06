import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/keypad_cubit.dart';

class NumKey extends StatelessWidget {
  final String _number;

  static const double keysize = 65;
  static const double padding = 2.5;
  static const double fontsize = 20.0;

  const NumKey(this._number, {super.key});

  @override
  Widget build(BuildContext context) {
    var keypadCubit = BlocProvider.of<KeypadCubit>(context);
    return Padding(
      padding: const EdgeInsets.all(padding),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(keysize, keysize)
        ),
        autofocus: false,
        clipBehavior: Clip.hardEdge,   
        onPressed: () => keypadCubit.addNumber(_number), 
        child: Text(_number, style: const TextStyle(fontSize: fontsize)),
      ),
    );
  }
}