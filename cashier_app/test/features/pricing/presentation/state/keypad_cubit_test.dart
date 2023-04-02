import 'package:cashier_app/features/pricing/presentation/state/keypad_cubit.dart';
import 'package:cashier_app/features/pricing/presentation/state/keypad_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

main() {
  group('Keypad Cubit', () {

    blocTest(
      'should emit "1" when "1" key is pressed',
      build: () => KeypadCubit(const KeypadState.nil()),
      act: (bloc) => bloc.add('1'),
      expect: () => [const KeypadState('1')],
    );

    blocTest(
      'should emit [1,2,3,4,5,6,7,8,9,0] when keys are pressed in sequence',
      build: () => KeypadCubit(const KeypadState.nil()),
      act: (bloc) {
        for (var i=1; i<=9; i++) {
          bloc.add(i.toString());
        }
        bloc.add('0');
      },
      expect: () => [
            const KeypadState('1'),
            const KeypadState('12'),
            const KeypadState('123'),
            const KeypadState('1234'),
            const KeypadState('12345'),
            const KeypadState('123456'),
            const KeypadState('1234567'),
            const KeypadState('12345678'),
            const KeypadState('123456789'),
            const KeypadState('1234567890')
      ],
    );

    blocTest(
      'should not allow a state leading with zero',
      build: () => KeypadCubit(const KeypadState.nil()),
      act: (bloc) => bloc.add('0'),
      expect: () => [const KeypadState.nil()],
    );

    blocTest(
      'should emit "100" on "1" + "00" key code sequence',
      build: () => KeypadCubit(const KeypadState('1')),
      act: (bloc) => bloc.add('00'),
      expect: () => [const KeypadState('100')],
    );

    blocTest(
      'should emit "1000" on "1" + "000" key code sequence',
      build: () => KeypadCubit(const KeypadState('1')),
      act: (bloc) => bloc.add('000'),
      expect: () => [const KeypadState('1000')],
    );

    blocTest(
      'should remove last digit from buffer on edit action', 
      build: () => KeypadCubit(const KeypadState('12')),
      act: (bloc) => bloc.edit(),
      expect: () => [const KeypadState('1')],
    );

    blocTest(
      'should do nothing when trying to edit an empty buffer', 
      build: () => KeypadCubit(const KeypadState.nil()),
      act: (bloc) => bloc.edit(),
      expect: () => [const KeypadState.nil()],
    );

    blocTest(
      'should set state to empty list on clear', 
      build: () => KeypadCubit(const KeypadState('1357')),
      act: (bloc) => bloc.clear(),
      expect: () => [const KeypadState.nil()],
    );

    blocTest('should store value and clear buffer when #times command is entered', 
      build: () => KeypadCubit(const KeypadState('123')),
      act: (bloc) => bloc.add('#times'),
      expect: () => [KeypadState('', stored: BigInt.from(123), command: '#times')],
      verify: (bloc) {
        expect(bloc.state.stored, BigInt.from(123));
        expect(bloc.state.command, '#times');
      }
    );

    blocTest(
      'should emit the result of calculation with #times function in buffer string', 
      build: () => KeypadCubit(const KeypadState('123')),
      act: (bloc) {
        bloc.add('#times');
        bloc.add('3');
      },
      expect: () => [
        KeypadState('', stored: BigInt.from(123), command: '#times'),
        KeypadState('3', stored: BigInt.from(123), command: '#times'),
      ],
    );

    blocTest(
      'should propagate values of command and stored number on current buffer', 
      build: () => KeypadCubit(KeypadState('', stored: BigInt.from(123), command: '#times')),
      act: (bloc) {
        bloc.add('1');
        bloc.add('0');
        bloc.add('1');
      },
      expect: () => [
        KeypadState('1', stored: BigInt.from(123), command: '#times'),
        KeypadState('10', stored: BigInt.from(123), command: '#times'),
        KeypadState('101', stored: BigInt.from(123), command: '#times'),
      ],
    );
  });
}