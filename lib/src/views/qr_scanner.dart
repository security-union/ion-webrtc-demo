import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ion/flutter_ion.dart' as ion;
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
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  ion.GRPCWebSignal? signal;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    bool scanned = false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan a session QR'),
      ),
      body: _buildQrView(context, onScan: (sessionID) async {
        if (!scanned) {
          this.signal = ion.GRPCWebSignal(widget.addr);
          final client = await ion.Client.create(
            sid: sessionID,
            uid: widget.uuid,
            signal: this.signal!,
          );
          scanned = true;
          _navigatetoCamera(widget.uuid, client);
        }
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
      onQRViewCreated: (controller) =>
          _onQRViewCreated(controller, onScan: onScan),
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
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      final sessionId = scanData.code;
      onScan.call(sessionId);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _navigatetoCamera(String uuid, ion.Client client) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return CameraView(uuid: uuid, client: client);
        },
      ),
    );
  }
}
