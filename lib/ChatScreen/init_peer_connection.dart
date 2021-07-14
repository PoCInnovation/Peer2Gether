import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:tuple/tuple.dart';

Future<Tuple3<RTCPeerConnection, RTCDataChannel, MediaStream>>
initPeerConnection(Function _onDataChannel, Function _onIceCandidate,
    Function _onIceConnectionState, Function _onAddStream) async {
  RTCDataChannelInit _dataChannelDict;
  RTCDataChannel dataChannel;

  Map<String, dynamic> configuration = {
    "iceServers": [
      {"url": "stun:stun.l.google.com:19302"},
    ]
  };
  final Map<String, dynamic> offerSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": true,
    },
    "optional": [],
  };
  RTCPeerConnection pc =
  await createPeerConnection(configuration, offerSdpConstraints);

  _dataChannelDict = RTCDataChannelInit();
  _dataChannelDict.id = 1;
  _dataChannelDict.ordered = true;
  _dataChannelDict.maxRetransmitTime = -1;
  _dataChannelDict.maxRetransmits = -1;
  _dataChannelDict.protocol = 'sctp';
  _dataChannelDict.negotiated = false;

  dataChannel = await pc.createDataChannel('dataChannel', _dataChannelDict);

  MediaStream stream;// = await getUserMedia();

  pc.onDataChannel = _onDataChannel;
  // pc.addStream(stream);

  pc.onIceCandidate = (e) {
    if (e.candidate != null) {
      print(json.encode({
        'candidate': e.candidate.toString(),
        'sdpMid': e.sdpMid.toString(),
        'sdpMlineIndex': e.sdpMlineIndex,
      }));
    }
  };

  pc.onIceConnectionState = (e) {
    print(e);
  };

  pc.onAddStream = _onAddStream;

  return new Tuple3(pc, dataChannel, stream);
}