import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/keypad_cubit.dart';

class CommandKey extends StatelessWidget {
  final String label;
  final String command;
  final IconData icon;
  final Color backgroundColor;
  final Color? textColor;
  
  static const double keyHeight = 65;
  static const double keyWidth = 100;
  static const double padding = 5.0;
  static const double fontsize = 15.0;

  const CommandKey({ 
    required this.label,
    required this.command,
    required this.icon,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var keypadCubit = BlocProvider.of<KeypadCubit>(context);
    return Padding(
      padding: const EdgeInsets.only(left: padding),
      child: ElevatedButton.icon(
        label: Text(label, style: const TextStyle(
          fontSize: fontsize,
        )),
        icon: Icon(icon),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          fixedSize: const Size(keyWidth, keyHeight)
        ),
        autofocus: false,
        clipBehavior: Clip.hardEdge,
        onPressed: () {
          switch (command) {
            case 'clear':
              keypadCubit.clear();
              break;
            case 'edit':
              keypadCubit.edit();
              break;
            case 'enter':
              keypadCubit.enter();
              break;
            default:
              keypadCubit.addCommand(command);
              break;
          }
        }, 

      ),
    );
  }
}