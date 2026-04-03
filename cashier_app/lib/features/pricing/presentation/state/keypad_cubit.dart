import 'package:cashier_app/core/extensions/bigint_extension.dart';
import 'package:cashier_app/features/pricing/presentation/state/keypad_command.dart';
import 'package:cashier_app/features/pricing/presentation/state/keypad_cubit_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class KeypadCubit extends Cubit<KeypadState> {
  KeypadCubit(super.initState);

  /// Store commands like times for later calculations.
  KeypadCmdState? _storedCommand;

  // Handler for adding multiple zeros.
  void _addZeros(String data) {
    if (state.value.isNotEmpty) {
      emit(KeypadNumState('${state.value}$data'));
      return;
    }
    emit(state);
  }

  /// Add and handle numbers entered as key codes.
  void addNumber(String data) {
    // Special handling to deal with leading zeroes.
    if (data.startsWith('0')) {
      _addZeros(data);
      return;
    }
    
    // Handle non-zero numbers.
    emit(KeypadNumState('${state.value}$data'));
  }

  /// Store commands and data as a cubit stored value.
  void addCommand(KeypadCommand command) {
    _storedCommand = KeypadCmdState(state.value, command);
    emit(const KeypadInitialState());
  }

  /// Clear/empty the number buffer.
  void clear() => emit(const KeypadInitialState());

  /// Remove the last number entered in the number buffer.
  void edit() {
    // Handle editing commands first.
    if (state is KeypadCmdState) {
      emit(KeypadNumState(state.value));
      return;
    }

    // Handle editing numbers in the number buffer.
    if (state.value != '') {
      final newBuffer = state.value.substring(0, state.value.length - 1);
      emit(KeypadNumState(newBuffer));
      return;
    }
    emit(state);
  }

  String _times() {
    if (state.value.isNotEmpty) {
      final multiplicand = _storedCommand!.value.toBigInt();
      final multiplier = state.value.toBigInt();
      return (multiplicand * multiplier).toString();
    }
    throw Exception('Attempting to multiply by empty value');
  }

  /// Respond to presses of the enter/return key.
  void enter() {

    // Handle calculations with command.
    if (_storedCommand != null) {
      try {
        switch (_storedCommand!.command) {
          case KeypadCommand.times:
            emit(KeypadResultState(_times()));
          case _:
            emit(KeypadErrorState('Unknown command: ${_storedCommand!.command}'));
        }
      } on Exception catch (e) {
        emit(KeypadErrorState(e.toString()));
      }
      _storedCommand = null;
      return;    
    }

    // Handle basic price entries.
    emit(KeypadResultState(state.value));
  }
}
