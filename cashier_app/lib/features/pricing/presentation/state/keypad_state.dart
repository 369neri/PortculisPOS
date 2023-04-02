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

  const KeypadState.nil() : _buffer = '', 
    stored = null, 
    command = null, 
    result = null, 
    error = null;
  
  const KeypadState.result(this.result) : _buffer = '', 
    stored = null, 
    command = null, 
    error = null;
  
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
  KeypadState cancelCommand() {
    return KeypadState(stored ?? '', stored: null, command: null);
  }
}