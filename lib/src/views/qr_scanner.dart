// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ion_webrtc_demo/src/views/camera_view.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerView extends StatefulWidget {
  const QRScannerView({
    Key? key,
    required this.uuid,
    required this.addr,
  }) : super(key: key);

  final String addr;
  final String uuid;

  @override
  State<StatefulWidget> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  QRViewController? _controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller!.pauseCamera();
    } else {
      _controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan a session QR'),
      ),
      body: _buildQrView(context, onScan: (sessionID) async {
        await _navigateToCamera(widget.uuid, sessionID, widget.addr);
      }),
    );
  }

  Widget _buildQrView(
    BuildContext context, {
    required Function(String) onScan,
  }) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: (controller) {
        setState(() {
          _controller = controller;
        });
        _onQRViewCreated(controller, onScan: onScan);
      },
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(
    QRViewController controller, {
    required Function(String) onScan,
  }) {
    controller.scannedDataStream.listen((scanData) async {
      final sessionId = scanData.code;
      await controller.stopCamera();
      onScan.call(sessionId);
    });
  }

  Future<void> _navigateToCamera(
    String uuid,
    String sessionId,
    String addr,
  ) async {
    await _closeCamera();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return CameraView(uuid: uuid, sessionId: sessionId, addr: addr);
        },
      ),
    );
  }

  Future<void> _closeCamera() async {
    try {
      await _controller?.stopCamera();
    } catch (e) {
      print('Error stopping camera');
    } finally {
      _controller?.dispose();
    }
  }
}
