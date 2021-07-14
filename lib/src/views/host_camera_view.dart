// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_ion/flutter_ion.dart' as ion;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:ion_webrtc_demo/src/models/participant.dart';

class HostCameraView extends StatefulWidget {
  const HostCameraView(
      {Key? key,
      required this.uuid,
      required this.sessionId,
      required this.participant,
      required this.client})
      : super(key: key);

  final String uuid;
  final Participant participant;
  final String sessionId;
  final ion.Client client;

  @override
  State<HostCameraView> createState() => _HostCameraViewState();
}

class _HostCameraViewState extends State<HostCameraView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            child: RTCVideoView(
              widget.participant.renderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
            ),
          ),
          // Flash button
          Positioned(
            top: 0,
            left: 0,
            child: FloatingActionButton(
              onPressed: () => print('Flash!'),
              heroTag: null,
              child: const Icon(Icons.flash_on),
            ),
          ),
          // Toggle camera button
          Positioned(
            top: 0,
            right: 0,
            child: FloatingActionButton(
              onPressed: () => print('Toggle camera!'),
              heroTag: null,
              child: const Icon(Icons.toggle_on),
            ),
          ),
          // Photo & Video buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              children: [
                FloatingActionButton(
                  onPressed: () => print('Photo!'),
                  heroTag: null,
                  child: const Icon(Icons.photo),
                ),
                const SizedBox(width: 5),
                FloatingActionButton(
                  onPressed: () => print('Video!'),
                  heroTag: null,
                  child: const Icon(Icons.play_circle),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
