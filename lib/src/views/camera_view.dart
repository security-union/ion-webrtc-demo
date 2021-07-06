// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_ion/flutter_ion.dart' as ion;
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CameraView extends StatefulWidget {
  const CameraView(
      {Key? key,
      required this.uuid,
      required this.sessionId,
      required this.addr})
      : super(key: key);

  final String uuid;
  final String addr;
  final String sessionId;
  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  ion.LocalStream? _localStream;
  ion.GRPCWebSignal? signal;
  ion.Client? client;

  @override
  void initState() {
    _startSharingCamera();
    super.initState();
  }

  @override
  void dispose() {
    this.client!.close();
    this.signal!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('You are a Camera'),
      ),
      body: RTCVideoView(_localRenderer, mirror: true),
    );
  }

  Future<void> _startSharingCamera() async {
    this.signal = ion.GRPCWebSignal(widget.addr);
    this.client = await ion.Client.create(
      sid: widget.sessionId,
      uid: widget.uuid,
      signal: this.signal!,
    );
    await _localRenderer.initialize();
    final localStream = await ion.LocalStream.getUserMedia(
      constraints: ion.Constraints.defaults..simulcast = false,
    );
    setState(() {
      _localStream = localStream;
      _localRenderer.srcObject = _localStream!.stream;
    });
    await this.client!.publish(_localStream!);
  }
}
