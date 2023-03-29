import 'package:flutter/material.dart';

class CommandKey extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color? textColor;
  
  const CommandKey({ 
    required this.label,
    required this.icon,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
        onPressed: () {}, 

      ),
    );
  }
}