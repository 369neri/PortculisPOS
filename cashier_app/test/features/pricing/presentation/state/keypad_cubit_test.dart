import 'package:bloc_test/bloc_test.dart';
import 'package:cashier_app/features/pricing/presentation/state/keypad_command.dart';
import 'package:cashier_app/features/pricing/presentation/state/keypad_cubit.dart';
import 'package:cashier_app/features/pricing/presentation/state/keypad_cubit_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Keypad Cubit', () {

    blocTest<KeypadCubit, KeypadState>(
      'should emit "1" when "1" key is pressed',
      build: () => KeypadCubit(const KeypadInitialState()),
      act: (bloc) => bloc.addNumber('1'),
      expect: () => [const KeypadNumState('1')],
    );

    blocTest<KeypadCubit, KeypadState>(
      'should emit [1,2,3,4,5,6,7,8,9,0] when keys are pressed in sequence',
      build: () => KeypadCubit(const KeypadInitialState()),
      act: (bloc) {
        for (var i = 1; i <= 9; i++) {
          bloc.addNumber(i.toString());
        }
        bloc.addNumber('0');
      },
      expect: () => [
            const KeypadNumState('1'),
            const KeypadNumState('12'),
            const KeypadNumState('123'),
            const KeypadNumState('1234'),
            const KeypadNumState('12345'),
            const KeypadNumState('123456'),
            const KeypadNumState('1234567'),
            const KeypadNumState('12345678'),
            const KeypadNumState('123456789'),
            const KeypadNumState('1234567890'),
      ],
    );

    blocTest<KeypadCubit, KeypadState>(
      'should not allow a state leading with zero',
      build: () => KeypadCubit(const KeypadInitialState()),
      act: (bloc) => bloc.addNumber('0'),
      expect: () => [const KeypadInitialState()],
    );

    blocTest<KeypadCubit, KeypadState>(
      'should emit "100" on "1" + "00" key code sequence',
      build: () => KeypadCubit(const KeypadNumState('1')),
      act: (bloc) => bloc.addNumber('00'),
      expect: () => [const KeypadNumState('100')],
    );

    blocTest<KeypadCubit, KeypadState>(
      'should emit "1000" on "1" + "000" key code sequence',
      build: () => KeypadCubit(const KeypadNumState('1')),
      act: (bloc) => bloc.addNumber('000'),
      expect: () => [const KeypadNumState('1000')],
    );

    blocTest<KeypadCubit, KeypadState>(
      'should remove last digit from buffer on edit action',
      build: () => KeypadCubit(const KeypadNumState('12')),
      act: (bloc) => bloc.edit(),
      expect: () => [const KeypadNumState('1')],
    );

    blocTest<KeypadCubit, KeypadState>(
      'should do nothing when trying to edit an empty buffer',
      build: () => KeypadCubit(const KeypadInitialState()),
      act: (bloc) => bloc.edit(),
      expect: () => [const KeypadInitialState()],
    );

    blocTest<KeypadCubit, KeypadState>(
      'should set state to initialState on clear',
      build: () => KeypadCubit(const KeypadNumState('1357')),
      act: (bloc) => bloc.clear(),
      expect: () => [const KeypadInitialState()],
    );

    blocTest<KeypadCubit, KeypadState>(
      'should emit the result of calculation with times function',
      build: () => KeypadCubit(const KeypadNumState('123')),
      act: (bloc) {
        bloc
          ..addCommand(KeypadCommand.times)
          ..addNumber('3')
          ..enter();
      },
      expect: () => [
        const KeypadInitialState(),
        const KeypadNumState('3'),
        const KeypadResultState('369'),
      ],
    );

    blocTest<KeypadCubit, KeypadState>(
      'should yield result of basic price entry',
      build: () => KeypadCubit(const KeypadNumState('4302')),
      act: (bloc) => bloc.enter(),
      expect: () => [
        const KeypadResultState('4302'),
      ],
    );
  });
}
