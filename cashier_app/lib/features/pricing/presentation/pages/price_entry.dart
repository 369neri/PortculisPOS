import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/keypad_cubit.dart';
import '../state/keypad_cubit_state.dart';
import '../widgets/num_keypad.dart';

class PriceEntryPage extends StatelessWidget {
  const PriceEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (context) => KeypadCubit(const KeypadInitialState()),
      child: const NumKeypad(),
    );
  }
}
