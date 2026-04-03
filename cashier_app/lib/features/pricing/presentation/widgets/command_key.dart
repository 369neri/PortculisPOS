import 'package:cashier_app/features/pricing/presentation/state/keypad_command.dart';
import 'package:cashier_app/features/pricing/presentation/state/keypad_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommandKey extends StatelessWidget {

  const CommandKey({ 
    required this.label,
    required this.command,
    required this.icon,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    super.key,
  });
  final String label;
  final KeypadCommand command;
  final IconData icon;
  final Color backgroundColor;
  final Color? textColor;
  
  static const double keyHeight = 65;
  static const double keyWidth = 100;
  static const double padding = 5;
  static const double fontsize = 15;

  @override
  Widget build(BuildContext context) {
    final keypadCubit = BlocProvider.of<KeypadCubit>(context);
    return Padding(
      padding: const EdgeInsets.only(left: padding),
      child: ElevatedButton.icon(
        label: Text(label, style: const TextStyle(
          fontSize: fontsize,
        ),),
        icon: Icon(icon),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          fixedSize: const Size(keyWidth, keyHeight),
        ),
        clipBehavior: Clip.hardEdge,
        onPressed: () {
          switch (command) {
            case KeypadCommand.clear:
              keypadCubit.clear();
            case KeypadCommand.edit:
              keypadCubit.edit();
            case KeypadCommand.enter:
              keypadCubit.enter();
            case KeypadCommand.times:
              keypadCubit.addCommand(command);
          }
        }, 

      ),
    );
  }
}
