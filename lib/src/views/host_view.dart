// ignore_for_file: avoid_print
import 'dart:typed_data';
import 'package:ion_webrtc_demo/src/constants.dart';
import 'package:ion_webrtc_demo/src/data_channels.dart';
import 'package:ion_webrtc_demo/src/views/host_camera_view.dart';
import 'package:flutter/foundation.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ion/flutter_ion.dart' as ion;
import 'package:ion_webrtc_demo/src/models/participant.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class HostView extends StatefulWidget {
  const HostView(
      {Key? key, required this.uuid, required this.sid, required this.addr})
      : super(key: key);

  final String uuid;
  final String sid;
  final String addr;

  @override
  State<HostView> createState() => _HostViewState();
}

class _HostViewState extends State<HostView> {
  List<Participant> plist = <Participant>[];
  ion.Client? _client;
  ion.Signal? _signal;
  late RTCDataChannel _localDataChannel;
  late RTCDataChannel _imagesDataChannel;
  WriteBuffer? _imageBuffer;

  @override
  void initState() {
    _startSession();
    super.initState();
  }

  @override
  void dispose() {
    _signal?.close();
    _client?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('You are the Host'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'QRCode'),
              Tab(text: 'Cameras'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _qrCode(widget.sid),
            _remotesView(context),
          ],
        ),
      ));

  Widget _qrCode(String content) => Container(
        decoration: const BoxDecoration(color: Colors.white),
        alignment: Alignment.center,
        child: QrImage(
          data: content,
          version: QrVersions.auto,
          size: 200.0,
        ),
      );

  Widget _remotesView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          _camerasGrid(context),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: _actionButtons(context),
          ),
        ],
      ),
    );
  }

  Widget _camerasGrid(BuildContext context) => GridView.builder(
        shrinkWrap: true,
        itemCount: plist.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 5.0,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return SizedBox(
            height: 400,
            child: _getItemView(
              plist[index],
            ),
          );
        },
      );

  Widget _actionButtons(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: FloatingActionButton(
              heroTag: null,
              onPressed: () {
                sendTakePictureCommand();
              },
              child: const Icon(Icons.camera_rounded),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: FloatingActionButton(
              heroTag: null,
              onPressed: () => print('Video'),
              child: const Icon(Icons.play_circle_rounded),
            ),
          ),
        ],
      );

  Widget _getItemView(Participant item) {
    print("items: " + item.toString());
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        RTCVideoView(
          item.renderer,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 5.0),
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton(
            child: const Icon(Icons.api_rounded),
            onPressed: () {
              _navigateToHostCameraView(
                widget.uuid,
                widget.sid,
                item,
                _client!,
              );
            },
          ),
        )
      ],
    );
  }

  Future<void> showPicture(ByteData bytes) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Image.memory(
          bytes.buffer.asUint8List(),
          height: 720,
          width: 1280,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: Navigator.of(context, rootNavigator: true).pop,
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void _startSession() async {
    _signal = ion.JsonRPCSignal(widget.addr);
    _client = await ion.Client.create(
      sid: widget.sid,
      uid: widget.uuid,
      signal: _signal!,
    );

    _localDataChannel = await createDataChannel(
      _client!,
      binaryType: 'text',
      id: 41324,
      channel: Constants.commandsChannelLabel,
    );

    _imagesDataChannel = await createDataChannel(
      _client!,
      binaryType: 'binary',
      id: 213,
      channel: Constants.imageBinaryChannel,
    );

    _client!.ontrack = clientOnTrack;
    _localDataChannel.onDataChannelState = onTextDataChannelState;
    _imagesDataChannel.onDataChannelState = onImageDataChannelState;
  }

  clientOnTrack(track, ion.RemoteStream remoteStream) async {
    if (track.kind == 'video') {
      print('remote stream id:  ${remoteStream.id}');
      print('ontrack: remote stream: ${remoteStream.stream}');
      var renderer = RTCVideoRenderer();
      await renderer.initialize();
      renderer.srcObject = remoteStream.stream;
      setState(() {
        plist.add(Participant('RemoteStream', renderer, remoteStream.stream));
      });
    }
  }

  onTextDataChannelState(RTCDataChannelState state) async {
    print("commands socket state changed $state");
    if (state == RTCDataChannelState.RTCDataChannelOpen) {
      print("commands socket state changed $state");
      _localDataChannel.messageStream.forEach(
        (msg) async => print("got msg ${msg.text}"),
      );
    }
  }

  onImageDataChannelState(RTCDataChannelState state) async {
    print("images socket state changed $state");
    if (state == RTCDataChannelState.RTCDataChannelOpen) {
      _imagesDataChannel.messageStream.forEach(
        (msg) async {
          print("image onMessage ${msg.binary.length}");
          if (msg.binary.length != Constants.endOfFileMessage.length) {
            print("adding chunk");
            _imageBuffer?.putUint8List(msg.binary);
          } else {
            print("got eol");
            final image = _imageBuffer?.done();
            _imageBuffer = WriteBuffer();
            print("sending image to ui ${image?.lengthInBytes}");
            if (image != null) await showPicture(image);
          }
        },
      );
    }
  }

  sendTakePictureCommand() async {
    await _localDataChannel
        .send(RTCDataChannelMessage("""{ "command": "takePicture" }"""));
  }

  void _navigateToHostCameraView(
    String uuid,
    String sid,
    Participant participant,
    ion.Client client,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return HostCameraView(
            uuid: uuid,
            participant: participant,
            sessionId: sid,
            client: client,
          );
        },
      ),
    );
  }
}
