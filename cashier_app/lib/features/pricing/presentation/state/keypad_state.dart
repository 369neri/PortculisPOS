import 'package:equatable/equatable.dart';

class KeypadState extends Equatable {
  final String _buffer;
  String get buffer => _buffer;
  set buffer (val) => _buffer;

  /// Store for previously entered price
  final BigInt? stored;
  final String? command;

  const KeypadState(this._buffer, {this.stored, this.command});
  const KeypadState.nil() : _buffer = '', stored = null, command = null;
  
  @override
  List<Object?> get props => [buffer];
}