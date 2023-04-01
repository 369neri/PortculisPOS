import 'keypad_state.dart';
import '../../../../core/extensions/bigint_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class KeypadCubit extends Cubit<KeypadState> {
  KeypadCubit(KeypadState initState) : super(initState);

  // Handler for commands starting with "{".
  void _addCommand(String data) {
    var priceNum = state.buffer.toBigInt(); // extension method
    emit(KeypadState(const [], stored: priceNum, command: data));
  }

  // Handler for adding multiple zeros.
  void _addZeros(String data) {
    if (state.buffer.isNotEmpty) {
      var newState = List<int>.from(state.buffer);
      for (var i = 1; i <= data.length; i++) {
        newState.add(0);
        emit(KeypadState(newState));
      }
    }
    emit(state);
  }

  // Handler for number entries.
  void _addNumber(String data) {
    var val = int.tryParse(data);
    List<int> newState;
    if (val != null) {
      if (state.buffer.isEmpty) {
        newState = [];
      } else {
        newState = state.buffer;
      }
      newState.add(val);
      emit(KeypadState(newState));
    }
  }

  /// Add and handle entered key codes.
  void add(String data) {
    switch (data[0]) {
      case '{': 
        _addCommand(data);
        break;
      case '0':
        _addZeros(data);
        break;
      default:
        _addNumber(data);
        break;
    }
  }

  /// Remove the last number entered in the number buffer.
  void edit() {
    if (state.buffer.isNotEmpty) {
      var newState = List<int>.from(state.buffer);
      newState.removeLast();
      emit(KeypadState(newState));
    }
    emit(state);
  }

  /// Clear/empty the number buffer.
  void clear() => emit(const KeypadState([]));

}