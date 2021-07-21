import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

Future<String> getUUID() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getString('deviceId') != null) {
    return prefs.getString('deviceId')!;
  } else {
    final String uuid = const Uuid().v4();
    await prefs.setString("deviceId", uuid);
    return uuid;
  }
}
