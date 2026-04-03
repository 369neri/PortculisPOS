import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/pricing/presentation/state/keypad_cubit.dart';
import 'package:cashier_app/features/pricing/presentation/state/keypad_cubit_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class KeypadDisplay extends StatelessWidget {
  const KeypadDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KeypadCubit, KeypadState>(
      builder: (context, state) {
        final text = _formatValue(state);
        final isError = state is KeypadErrorState;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: isError
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
          ),
        );
      },
    );
  }

  String _formatValue(KeypadState state) {
    if (state is KeypadErrorState) return state.message;
    if (state.value.isEmpty) return Price.from(0).toString();
    final parsed = BigInt.tryParse(state.value);
    if (parsed == null) return state.value;
    return Price(parsed).toString();
  }
}
