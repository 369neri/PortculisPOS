import 'package:flutter_bloc/flutter_bloc.dart';

class KeypadCubit extends Cubit<List<int>> {
  KeypadCubit(List<int> initState) : super(initState);

  void add(String number) {
  
    // Handle zero keys: "0", "00" and "000".
    if (number.startsWith('0')) {
      if (state.isNotEmpty) {
        for (var i = 1; i <= number.length; i++) {
          state.add(0);
        }
      }
      emit(state);
      return;
    }

    // Handle regular number keys.
    var val = int.tryParse(number);
    if (val != null) {
      state.add(val);
    }

    emit(state);
  }

  void edit() {
    if (state.isNotEmpty) {
      state.removeLast();
    }
    emit(state);
  }

  void clear() => emit(<int>[]);

}