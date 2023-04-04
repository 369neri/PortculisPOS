import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
abstract class KeypadState extends Equatable {
  final String value;

  const KeypadState(this.value) : super();

  @override
  List<Object?> get props => [value];
}

class KeypadInitialState extends KeypadState {
  const KeypadInitialState() : super('');
}

class KeypadNumState extends KeypadState {
  final String buffer;

  const KeypadNumState(this.buffer) : super(buffer);
}

class KeypadCmdState extends KeypadState {
  final String stored;
  final String command;

  const KeypadCmdState(this.stored, this.command) : super(stored);
}

class KeypadResultState extends KeypadState {
  final String total;

  const KeypadResultState(this.total) : super(total);
}

class KeypadErrorState extends KeypadState {
  final String message;

  const KeypadErrorState(this.message) : super(message);
}