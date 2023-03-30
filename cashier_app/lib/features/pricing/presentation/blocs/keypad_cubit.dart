import 'package:flutter_bloc/flutter_bloc.dart';

class KeypadCubit extends Cubit<List<int>> {
  KeypadCubit(List<int> initState) : super(initState);

  void add(String number) {
    if (number == '00') {
      state.add(0);
      state.add(0);
      emit(state);
      return;
    }

    if (number == '000') {
      state.add(0);
      state.add(0);
      state.add(0);
      emit(state);
      return;
    }

    var val = int.tryParse(number);

    if (val != null) {
      state.add(val);
      emit(state);
    }
  }

  void edit() {
    if (state.isNotEmpty) {
      state.removeLast();
      emit(state);
    }
  }

  void clear() => emit(<int>[]);

}