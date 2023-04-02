import 'package:equatable/equatable.dart';

class KeypadState extends Equatable {
  final String _buffer;
  String get buffer => _buffer;
  set buffer (val) => _buffer;

  /// Store for previously entered price
  final String? stored;
  final String? command;

  const KeypadState(this._buffer, {this.stored, this.command});
  const KeypadState.nil() : _buffer = '', stored = null, command = null;
  
  @override
  List<Object?> get props => [buffer, stored, command];

  /// Test whether the state is in the command state.
  bool isCommand() {
    return (command != null);
  }

  /// Cancel a command sequence and restore the number buffer.
  KeypadState cancelCommand() {
    return KeypadState(stored ?? '', stored: null, command: null);
  }
}