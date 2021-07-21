import 'dart:typed_data';

class Constants {
  static final endOfFileMessage = Uint8List.fromList('EOF'.codeUnits);
  static const commandsChannelLabel = "Commands";
  static const imageBinaryChannel = "IMAGE_BINARY_CHANNEL";
  static const maximumMessageSize = 65000;
}
