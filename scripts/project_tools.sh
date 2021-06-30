#!/bin/bash

CMD=$1

function add_permission_label() {
    cd ./scripts
    echo ""
    echo "Add permission labels to iOS."
    echo ""
    python add-line.py -i ../ios/Runner/Info.plist -s '<key>UILaunchStoryboardName</key>' -t '	<key>NSCameraUsageDescription</key>'
    python add-line.py -i ../ios/Runner/Info.plist -s '<key>UILaunchStoryboardName</key>' -t '	<string>$(PRODUCT_NAME) Camera Usage!</string>'
    python add-line.py -i ../ios/Runner/Info.plist -s '<key>UILaunchStoryboardName</key>' -t '	<key>NSMicrophoneUsageDescription</key>'
    python add-line.py -i ../ios/Runner/Info.plist -s '<key>UILaunchStoryboardName</key>' -t '	<string>$(PRODUCT_NAME) Microphone Usage!</string>'
    echo ""
    echo "Add permission labels to AndroidManifest.xml."
    echo ""
    python add-line.py -i ../android/app/src/main/AndroidManifest.xml -s "<application" -t '    <uses-feature android:name="android.hardware.camera" />'
    python add-line.py -i ../android/app/src/main/AndroidManifest.xml -s "<application" -t '    <uses-feature android:name="android.hardware.camera.autofocus" />'
    python add-line.py -i ../android/app/src/main/AndroidManifest.xml -s "<application" -t '    <uses-permission android:name="android.permission.CAMERA" />'
    python add-line.py -i ../android/app/src/main/AndroidManifest.xml -s "<application" -t '    <uses-permission android:name="android.permission.RECORD_AUDIO" />'
    python add-line.py -i ../android/app/src/main/AndroidManifest.xml -s "<application" -t '    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />'
    python add-line.py -i ../android/app/src/main/AndroidManifest.xml -s "<application" -t '    <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />'
    python add-line.py -i ../android/app/src/main/AndroidManifest.xml -s "<application" -t '    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />'
}


if [ "$CMD" == "add_permission" ];
then
    add_permission_label
fi

if [ ! -n "$1" ] ;then
    echo "Usage: ./project_tools.sh 'add_permission'"
fi
