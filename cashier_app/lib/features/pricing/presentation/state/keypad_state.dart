import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class KeypadState extends Equatable {
  final String _buffer;
  String get buffer => _buffer;

  /// Store for previously entered price.
  final String? stored;

  /// Name of command sent starting with a '#' mark.
  final String? command;

  /// Final result of the entry after calculation.
  final BigInt? result;

  /// Any exceptions that occurred during calculation.
  final Exception? error;

  const KeypadState(this._buffer, {
    this.stored, 
    this.command,
    this.result,
    this.error,    
  });

  /// Constructor to create a new state with empty buffer.
  const KeypadState.nil() : _buffer = '', 
    stored = null, 
    command = null, 
    result = null, 
    error = null;
  
  /// Constructor to create result state.
  const KeypadState.result(this.result) : _buffer = '', 
    stored = null, 
    command = null, 
    error = null;
  
  /// Constructor to create an error state.
  const KeypadState.error(this.error) : _buffer = '', 
    stored = null, 
    command = null, 
    result = null;
  
  @override // Equatable
  List<Object?> get props => [buffer, stored, command, result, error];

  /// Test whether the state is in the command state.
  bool isCommand() {
    return (command != null);
  }

  /// Cancel a command sequence and restore the number buffer.
  KeypadState voidCommand() {
    return KeypadState(stored ?? '', 
      stored: null, 
      command: null, 
      result: null, 
      error: null);
  }
}