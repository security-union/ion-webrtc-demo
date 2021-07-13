// ignore_for_file: avoid_print
import 'package:ion_webrtc_demo/src/styles/colors.dart';
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
        bottomNavigationBar: _bottomView(),
      ));

  Widget _bottomView() => Container(
        padding: const EdgeInsets.all(0.0),
        color: AppColors.darkDefaultColor,
        height: 100,
        child: Column(
          children: <Widget>[
            Center(
              child: IconButton(
                icon: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 60.0,
                ),
                iconSize: 80,
                splashColor: Colors.blue,
                onPressed: () {
                  print('"sdafasdf');
                },
              ),
            ),
          ],
        ),
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

  Widget _remotesView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: plist.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 5.0,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          return _getItemView(plist[index]);
        },
      ),
    );
  }

  Widget _getItemView(Participant item) {
    print("items: " + item.toString());
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${item.title}:\n${item.stream!.id}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
          Expanded(
            child: RTCVideoView(item.renderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain),
          ),
        ],
      ),
    );
  }

  void _startSession() async {
    _signal = ion.GRPCWebSignal(widget.addr);
    print("serverurl " + widget.addr);
    // create new client
    _client = await ion.Client.create(
        sid: widget.sid, uid: widget.uuid, signal: _signal!);

    // peer ontrack
    _client?.ontrack = (track, ion.RemoteStream remoteStream) async {
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
    };
  }
}
