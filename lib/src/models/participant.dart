import 'package:flutter_webrtc/flutter_webrtc.dart';

class Participant {
  Participant(this.title, this.renderer, this.stream);

  MediaStream? stream;
  String title;
  RTCVideoRenderer renderer;
}
