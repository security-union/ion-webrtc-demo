// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter_ion/flutter_ion.dart';
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
  final Map<String, Participant> _participants = <String, Participant>{};

  Timer? timer;

  Client? client;

  GRPCWebSignal? signal;

  @override
  void initState() {
    this.createClient();
    this.client?.ontrack = _onTrack;
    super.initState();
  }

  void createClient() async {
    this.signal = ion.GRPCWebSignal(widget.addr);
    this.client = await ion.Client.create(
      sid: widget.sid,
      uid: widget.uuid,
      signal: this.signal!,
    );
  }

  @override
  void dispose() {
    this.signal?.close();
    this.client?.close();
    timer?.cancel();
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
                _remotesView(
                  context,
                  _participants.values.map((e) => e.renderer).toList(),
                )
              ],
            )),
      );

  Widget _qrCode(String content) => Container(
        decoration: const BoxDecoration(color: Colors.white),
        alignment: Alignment.center,
        child: QrImage(
          data: content,
          version: QrVersions.auto,
          size: 200.0,
        ),
      );

  Widget _remotesView(BuildContext context, List<RTCVideoRenderer> renderers) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...renderers.map((value) => Expanded(
                child: RTCVideoView(value),
              )),
        ],
      );

  _onTrack(MediaStreamTrack track, ion.RemoteStream remoteStream) async {
    if (track.kind == 'video') {
      print('ontrack: remote stream => ${remoteStream.id}');
      final remoteRenderer = RTCVideoRenderer();
      await remoteRenderer.initialize();
      print(remoteStream.id);
      remoteRenderer.srcObject = remoteStream.stream;
      setState(() {
        _participants[remoteStream.id] = Participant(
          remoteStream.id,
          remoteRenderer,
          remoteStream.stream,
        );
      });
    }
  }
}
