import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/bigint_extension.dart';
import 'keypad_state.dart';

class KeypadCubit extends Cubit<KeypadState> {
  KeypadCubit(KeypadState initState) : super(initState);

  // Handler for adding multiple zeros.
  void _addZeros(String data) {
    if (state.buffer != '') {
      emit(KeypadState(
          '${state.buffer}$data', 
          stored: state.stored, 
          command: state.command,
      ));
    }
    emit(state);
  }

  /// Add and handle entered key codes.
  void add(String data) {
    switch (data[0]) {
      case '#': 
        emit(KeypadState('',
          stored: state.buffer,
          command: data,
        ));
        break;
      case '0':
        _addZeros(data);
        break;
      default:
        emit(KeypadState(
          '${state.buffer}$data', 
          stored: state.stored, 
          command: state.command,
        ));
        break;
    }
  }

  /// Clear/empty the number buffer.
  void clear() => emit(const KeypadState.nil());

  /// Remove the last number entered in the number buffer.
  void edit() {

    // Handle editing commands first.
    if (state.isCommand()) {
      emit(state.voidCommand());
      return;
    }

    // Handle editing numbers in the number buffer.
    if (state.buffer != '') {
      var newBuffer = state.buffer.substring(0, state.buffer.length - 1);
      emit(KeypadState(newBuffer));
      return;
    }
    emit(state);
  }

  BigInt _times() {
    var multiplicand = state.stored?.toBigInt();
    var multiplier = state.buffer.toBigInt();
    if (multiplicand != null) {
      return multiplicand * multiplier;
    }
    throw Exception('Attempting to multiply by null');
  }

  /// Respond to presses of the enter/return key.
  void enter() {

    // Handle calculations with command.
    if (state.isCommand() && state.stored != '') {
      try {
        emit(KeypadState.result(_times()));
      } catch (e) {
        emit(KeypadState.error(e as Exception));
      }
      return;    
    }

    // Handle basic price entries.
    emit(KeypadState.result(state.buffer.toBigInt()));
  }
}