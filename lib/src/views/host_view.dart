// ignore_for_file: avoid_print
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ion/flutter_ion.dart' as ion;
import 'package:ion_webrtc_demo/src/models/participant.dart';
import 'package:ion_webrtc_demo/src/utils.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';

class HostView extends StatefulWidget {
  const HostView({
    Key? key,
    required this.uuid,
    required this.signal,
  }) : super(key: key);

  final ion.Signal signal;
  final String uuid;

  @override
  State<HostView> createState() => _HostViewState();
}

class _HostViewState extends State<HostView> {
  final Map<String, Participant> _participants = <String, Participant>{};
  ion.Client? _client;
  final String _sid = const Uuid().v4();

  @override
  void initState() {
    _createClient(_sid, widget.uuid, widget.signal, onTrack: _onTrack)
        .then((client) => setState(() => _client = client))
        .catchError((err) => alertDialog(context, err.toString()));
    super.initState();
  }

  @override
  void dispose() {
    _closeCall();
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
                _qrCode(_sid),
                _remotesView(
                  context,
                  [..._participants.values.map((e) => e.renderer)],
                )
              ],
            )),
      );

  Widget _qrCode(String content) => Center(
        child: BarcodeWidget(
          data: content,
          barcode: Barcode.qrCode(),
          color: Colors.white,
          width: 200,
          height: 200,
        ),
      );

  Widget _remotesView(BuildContext context, List<RTCVideoRenderer> renderers) =>
      GridView.count(
        crossAxisCount: 2,
        children: [...renderers.map((renderer) => RTCVideoView(renderer))],
      );

  Future<ion.Client> _createClient(
    String sid,
    String uuid,
    ion.Signal signal, {
    required Function(MediaStreamTrack, ion.RemoteStream) onTrack,
  }) async {
    final client = await ion.Client.create(sid: sid, uid: uuid, signal: signal);
    client.ontrack = onTrack;
    return client;
  }

  _onTrack(MediaStreamTrack track, ion.RemoteStream remoteStream) async {
    if (track.kind == 'video') {
      print('ontrack: remote stream => ${remoteStream.id}');
      final remoteRenderer = RTCVideoRenderer();
      await remoteRenderer.initialize();
      setState(() {
        remoteRenderer.srcObject = remoteStream.stream;
        _participants[remoteStream.id] = Participant(
          remoteStream.id,
          remoteRenderer,
          remoteStream.stream,
        );
      });
    }
  }

  void _closeCall() {
    _client?.close();
    _client = null;
  }
}
