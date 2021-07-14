// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ion/flutter_ion.dart' as ion;
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'host_view.dart';

int MAXIMUM_MESSAGE_SIZE = 65000;

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

  RTCDataChannel? _localDataChannel;

  RTCDataChannel? _imagesDataChannel;

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

    var localDataInit = RTCDataChannelInit();
    localDataInit.binaryType = 'text';
    localDataInit.id = 42314;
    _localDataChannel =
        await _client?.createDataChannel(COMMANDS_CHANNEL_LABEL, localDataInit);
    _localDataChannel?.onDataChannelState = (RTCDataChannelState state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        print("imageslocalDataChannel socket state changed ${state}");
        _localDataChannel!.messageStream
            .forEach((RTCDataChannelMessage msg) async {
          print("got msg ${msg.text}");
          final json = JsonDecoder();
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
    };
    var init = RTCDataChannelInit();
    init.binaryType = 'binary';
    init.id = 213;
    _imagesDataChannel =
        await _client?.createDataChannel(IMAGE_BINARY_CHANNEL, init);
    _imagesDataChannel!.onDataChannelState = (RTCDataChannelState state) {
      print("images socket state changed ${state}");
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        _imagesDataChannel!.messageStream
            .forEach((RTCDataChannelMessage msg) async {
          print("image onMessage ${msg.binary.length}");
        });
      }
    };

    setState(() {
      _localRenderer.srcObject = _localStream?.stream;
    });
  }

  Future<void> takePicture() async {
    final videoTrack = _localStream!.stream
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    final frame = await videoTrack.captureFrame();
    final bytes = frame.asUint8List();
    final sizeInBytes = frame.lengthInBytes;
    for (var i = 0; i < sizeInBytes; i += MAXIMUM_MESSAGE_SIZE) {
      print("sublist $i ${i + MAXIMUM_MESSAGE_SIZE}");
      var upperLimit = (i + MAXIMUM_MESSAGE_SIZE > sizeInBytes)
          ? sizeInBytes
          : (i + MAXIMUM_MESSAGE_SIZE);
      await _imagesDataChannel!
          .send(RTCDataChannelMessage.fromBinary(bytes.sublist(i, upperLimit)));
    }
    await _imagesDataChannel!
        .send(RTCDataChannelMessage.fromBinary(END_OF_FILE_MESSAGE));

    print("sent bytes...");
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
