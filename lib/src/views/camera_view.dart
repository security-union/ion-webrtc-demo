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
  ion.GRPCWebSignal? _signal;
  ion.Client? _client;

  @override
  void initState() {
    _startSharingCamera();
    super.initState();
  }

  @override
  Future<void> dispose() async {
    await _localStream?.unpublish();
    await _localRenderer.dispose();
    _client?.close();
    _signal?.close();
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
    final signal = ion.GRPCWebSignal(widget.addr);
    final client = await ion.Client.create(
      sid: widget.sessionId,
      uid: widget.uuid,
      signal: signal,
    );
    await _localRenderer.initialize();
    final localStream = await ion.LocalStream.getUserMedia(
      constraints: ion.Constraints.defaults..simulcast = false,
    );
    setState(() {
      _signal = signal;
      _client = client;
      _localStream = localStream;
      _localRenderer.srcObject = _localStream!.stream;
    });
    await _client!.publish(_localStream!);
  }
}
