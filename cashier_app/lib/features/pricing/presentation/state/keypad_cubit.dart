import 'keypad_state.dart';
import '../../../../core/extensions/bigint_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class KeypadCubit extends Cubit<KeypadState> {
  KeypadCubit(KeypadState initState) : super(initState);

  // Handler for commands starting with "#".
  void _addCommand(String data) {
    var priceNum = state.buffer.toBigInt(); // extension method
    emit(KeypadState(
      '', 
      stored: priceNum, 
      command: data,
    ));
  }

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
        _addCommand(data);
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
    if (state.isCommand()) {
      emit(state.cancelCommand());
      return;
    }

    if (state.buffer != '' && state.buffer[0] != '#') {
      var newBuffer = state.buffer.substring(0, state.buffer.length - 1);
      emit(KeypadState(newBuffer));
      return;
    }
    emit(state);
  }
}