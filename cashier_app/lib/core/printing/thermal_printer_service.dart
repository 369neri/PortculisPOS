import 'dart:io';
import 'dart:typed_data';

import 'package:cashier_app/core/logging/app_logger.dart';

/// Supported thermal printer connection types.
enum PrinterType {
  none,
  network,
  usb,
}

/// Sends raw ESC/POS bytes to a configured thermal printer.
class ThermalPrinterService {
  const ThermalPrinterService._();

  /// Send [bytes] to a network printer at [address] (format: `host:port`).
  ///
  /// Opens a TCP socket, writes the payload, then closes.
  static Future<void> printNetwork(
    Uint8List bytes,
    String address, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final parts = address.split(':');
    final host = parts.first;
    final port = parts.length > 1 ? int.tryParse(parts[1]) ?? 9100 : 9100;

    Socket? socket;
    try {
      socket = await Socket.connect(host, port, timeout: timeout);
      socket.add(bytes);
      await socket.flush();
    } finally {
      await socket?.close();
    }
  }

  /// Send [bytes] to a USB printer via a device file path (Linux).
  ///
  /// Typical paths: `/dev/usb/lp0`, `/dev/usb/lp1`.
  static Future<void> printUsb(Uint8List bytes, String devicePath) async {
    final file = File(devicePath);
    if (!file.existsSync()) {
      throw PrinterException('USB device not found: $devicePath');
    }
    await file.writeAsBytes(bytes, mode: FileMode.append, flush: true);
  }

  /// Convenience: send [bytes] based on configured [type] and [address].
  static Future<void> send(
    Uint8List bytes, {
    required PrinterType type,
    required String address,
  }) async {
    switch (type) {
      case PrinterType.none:
        return; // No printer configured — silently skip.
      case PrinterType.network:
        await printNetwork(bytes, address);
      case PrinterType.usb:
        await printUsb(bytes, address);
    }
  }

  /// Attempt a test print to verify connectivity.
  static Future<void> testPrint({
    required PrinterType type,
    required String address,
  }) async {
    // Simple "Printer OK" test page.
    final buf = BytesBuilder(copy: false)
      ..add(Uint8List.fromList([0x1B, 0x40])) // init
      ..add(Uint8List.fromList([0x1B, 0x61, 0x01])) // center
      ..add(Uint8List.fromList([0x1B, 0x45, 0x01])) // bold on
      ..add(Uint8List.fromList('Printer Test'.codeUnits))
      ..addByte(0x0A)
      ..add(Uint8List.fromList([0x1B, 0x45, 0x00])) // bold off
      ..add(Uint8List.fromList('Connection OK'.codeUnits))
      ..addByte(0x0A)
      ..add(Uint8List.fromList(List.filled(4, 0x0A))) // feed
      ..add(Uint8List.fromList([0x1D, 0x56, 0x00])); // cut

    try {
      await send(buf.toBytes(), type: type, address: address);
    } on Exception catch (e, st) {
      appLogger.e('Test print failed', error: e, stackTrace: st);
      rethrow;
    }
  }
}

class PrinterException implements Exception {
  const PrinterException(this.message);
  final String message;

  @override
  String toString() => 'PrinterException: $message';
}
