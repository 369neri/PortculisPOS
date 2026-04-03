import 'package:flutter/material.dart';

class SelectWorkplace extends StatelessWidget {
  const SelectWorkplace({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Enter your workplace code',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),    
      ],
    );
  }
}
