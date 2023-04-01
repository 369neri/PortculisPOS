import 'package:equatable/equatable.dart';

class KeypadState extends Equatable {
  final List<int> _buffer;
  List<int> get buffer => _buffer;
  set buffer (val) => _buffer;

  /// Store for previously entered price
  final BigInt? stored;
  final String? command;

  const KeypadState(this._buffer, {this.stored, this.command});
  
  @override
  List<Object?> get props => [buffer];
}