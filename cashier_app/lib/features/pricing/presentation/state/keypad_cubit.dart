import 'keypad_cubit_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/bigint_extension.dart';

class KeypadCubit extends Cubit<KeypadState> {
  KeypadCubit(KeypadState initState) : super(initState);

  /// Store commands like #times for later calculations.
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
  void addCommand(String data) {
    _storedCommand = KeypadCmdState(state.value, data);
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
      var newBuffer = state.value.substring(0, state.value.length - 1);
      emit(KeypadNumState(newBuffer));
      return;
    }
    emit(state);
  }

  String _times() {
    if (state.value.isNotEmpty) {
      var multiplicand = _storedCommand!.value.toBigInt();
      var multiplier = state.value.toBigInt();
      return (multiplicand * multiplier).toString();
    }
    throw Exception('Attempting to multiply by empty value');
  }

  /// Respond to presses of the enter/return key.
  void enter() {

    // Handle calculations with command.
    if (_storedCommand != null) {
      try {
        emit(KeypadResultState(_times()));
      } catch (e) {
        emit(KeypadErrorState(e.toString()));
      }
      _storedCommand = null;
      return;    
    }

    // Handle basic price entries.
    emit(KeypadResultState(state.value));
  }
}