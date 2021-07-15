import 'package:flutter/material.dart';
import 'package:ion_webrtc_demo/src/styles/colors.dart';

final appTheme = ThemeData(
  iconTheme: const IconThemeData(color: Colors.white),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryBlue,
    foregroundColor: Colors.white,
  ),
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryBlue,
);
