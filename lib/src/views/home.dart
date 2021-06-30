// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_ion/flutter_ion.dart' as ion;
import 'package:ion_webrtc_demo/src/models/Participant.dart';
import 'package:uuid/uuid.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Map of session participants
  final Map<String, Participant> _plist = {};
  // WebRTC Native video renderers
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  // ion SDK objects to perform the signaling & connection through the ionSfu server
  ion.Client? _client;
  ion.LocalStream? _localStream;
  // Our device Unique identifier
  final String _uuid = const Uuid().v4();

  ///
  /// STATE METHODS & WIDGETS
  ///
  @override
  void initState() {
    super.initState();
    // Initialize the native WebRTC video renderers
    _initRenderers().then((value) => _initSfu("Test room", _uuid));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: RTCVideoView(_localRenderer)),
            ..._plist.values.map((value) => Expanded(
                  child: RTCVideoView(value.renderer),
                )),
          ],
        ),
      ),
      floatingActionButton: _floatingButton(),
    );
  }

  Widget _floatingButton() {
    return FloatingActionButton(
      onPressed: _startSharingCamera,
      child: const Icon(Icons.ondemand_video),
    );
  }

  ///
  /// APP LOGIC METHODS
  ///

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
  }

  // Execute the signaling with the SFU server
  // and set behaviour for when receive remote non-data streams (webRTC streams can be 'video' or 'data')
  _initSfu(String sid, String uid) async {
    final _signal = await _getUrl();
    _client = await ion.Client.create(
      sid: sid, // Session id
      uid: uid, // Send our UUID so the server knows who we are
      signal: _signal, // Signaling object pointing to the SFU server
    );
    _client?.ontrack = (track, ion.RemoteStream remoteStream) async {
      if (track.kind == 'video') {
        print('ontrack: remote stream => ${remoteStream.id}');
        final remoteRenderer = RTCVideoRenderer();
        await remoteRenderer.initialize();
        setState(() {
          remoteRenderer.srcObject = remoteStream.stream;
          _plist[remoteStream.id] = Participant(
            remoteStream.id,
            remoteRenderer,
            remoteStream.stream,
          );
        });
      }
    };
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

  // Get the GRPC signaling object pointing to the SFU server
  _getUrl() {
    if (kIsWeb) {
      return ion.GRPCWebSignal('http://localhost:9090');
    } else {
      return ion.GRPCWebSignal('http://192.168.1.46:9090');
    }
  }
}
