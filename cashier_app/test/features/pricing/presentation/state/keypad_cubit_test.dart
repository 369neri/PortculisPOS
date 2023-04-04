import 'package:cashier_app/features/pricing/presentation/state/keypad_cubit_state.dart';
import 'package:cashier_app/features/pricing/presentation/state/keypad_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

main() {
  group('Keypad Cubit', () {

    blocTest(
      'should emit "1" when "1" key is pressed',
      build: () => KeypadCubit(const KeypadInitialState()),
      act: (bloc) => bloc.addNumber('1'),
      expect: () => [const KeypadNumState('1')],
    );

    blocTest(
      'should emit [1,2,3,4,5,6,7,8,9,0] when keys are pressed in sequence',
      build: () => KeypadCubit(const KeypadInitialState()),
      act: (bloc) {
        for (var i=1; i<=9; i++) {
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
            const KeypadNumState('1234567890')
      ],
    );

    blocTest(
      'should not allow a state leading with zero',
      build: () => KeypadCubit(const KeypadInitialState()),
      act: (bloc) => bloc.addNumber('0'),
      expect: () => [const KeypadInitialState()],
    );

    blocTest(
      'should emit "100" on "1" + "00" key code sequence',
      build: () => KeypadCubit(const KeypadNumState('1')),
      act: (bloc) => bloc.addNumber('00'),
      expect: () => [const KeypadNumState('100')],
    );

    blocTest(
      'should emit "1000" on "1" + "000" key code sequence',
      build: () => KeypadCubit(const KeypadNumState('1')),
      act: (bloc) => bloc.addNumber('000'),
      expect: () => [const KeypadNumState('1000')],
    );

    blocTest(
      'should remove last digit from buffer on edit action', 
      build: () => KeypadCubit(const KeypadNumState('12')),
      act: (bloc) => bloc.edit(),
      expect: () => [const KeypadNumState('1')],
    );

    blocTest(
      'should do nothing when trying to edit an empty buffer', 
      build: () => KeypadCubit(const KeypadInitialState()),
      act: (bloc) => bloc.edit(),
      expect: () => [const KeypadInitialState()],
    );

    blocTest(
      'should set state to initialState on clear', 
      build: () => KeypadCubit(const KeypadNumState('1357')),
      act: (bloc) => bloc.clear(),
      expect: () => [const KeypadInitialState()],
    );

    // blocTest('should store value and clear buffer when #times command is entered', 
    //   build: () => KeypadCubit(const KeypadNumState('123')),
    //   act: (bloc) => bloc.addCommand('#times'),
    //   expect: () => [const KeypadState('', stored: '123', command: '#times')],
    //   verify: (bloc) {
    //     expect(bloc.state.stored, '123');
    //     expect(bloc.state.command, '#times');
    //   }
    // );

    blocTest(
      'should emit the result of calculation with #times function', 
      build: () => KeypadCubit(const KeypadNumState('123')),
      act: (bloc) {
        bloc.addCommand('#times');
        bloc.addNumber('3');
        bloc.enter();
      },
      expect: () => [
        const KeypadInitialState(),
        const KeypadNumState('3'),
        const KeypadResultState('369'),
      ],
    );

  blocTest(
    'should yield result of basic price entry', 
    build: () => KeypadCubit(const KeypadNumState('4302')),
    act: (bloc) => bloc.enter(),
    expect: () => [
      const KeypadResultState('4302'),
    ]);
  });
}