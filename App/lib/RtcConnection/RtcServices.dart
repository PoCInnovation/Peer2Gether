import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'dart:convert';
import 'package:tuple/tuple.dart';

class rtcService {
  Future<Tuple3<RTCPeerConnection, RTCDataChannel, MediaStream>> initPeerConnection(
      Function _onDataChannel, Function _onIceCandidate, Function _onIceConnectionState, Function _onAddStream) async {
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
    RTCPeerConnection pc = await createPeerConnection(configuration, offerSdpConstraints);

    _dataChannelDict = RTCDataChannelInit();
    _dataChannelDict.id = 1;
    _dataChannelDict.ordered = true;
    _dataChannelDict.maxRetransmitTime = -1;
    _dataChannelDict.maxRetransmits = -1;
    _dataChannelDict.protocol = 'sctp';
    _dataChannelDict.negotiated = false;

    dataChannel = await pc.createDataChannel('dataChannel', _dataChannelDict);

    MediaStream stream; // = await getUserMedia();

    pc.onDataChannel = _onDataChannel;
    // pc.addStream(stream);
    if (_onIceCandidate != null)
      pc.onIceCandidate = _onIceCandidate;

    pc.onIceConnectionState = (e) {
      print(e);
    };

    pc.onAddStream = _onAddStream;

    return new Tuple3(pc, dataChannel, stream);
  }

  Future<String> createOffer(RTCPeerConnection _peerConnection) async {
    RTCSessionDescription description = await _peerConnection.createOffer({'offerToReceiveVideo': 1});
    var session = parse(description.sdp);

    print(json.encode(session));
    _peerConnection.setLocalDescription(description);
    return json.encode(session).toString();
  }

  Future<String> createAnswer(RTCPeerConnection _peerConnection) async {
    RTCSessionDescription description = await _peerConnection.createAnswer({'offerToReceiveVideo': 1});
    var session = parse(description.sdp);

    print(json.encode(session));
    _peerConnection.setLocalDescription(description);
    return json.encode(session).toString();
  }

  void setRemoteDescription(RTCPeerConnection _peerConnection, String _remoteDescription, bool _isOffer) async {
    dynamic session = await jsonDecode('$_remoteDescription');
    String sdp = write(session, null);
    RTCSessionDescription description = new RTCSessionDescription(sdp, _isOffer ? 'answer' : 'offer');

    await _peerConnection.setRemoteDescription(description);
  }

  void addCandidate(RTCPeerConnection _peerConnection, String _candidate) async {
    dynamic session = await jsonDecode('$_candidate');
    dynamic candidate = new RTCIceCandidate(session['candidate'], session['sdpMid'], session['sdpMlineIndex']);

    await _peerConnection.addCandidate(candidate);
  }

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
}