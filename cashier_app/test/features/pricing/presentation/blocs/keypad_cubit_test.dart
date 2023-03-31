import 'package:cashier_app/features/pricing/presentation/blocs/keypad_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  group('Keypad Cubit', () {
    blocTest(
      'should emit [] when nothing added', 
      build: () => KeypadCubit([]),
      expect: () => [],
    );

    blocTest(
      'should emit [1] when "1" key is pressed',
      build: () => KeypadCubit([]),
      act: (bloc) => bloc.add('1'),
      expect: () => [[1]],
    );

    blocTest(
      'should emit [1,2,3,4,5,6,7,8,9,0] when keys are pressed in sequence',
      build: () => KeypadCubit([]),
      act: (bloc) {
        bloc.add('1');
        bloc.add('2');
        bloc.add('3');
        bloc.add('4');
        bloc.add('5');
        bloc.add('6');
        bloc.add('7');
        bloc.add('8');
        bloc.add('9');
        bloc.add('0');
      },
      expect: () => [[1,2,3,4,5,6,7,8,9,0]],
    );

    blocTest(
      'should not allow a state leading with zero',
      build: () => KeypadCubit([]),
      act: (bloc) => bloc.add('0'),
      expect: () => [[]],
    );

    blocTest(
      'should emit [1,0,0] on "1" + "00" key code sequence',
      build: () => KeypadCubit([1]),
      act: (bloc) => bloc.add('00'),
      expect: () => [[1,0,0]],
    );

    blocTest(
      'should emit [1,0,0,0] on "1" + "000" key code sequence',
      build: () => KeypadCubit([1]),
      act: (bloc) => bloc.add('000'),
      expect: () => [[1,0,0,0]],
    );

    blocTest(
      'should remove last integer from list on edit action', 
      build: () => KeypadCubit([1,2]),
      act: (bloc) => bloc.edit(),
      expect: () => [[1]],
    );

    blocTest(
      'should do nothing when trying to edit an empty list', 
      build: () => KeypadCubit([]),
      act: (bloc) => bloc.edit(),
      expect: () => [[]],
    );

    blocTest(
      'should set state to empty list on clear', 
      build: () => KeypadCubit([1,3,5,7]),
      act: (bloc) => bloc.clear(),
      expect: () => [[]],
    );
  });
}