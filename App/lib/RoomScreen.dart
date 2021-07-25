import 'package:flutter/material.dart';
import 'package:peer_to_gether_app/ChatScreen/offer.dart';
import 'package:peer_to_gether_app/RoomsService.dart';
import 'package:peer_to_gether_app/commonService.dart';
import 'package:peer_to_gether_app/user_model.dart';

import 'message_model.dart';
import 'user_model.dart';
import 'package:peer_to_gether_app/RtcConnection/RtcServices.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class RoomScreen extends StatefulWidget {
  final String roomName;

  RoomScreen({this.roomName});

  @override
  RoomScreenState createState() => RoomScreenState();
}

class RoomScreenState extends State<RoomScreen> {
  List<User> user = [];
  RTCPeerConnection _peerConnection;

  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();

  CommonService db = CommonService();

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

    dataChannel.send(RTCDataChannelMessage('Hello!'));
  }

  @override
  void initState() {
    super.initState();
    initRenderers();
    rtcService()
        .initPeerConnection(_onDataChannel, () => {}, () => {}, (stream) => {_remoteRenderer.srcObject = stream})
        .then((data) {
      _peerConnection = data.item1;
      // _localRenderer.srcObject = data.item3;
    });
    RoomService.getAllUsers('rooms/${widget.roomName}/inWait').then((value) => setState(() => {user = value}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.autorenew),
              onPressed: () {
                RoomService.getAllUsers('rooms/${widget.roomName}/inWait')
                    .then((value) => setState(() => {user = value}));
              })
        ],
      ),
      body: ListView.builder(
        itemCount: user.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.person),
            title: Text('${user[index].name}'),
            subtitle: Text('${user[index].message}'),
            trailing: IconButton(
                icon: Icon(Icons.person_add_alt),
                onPressed: () {
                  createOffer(_peerConnection).then((value) =>
                      CommonService().add('rooms/${widget.roomName}/inWait', user[index].name, {'offer': value}));
                }),
          );
        },
      ),
    );
  }
}
