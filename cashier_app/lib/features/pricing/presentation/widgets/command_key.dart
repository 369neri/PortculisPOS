import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/keypad_cubit.dart';

class CommandKey extends StatelessWidget {
  final String label;
  final String command;
  final IconData icon;
  final Color backgroundColor;
  final Color? textColor;
  
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
      padding: const EdgeInsets.all(2.0),
      child: ElevatedButton.icon(
        label: Text(label, style: const TextStyle(
          fontSize: 20.0,
        )),
        icon: Icon(icon),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          fixedSize: const Size(120.0, 80.0)
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