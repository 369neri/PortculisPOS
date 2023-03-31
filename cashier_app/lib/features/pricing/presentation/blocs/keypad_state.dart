import 'package:equatable/equatable.dart';

class KeypadState extends Equatable {
  final List<int> _buffer;
  List<int> get buffer => _buffer;
  set buffer (val) => _buffer;

  /// Store for previously entered price
  late BigInt? stored;
  late String? command;

  KeypadState(this._buffer);
  
  @override
  List<Object?> get props => [buffer];
}