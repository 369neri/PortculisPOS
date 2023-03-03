import 'package:flutter/material.dart';

class SelectWorkplace extends StatelessWidget {
  const SelectWorkplace({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        TextField(
          decoration: InputDecoration(
            hintText: 'Enter your workplace code',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))
            )
          ),
        )    
      ]
        );
  }
}