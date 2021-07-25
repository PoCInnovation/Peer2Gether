import 'package:flutter_webrtc/flutter_webrtc.dart';

Future<MediaStream> getUserMedia() async {
  final Map<String, dynamic> mediaConstraints = {
    'audio': true,
    'video': {
      'facingMode': 'user',
    },
  };

  MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
  return stream;
}