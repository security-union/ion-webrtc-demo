// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_ion/flutter_ion.dart' as ion;
import 'package:ion_webrtc_demo/src/styles/colors.dart';
import 'package:ion_webrtc_demo/src/views/host_view.dart';
import 'package:ion_webrtc_demo/src/views/qr_scanner.dart';
import 'package:ion_webrtc_demo/src/widgets/role_card.dart';
import 'package:ion_webrtc_demo/src/widgets/rounded_button.dart';
import 'package:uuid/uuid.dart';

class RoleView extends StatefulWidget {
  const RoleView({
    Key? key,
    required this.uuid,
    required this.addr,
  }) : super(key: key);

  final String addr;
  final String uuid;

  @override
  State<RoleView> createState() => _RoleViewState();
}

class _RoleViewState extends State<RoleView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose an option'),
      ),
      body: Column(
        children: <Widget>[
          roleCard(
            title: 'Host',
            description: 'Start as a host and receive video from cameras',
            icon: Icons.speaker_phone_rounded,
            button: roundedButton(
              text: 'Host',
              color: AppColors.primaryBlue,
              onPressed: () async {
                final sid = const Uuid().v4();

                _navigateToHost(sid, widget.addr, widget.uuid);
              },
            ),
          ),
          roleCard(
            title: 'Camera',
            description: 'Start as a camera and share your video',
            icon: Icons.camera_alt_rounded,
            button: roundedButton(
              text: 'Camera',
              color: AppColors.primaryRed,
              onPressed: () => _navigateToQRScanner(widget.uuid, widget.addr),
            ),
          )
        ],
      ),
    );
  }

  void _navigateToQRScanner(String uuid, String addr) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return QRScannerView(uuid: uuid, addr: addr);
        },
      ),
    );
  }

  void _navigateToHost(String sid, String addr, String uuid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return HostView(uuid: uuid, addr: addr, sid: sid);
        },
      ),
    );
  }
}
