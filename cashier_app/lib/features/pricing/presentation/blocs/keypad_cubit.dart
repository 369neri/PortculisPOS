import 'package:cashier_app/features/pricing/presentation/blocs/keypad_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class KeypadCubit extends Cubit<KeypadState> {
  KeypadCubit(KeypadState initState) : super(initState);

  void add(String number) {
  
    // Handle zero keys: "0", "00" and "000".
    if (number.startsWith('0')) {
      if (state.buffer.isNotEmpty) {
        for (var i = 1; i <= number.length; i++) {
          state.buffer.add(0);
        }
      }
      emit(state);
      return;
    }

    // Handle regular number keys.
    var val = int.tryParse(number);
    if (val != null) {
      state.buffer.add(val);
    }

    emit(state);
  }

  void edit() {
    if (state.buffer.isNotEmpty) {
      state.buffer.removeLast();
    }
    emit(state);
  }

  void clear() => emit(KeypadState([]));

}