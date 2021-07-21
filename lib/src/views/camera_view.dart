// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_ion/flutter_ion.dart' as ion;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:ion_webrtc_demo/src/constants.dart';
import 'package:ion_webrtc_demo/src/data_channels.dart';

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
  ion.Signal? _signal;
  ion.LocalStream? _localStream;
  RTCDataChannel? _localDataChannel;
  RTCDataChannel? _imagesDataChannel;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();

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

  void _initClient() async {
    print("serverurl " + widget.addr);
    _signal = ion.JsonRPCSignal(widget.addr);
    _client = await ion.Client.create(
      sid: widget.sessionId,
      uid: widget.uuid,
      signal: _signal!,
    );
    _localStream = await ion.LocalStream.getUserMedia(
      constraints: ion.Constraints.defaults..simulcast = false,
    );
    _localDataChannel = await createDataChannel(
      _client!,
      binaryType: 'text',
      id: 42314,
      channel: Constants.commandsChannelLabel,
    );
    _imagesDataChannel = await createDataChannel(
      _client!,
      binaryType: 'binary',
      id: 213,
      channel: Constants.imageBinaryChannel,
    );
    _imagesDataChannel!.onDataChannelState = onBinaryChannelState;
    _localDataChannel!.onDataChannelState = onTextDataChannelState;
    await _client?.publish(_localStream!);
    await _localRenderer.initialize();
    setState(() {
      _localRenderer.srcObject = _localStream?.stream;
    });
  }

  onBinaryChannelState(RTCDataChannelState state) async {
    print("images socket state changed $state");
    if (state == RTCDataChannelState.RTCDataChannelOpen) {
      _imagesDataChannel!.messageStream
          .forEach((RTCDataChannelMessage msg) async {
        print("image onMessage ${msg.binary.length}");
      });
    }
  }

  onTextDataChannelState(RTCDataChannelState state) async {
    print("data socket state changed $state");
    if (state == RTCDataChannelState.RTCDataChannelOpen) {
      print("imageslocalDataChannel socket state changed $state");
      _localDataChannel!.messageStream
          .forEach((RTCDataChannelMessage msg) async {
        print("got msg ${msg.text}");
        const json = JsonDecoder();
        final parsedJson = json.convert(msg.text);
        print("got $parsedJson");
        if (parsedJson == null) {
          return;
        }
        final command = parsedJson["command"];
        if (command == "takePicture") {
          print("taking picture...");
          await takePicture();
        }
      });
    }
  }

  Future<void> takePicture() async {
    final frame = await _localStream!.stream
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video')
        .captureFrame();
    final bytes = frame.asUint8List();
    final sizeInBytes = frame.lengthInBytes;
    for (int i = 0; i < sizeInBytes; i += Constants.maximumMessageSize) {
      await _imagesDataChannel!.send(
        RTCDataChannelMessage.fromBinary(
          bytes.sublist(i, computeMessageUpperLimit(i, sizeInBytes)),
        ),
      );
    }
    await _imagesDataChannel!.send(
      RTCDataChannelMessage.fromBinary(Constants.endOfFileMessage),
    );
    print("sent bytes...");
  }

  computeMessageUpperLimit(accSize, totalSize) {
    return (accSize + Constants.maximumMessageSize > totalSize)
        ? totalSize
        : (accSize + Constants.maximumMessageSize);
  }
}
