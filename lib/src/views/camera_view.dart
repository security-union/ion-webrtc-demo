// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_ion/flutter_ion.dart' as ion;
import 'package:ion_webrtc_demo/src/utils.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

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
  ion.Client? _client;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  ion.LocalStream? _localStream;

  @override
  void initState() {
    _initLocalRender();
    _scanQrCode()
        .then((_) => _startSharingCamera)
        .catchError((err) => alertDialog(context, err.toString()));
    super.initState();
  }

  @override
  void dispose() {
    _closeCall();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('You are a Camera'),
      ),
      floatingActionButton: _client != null
          ? FloatingActionButton(
              onPressed: _scanQrCode,
              child: const Icon(Icons.qr_code),
            )
          : null,
      body: _client == null
          ? const Center(
              child: Text('Scan a QR code to join a session'),
            )
          : Expanded(
              child: RTCVideoView(_localRenderer),
            ),
    );
  }

  Future<void> _scanQrCode() async {
    try {
      final data = await FlutterBarcodeScanner.scanBarcode(
        '#0000',
        'Cancel',
        true,
        ScanMode.QR,
      );

      final ionClient = await ion.Client.create(
        sid: data,
        uid: widget.uuid,
        signal: widget.signal,
      );

      if (!ionClient.initialized) {
        throw Exception(
            'There was an error connecting to the server, check the server address');
      }

      _client = ionClient;
    } on PlatformException {
      throw Exception('Scan failed, unable to get platform version');
    }
  }

  _initLocalRender() async {
    await _localRenderer.initialize();
  }

  void _startSharingCamera() async {
    _localStream = await ion.LocalStream.getUserMedia(
      constraints: ion.Constraints.defaults..simulcast = false,
    );
    setState(() {
      _localRenderer.srcObject = _localStream?.stream;
    });
    await _client?.publish(_localStream!);
  }

  void _closeCall() {
    _client?.close();
    _client = null;
  }
}
