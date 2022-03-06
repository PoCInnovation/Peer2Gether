import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mobx/mobx.dart';

part 'webrtc_viewmodel.g.dart';

typedef MessageHandler = Function(String value);

Map<String, dynamic> _connectionConfiguration = {
  'iceServers': [
    {'url': 'stun:stun.l.google.com:19302'},
  ]
};

const _offerAnswerConstraints = {
  'mandatory': {
    'OfferToReceiveAudio': false,
    'OfferToReceiveVideo': true,
  },
  'optional': [],
};

class WebRtcViewModel = _WebRtcViewModelBase with _$WebRtcViewModel;

abstract class _WebRtcViewModelBase with Store {
  late RTCDataChannel _dataChannel;
  late RTCPeerConnection _connection;
  late RTCSessionDescription _sdp;
  late MediaStream remoteStream;
  late MediaStream localStream;
  late String roomName;
  late String userName;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  late MessageHandler _messageHandler;

  @action
  Future<void> offerConnection(
      String _roomName, String _userName, MessageHandler messageHandler) async {
    _connection = await _createPeerConnection();
    await _createDataChannel();
    RTCSessionDescription offer =
        await _connection.createOffer(_offerAnswerConstraints);
    await _connection.setLocalDescription(offer);
    roomName = _roomName;
    userName = _userName;
    _messageHandler = messageHandler;
    _sdpChanged();
  }

  @action
  Future<void> answerConnection(RTCSessionDescription offer, String _roomName,
      String _userName, MessageHandler messageHandler) async {
    _connection = await _createPeerConnection();
    await _connection.setRemoteDescription(offer);
    final answer = await _connection.createAnswer(_offerAnswerConstraints);
    await _connection.setLocalDescription(answer);
    roomName = _roomName;
    userName = _userName;
    _messageHandler = messageHandler;
    _sdpChanged();
  }

  @action
  Future<void> acceptAnswer(RTCSessionDescription answer) async {
    await _connection.setRemoteDescription(answer);
  }

  @action
  Future<void> closeConnection() async {
    await _connection.close();
    await _dataChannel.close();
  }

  @action
  Future<void> sendMessage(String message) async {
    await _dataChannel.send(RTCDataChannelMessage(message));
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final con = await createPeerConnection(_connectionConfiguration);
    con.onIceCandidate = (candidate) async {
      _sdpChanged();
    };
    con.onDataChannel = (channel) {
      _addDataChannel(channel);
    };
    con.onConnectionState = (state) {
      print("State = $state");
    };
    return con;
  }

  void _sdpChanged() async {
    _sdp = (await _connection.getLocalDescription())!;
    await db
        .collection("rooms/$roomName/inWait")
        .doc(userName)
        .set({"sdp": _sdp.toMap()});
  }

  Future<void> _createDataChannel() async {
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit();
    RTCDataChannel channel =
        await _connection.createDataChannel("textchat-chan", dataChannelDict);
    _addDataChannel(channel);
  }

  void _addDataChannel(RTCDataChannel channel) {
    _dataChannel = channel;
    _dataChannel.onMessage = (data) {
      _messageHandler(data.text);
    };
    _dataChannel.onDataChannelState = (state) {
      print("STATE = $state");
    };
  }
}
