import 'keypad_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      emit(state.cancelCommand());
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

  /// Respond to presses of the enter/return key.
  void enter() {

  }
}