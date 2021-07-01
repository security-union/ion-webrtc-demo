## Ion WebRTC Demo

For now this demo is a Many to Many (on a room) webRTC call implementation with ion.

First, execute the ion SFU server on your computer:

```sh
docker run -p 9090:50051 -p 5000-5200:5000-5200/udp pionwebrtc/ion-sfu:latest-grpc
```

Then, modify the *getUrl* method inside lib/src/views/home.dart
and set the ```ion.GRPCWebSignal('http://192.168.1.46:9090')``` with your local ip so phones can connect to your local sfu server

### Development

Ion lets you create & join sessions on a SFU server to share your video/audio in real time with other users on that session.

You just have to create a Client object specifying the SFU server, the session & your unique identifier.

Then, if you want to start sending video its as easy as just calling ```client.publish(mediaStream)```

More about SFU: https://webrtcglossary.com/sfu

The cool thing about SFU and ion is that you dont need to care about signaling peer to peer but just signaling with the SFU server (which is done automatically by the library).

The server will start sending you the streaming data (video/audio) of the other peers on that session as soon as you connect to it.

Example: 

```dart
final signal = await ion.GRPCWebSignal('<SFU server address>');

client = await ion.Client.create(
  sid: sid, // Session id
  uid: uid, // Send our UUID so the server knows who we are
  signal: _signal, // Signaling object pointing to the SFU server
);

// You are already connected to the server and ready to receive data lol

client.ontrack = (track, ion.RemoteStream remoteStream) async {
  if (track.kind == 'video') {
    // Now we can store the remote stream and create a RTCVideoRenderer with it
  }
};

// Lets publish our video

final localStream = await ion.LocalStream.getUserMedia(
     constraints: ion.Constraints.defaults..simulcast = false,
);

await client.publish(_localStream);
``` 





