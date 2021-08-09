import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';

Future<String> createOffer(RTCPeerConnection _peerConnection) async {
  RTCSessionDescription description =
  await _peerConnection.createOffer({'offerToReceiveVideo': 1});
  var session = parse(description.sdp);

  print(json.encode(session));
  _peerConnection.setLocalDescription(description);
  return json.encode(session).toString();
}

Future<String> createAnswer(RTCPeerConnection _peerConnection) async {
  RTCSessionDescription description =
  await _peerConnection.createAnswer({'offerToReceiveVideo': 1});
  var session = parse(description.sdp);

  print(json.encode(session));
  _peerConnection.setLocalDescription(description);
  return json.encode(session).toString();
}

void setRemoteDescription(RTCPeerConnection _peerConnection,
    String _remoteDescription, bool _isOffer) async {
  dynamic session = await jsonDecode('$_remoteDescription');
  String sdp = write(session, null);
  RTCSessionDescription description =
  new RTCSessionDescription(sdp, _isOffer ? 'answer' : 'offer');

  await _peerConnection.setRemoteDescription(description);
}

void addCandidate(RTCPeerConnection _peerConnection, String _candidate) async {
  dynamic session = await jsonDecode('$_candidate');
  dynamic candidate = new RTCIceCandidate(
      session['candidate'], session['sdpMid'], session['sdpMlineIndex']);

  await _peerConnection.addCandidate(candidate);
}