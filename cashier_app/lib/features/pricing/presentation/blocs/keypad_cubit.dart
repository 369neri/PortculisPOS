import 'package:cashier_app/features/pricing/presentation/blocs/keypad_state.dart';
import 'package:cashier_app/features/pricing/presentation/widgets/command_key.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class KeypadCubit extends Cubit<KeypadState> {
  KeypadCubit(KeypadState initState) : super(initState);

  // Converts the buffer from list of ints to a BigInt. 
  BigInt _convertToBigInt(List<int> buffer) {
    String s = '';
    for (var n in buffer) {
      s += n.toString();
    }

    int? price = int.tryParse(s);

    if (price != null) {
      return BigInt.from(price);
    } else {
      throw Exception('cannot convert buffer to BigInt');
    }
  }

  // Handler for commands starting with "{".
  void _addCommand(String data) {
    var priceNum = _convertToBigInt(state.buffer);
    var cmdState = KeypadState(const [], stored: priceNum, command: data);
    emit(cmdState);
  }

  // Handler for processing attempts to enter leading zeros.
  void _addLeadingZero(String data) {
    if (state.buffer.isNotEmpty) {
      for (var i = 1; i <= data.length; i++) {
        state.buffer.add(0);
      }
    }
    emit(state);
  }

  // Handler for number entries.
  void _addNumber(String data) {
    var val = int.tryParse(data);
    if (val != null) {
      state.buffer.add(val);
    }
    emit(state);
  }

  /// Add and handle entered key codes.
  void add(String data) {
    switch (data[0]) {
      case '{': 
        _addCommand(data);
        break;
      case '0':
        _addLeadingZero(data);
        break;
      default:
        _addNumber(data);
        break;
    }
  }

  /// Remove the last number entered in the number buffer.
  void edit() {
    if (state.buffer.isNotEmpty) {
      state.buffer.removeLast();
    }
    emit(state);
  }

  /// Clear/empty the number buffer.
  void clear() => emit(KeypadState([]));

}