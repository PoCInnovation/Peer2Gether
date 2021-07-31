import 'package:flutter/material.dart';
import 'package:peer_to_gether_app/RoomScreen.dart';
import 'dart:async';
import 'dart:convert';

import 'message_model.dart';
import 'user_model.dart';

import 'package:peer_to_gether_app/commonService.dart';
import 'package:peer_to_gether_app/RtcConnection/RtcServices.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WaitJoinScreen extends StatefulWidget {
  final String roomName;

  WaitJoinScreen({this.roomName});

  @override
  WaitJoinScreenState createState() => WaitJoinScreenState();
}

class WaitJoinScreenState extends State<WaitJoinScreen> {
  Timer _timer;
  int _counter = 60;
  CommonService db = CommonService();
  String message = "Waiting owner approbation\n";
  String offer = "";
  String answer = "";
  RTCPeerConnection _peerConnection;

  bool done = false;

  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();

  @override
  dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  _onDataChannel(RTCDataChannel dataChannel) {
    dataChannel.onMessage = (message) {
      if (message.type == MessageType.text) {
        print("message.text");
        Message msg = Message(text: message.text, sender: currentUser, time: "now", unread: false);
        setState(() {
          messages.add(msg);
        });
      } else {
        // do something with message.binary
      }
    };
    // or alternatively:
    dataChannel.messageStream.listen((message) {
      if (message.type == MessageType.text) {
        print(message.text);
      } else {
        // do something with message.binary
      }
    });

    dataChannel.send(RTCDataChannelMessage('Hello !'));
  }

  void startTimer() async {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      print(_counter);
      if (_counter > 0) {
        try {
          db.get('rooms/${widget.roomName}/inWait', 'Tom', 'offer').then((value) async {
            if (value.length != 0)
              setState(() {
                offer = value;
                message = "Joining";
              });
            _timer.cancel();
            await rtcService().setRemoteDescription(_peerConnection, offer, false);
            await rtcService().createAnswer(_peerConnection).then((value) => {answer = value});
            Navigator.push(context, MaterialPageRoute(builder: (_) => RoomScreen(roomName: widget.roomName)));
          });
        } catch (e) {
          print('Error in joining: $e');
        }
        _counter--;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initRenderers();
    rtcService().initPeerConnection(_onDataChannel, (e) {
      if (e.candidate != null && !done) {
        db.add('rooms/${widget.roomName}/inWait', 'Tom', {
          "answer": answer,
          "iceCandidate": json.encode({
            'candidate': e.candidate.toString(),
            'sdpMid': e.sdpMid.toString(),
            'sdpMlineIndex': e.sdpMlineIndex,
          }).toString()
        });
        done = true;
      }
    }, () => {}, (stream) => {_remoteRenderer.srcObject = stream}).then((data) {
      _peerConnection = data.item1;
      // _localRenderer.srcObject = data.item3;
    });
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Joining..."),
            centerTitle: true,
          ),
          body: Container(
            padding: EdgeInsets.only(top: 150.0),
            child: Column(
              children: <Widget>[
                Center(child: Text(message, style: TextStyle(fontSize: 20))),
                Container(padding: EdgeInsets.only(top: 25.0), child: CircularProgressIndicator())
              ],
            ),
          ),
        ));
  }
}
