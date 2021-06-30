#!/bin/bash

cd ./scripts
echo ""
echo "Add permission labels to iOS."
echo ""
python3 add-line.py -i ../ios/Runner/Info.plist -s '<key>UILaunchStoryboardName</key>' -t '	<key>NSCameraUsageDescription</key>'
python3 add-line.py -i ../ios/Runner/Info.plist -s '<key>UILaunchStoryboardName</key>' -t '	<string>$(PRODUCT_NAME) Camera Usage!</string>'
python3 add-line.py -i ../ios/Runner/Info.plist -s '<key>UILaunchStoryboardName</key>' -t '	<key>NSMicrophoneUsageDescription</key>'
python3 add-line.py -i ../ios/Runner/Info.plist -s '<key>UILaunchStoryboardName</key>' -t '	<string>$(PRODUCT_NAME) Microphone Usage!</string>'
echo ""
echo "Add permission labels to AndroidManifest.xml."
echo ""
python3 add-line.py -i ../android/app/src/main/AndroidManifest.xml -s "<application" -t '    <uses-feature android:name="android.hardware.camera" />'
python3 add-line.py -i ../android/app/src/main/AndroidManifest.xml -s "<application" -t '    <uses-feature android:name="android.hardware.camera.autofocus" />'
python3 add-line.py -i ../android/app/src/main/AndroidManifest.xml -s "<application" -t '    <uses-permission android:name="android.permission.CAMERA" />'
python3 add-line.py -i ../android/app/src/main/AndroidManifest.xml -s "<application" -t '    <uses-permission android:name="android.permission.RECORD_AUDIO" />'
python3 add-line.py -i ../android/app/src/main/AndroidManifest.xml -s "<application" -t '    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />'
python3 add-line.py -i ../android/app/src/main/AndroidManifest.xml -s "<application" -t '    <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />'
python3 add-line.py -i ../android/app/src/main/AndroidManifest.xml -s "<application" -t '    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />'

