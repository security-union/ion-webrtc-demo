## Ion WebRTC Demo

For now this demo is a Many to Many (on a room) webRTC call implementation with ion.

First, execute the ion SFU server on your computer:

```sh
docker run -p 9090:50051 -p 5000-5200:5000-5200/udp pionwebrtc/ion-sfu:latest-grpc
```

Then, modify the *getUrl* method inside lib/src/views/home.dart
and set the ```ion.GRPCWebSignal('http://192.168.1.46:9090')``` with your local ip so phones can connect to your local sfu server