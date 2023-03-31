// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cashier_app/features/pricing/presentation/blocs/keypad_cubit.dart';
import 'package:cashier_app/features/pricing/presentation/blocs/keypad_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

main() {
  group('Keypad Cubit', () {

    blocTest(
      'should emit [1] when "1" key is pressed',
      build: () => KeypadCubit(KeypadState([])),
      act: (bloc) => bloc.add('1'),
      expect: () => [KeypadState([1])],
    );

    blocTest(
      'should emit [1,2,3,4,5,6,7,8,9,0] when keys are pressed in sequence',
      build: () => KeypadCubit(KeypadState([])),
      act: (bloc) {
        for (var i=1; i<=9; i++) {
          bloc.add(i.toString());
        }
        bloc.add('0');
      },
      expect: () => [KeypadState([1,2,3,4,5,6,7,8,9,0])],
    );

    blocTest(
      'should not allow a state leading with zero',
      build: () => KeypadCubit(KeypadState([])),
      act: (bloc) => bloc.add('0'),
      expect: () => [KeypadState([])],
    );

    blocTest(
      'should emit [1,0,0] on "1" + "00" key code sequence',
      build: () => KeypadCubit(KeypadState([1])),
      act: (bloc) => bloc.add('00'),
      expect: () => [KeypadState([1,0,0])],
    );

    blocTest(
      'should emit [1,0,0,0] on "1" + "000" key code sequence',
      build: () => KeypadCubit(KeypadState([1])),
      act: (bloc) => bloc.add('000'),
      expect: () => [KeypadState([1,0,0,0])],
    );

    blocTest(
      'should remove last integer from list on edit action', 
      build: () => KeypadCubit(KeypadState([1,2])),
      act: (bloc) => bloc.edit(),
      expect: () => [KeypadState([1])],
    );

    blocTest(
      'should do nothing when trying to edit an empty list', 
      build: () => KeypadCubit(KeypadState([])),
      act: (bloc) => bloc.edit(),
      expect: () => [KeypadState([])],
    );

    blocTest(
      'should set state to empty list on clear', 
      build: () => KeypadCubit(KeypadState([1,3,5,7])),
      act: (bloc) => bloc.clear(),
      expect: () => [KeypadState([])],
    );

    blocTest('should store value and clear buffer when {times} command is entered', 
      build: () => KeypadCubit(KeypadState([1,2,3])),
      act: (bloc) => bloc.add('{times}'),
      expect: () => [KeypadState([])],
      verify: (bloc) {
        expect(bloc.state.stored, BigInt.from(123));
        expect(bloc.state.command, '{times}');
      }
    );
  });
}