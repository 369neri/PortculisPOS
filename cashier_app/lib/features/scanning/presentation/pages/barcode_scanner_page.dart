import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen camera scanner overlay. Returns the scanned barcode string
/// when a barcode is detected, or null if the user dismisses.
class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final _controller = MobileScannerController();
  bool _scanned = false;
  bool _permissionDenied = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;
    _scanned = true;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_permissionDenied) ...[
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: _controller.toggleTorch,
            ),
            IconButton(
              icon: const Icon(Icons.cameraswitch),
              onPressed: _controller.switchCamera,
            ),
          ],
        ],
      ),
      body: _permissionDenied
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.no_photography, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Camera permission is required to scan barcodes.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            )
          : MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error, child) {
                if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && !_permissionDenied) {
                      setState(() => _permissionDenied = true);
                    }
                  });
                }
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          error.errorCode == MobileScannerErrorCode.permissionDenied
                              ? 'Camera permission denied.'
                              : 'Camera error: ${error.errorCode.name}',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
