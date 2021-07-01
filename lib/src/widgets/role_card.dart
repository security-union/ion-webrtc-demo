import 'package:flutter/widgets.dart';
import 'package:ion_webrtc_demo/src/styles/text.dart';

Widget roleCard({
  required String title,
  required String description,
  required Widget button,
  required IconData icon,
}) =>
    Expanded(
      child: Container(
        padding: const EdgeInsets.all(30),
        margin: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              description,
              style: subtitle,
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: button,
              ),
            )
          ],
        ),
      ),
    );
