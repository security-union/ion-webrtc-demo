import 'package:flutter/material.dart';
import 'package:ion_webrtc_demo/src/styles/app_theme.dart';
import 'package:ion_webrtc_demo/src/views/home.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: const Home(title: 'Ion WebRTC'),
    );
  }
}
