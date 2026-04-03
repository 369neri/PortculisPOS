import 'package:cashier_app/features/pricing/presentation/state/keypad_command.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
abstract class KeypadState extends Equatable {

  const KeypadState(this.value) : super();
  final String value;

  @override
  List<Object?> get props => [value];
}

class KeypadInitialState extends KeypadState {
  const KeypadInitialState() : super('');
}

class KeypadNumState extends KeypadState {

  const KeypadNumState(this.buffer) : super(buffer);
  final String buffer;
}

class KeypadCmdState extends KeypadState {

  const KeypadCmdState(this.stored, this.command) : super(stored);
  final String stored;
  final KeypadCommand command;
}

class KeypadResultState extends KeypadState {

  const KeypadResultState(this.total) : super(total);
  final String total;
}

class KeypadErrorState extends KeypadState {

  const KeypadErrorState(this.message) : super(message);
  final String message;
}
