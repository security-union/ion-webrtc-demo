import 'package:flutter_ion/flutter_ion.dart' as ion;
import 'package:flutter_webrtc/flutter_webrtc.dart';

Future<RTCDataChannel> createDataChannel(
  ion.Client client, {
  required String binaryType,
  required int id,
  required String channel,
}) async {
  final channelInit = RTCDataChannelInit()
    ..binaryType = binaryType
    ..id = id;
  final dataChannel = await client.createDataChannel(channel, channelInit);
  return dataChannel;
}
