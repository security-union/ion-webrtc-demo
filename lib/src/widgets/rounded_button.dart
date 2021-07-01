import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ion_webrtc_demo/src/styles/colors.dart';
import 'package:ion_webrtc_demo/src/styles/text.dart';

Widget roundedButton({
  required String text,
  required void Function() onPressed,
  Color? color,
}) =>
    ElevatedButton(
      onPressed: onPressed,
      child: Text(text, style: h3),
      style: ElevatedButton.styleFrom(
        onPrimary: Colors.white,
        primary: color ?? AppColors.primaryBlue,
        onSurface: Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 58, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
