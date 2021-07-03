// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_ion/flutter_ion.dart' as ion;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class CameraView extends StatefulWidget {
  const CameraView({
    Key? key,
    required this.uuid,
    required this.signal,
  }) : super(key: key);

  final ion.Signal signal;
  final String uuid;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  ion.LocalStream? _localStream;
  QRViewController? _controller;
  ion.Client? _client;

  @override
  void initState() {
    _initLocalRender();
    super.initState();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller?.pauseCamera();
    }
    _controller?.resumeCamera();
  }

  @override
  void dispose() {
    _closeCall();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('You are a Camera'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _closeCall()),
      ),
      body: _client == null
          ? _buildQrView(context, onData: _onScanData)
          : Expanded(child: RTCVideoView(_localRenderer)),
    );
  }

  _initLocalRender() async {
    await _localRenderer.initialize();
  }

  _onScanData(Barcode data) async {
    final sessionId = data.code;
    final ionClient = await ion.Client.create(
      sid: sessionId,
      uid: widget.uuid,
      signal: widget.signal,
    );
    setState(() {
      _client = ionClient;
    });
    _startSharingCamera(_client!);
  }

  void _startSharingCamera(ion.Client client) async {
    _localStream = await ion.LocalStream.getUserMedia(
      constraints: ion.Constraints.defaults..simulcast = false,
    );
    setState(() {
      _localRenderer.srcObject = _localStream?.stream;
    });
    await _client?.publish(_localStream!);
  }

  Widget _buildQrView(
    BuildContext context, {
    required Function(Barcode data) onData,
  }) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: _qrKey,
      onQRViewCreated: (controller) =>
          _onQRViewCreated(controller, onData: onData),
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
    required Function(Barcode data) onData,
  }) {
    setState(() => _controller = controller);
    controller.scannedDataStream.listen(onData);
  }

  void _closeCall() {
    _client?.close();
    _client = null;
  }
}
