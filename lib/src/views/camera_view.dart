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
  ion.Client? _client;
  ion.LocalStream? _localStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  ion.Signal? _signal;

  @override
  void initState() {
    _initClient();
    super.initState();
  }

  @override
  void dispose() {
    _localStream?.unpublish();
    _localRenderer.dispose();
    _signal?.close();
    _client?.close();
    super.dispose();
  }

  void _initClient() async {
    print("serverurl " + widget.addr);
    _signal = ion.GRPCWebSignal(widget.addr);
    // create new client
    _client = await ion.Client.create(
        sid: widget.sessionId, uid: widget.uuid, signal: _signal!);
    // create get user camera stream
    _localStream = await ion.LocalStream.getUserMedia(
        constraints: ion.Constraints.defaults..simulcast = false);
    // publish the stream
    await _client?.publish(_localStream!);
    await _localRenderer.initialize();
    setState(() {
      _localRenderer.srcObject = _localStream?.stream;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('You are the camera'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: RTCVideoView(
          _localRenderer,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
        ),
      ),
    );
  }
}
