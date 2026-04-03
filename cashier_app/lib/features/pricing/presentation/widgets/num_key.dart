import 'package:cashier_app/features/pricing/presentation/state/keypad_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NumKey extends StatelessWidget {

  const NumKey(this._number, {super.key});
  final String _number;

  static const double keysize = 65;
  static const double padding = 2.5;
  static const double fontsize = 20;

  @override
  Widget build(BuildContext context) {
    final keypadCubit = BlocProvider.of<KeypadCubit>(context);
    return Padding(
      padding: const EdgeInsets.all(padding),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(keysize, keysize),
        ),
        clipBehavior: Clip.hardEdge,   
        onPressed: () => keypadCubit.addNumber(_number), 
        child: Text(_number, style: const TextStyle(fontSize: fontsize)),
      ),
    );
  }
}
