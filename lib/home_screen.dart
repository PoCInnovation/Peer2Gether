import 'package:peer_to_gether_app/Connection.dart';
import 'package:peer_to_gether_app/RoomScreen.dart';
import 'package:peer_to_gether_app/lecture.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peer_to_gether_app/message_model.dart';
import 'package:peer_to_gether_app/ChatScreen/chat_screen.dart';

import 'package:peer_to_gether_app/user_model.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'dart:convert';
import 'package:tuple/tuple.dart';
import 'message_model.dart';
import 'user_model.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:peer_to_gether_app/commonService.dart';
import 'package:peer_to_gether_app/PhoneUtils.dart';
import 'package:peer_to_gether_app/RegisterScreen.dart';
import 'package:peer_to_gether_app/RoomsService.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

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

class _HomeScreenState extends State<HomeScreen> {
  RTCPeerConnection _peerConnection;
  String userId = "";

  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();

  FirebaseAuth auth = FirebaseAuth.instance;
  CommonService db = CommonService();

  String my_words = "";

  @override
  dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initRenderers();
    initPeerConnection(_onDataChannel, () => {}, () => {}, (stream) => {_remoteRenderer.srcObject = stream})
        .then((data) {
      _peerConnection = data.item1;
      // _localRenderer.srcObject = data.item3;
    });
    FileUtils.readFromFile("user.txt").then((value) {
      setState(() {
        userId = value;
      });
    });
    print("Loged as '$userId' !--------------------------------");
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

  String temp = 'll';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Rooms"),
          centerTitle: true,
        ),
        body: Container(
            child: Column(
          children: <Widget>[
            SizedBox(
              height: 25,
            ),
            Text("Join a room"),
            TextField(
              autocorrect: false,
              onSubmitted: (value) {
                RoomService.join(value, "Tome").then((value) => {print(value)});
              },
            ),
            SizedBox(
              height: 100,
            ),
            Text("Create a room"),
            TextField(onSubmitted: (value) {
              RoomService.create(value);
              Navigator.push(context, MaterialPageRoute(builder: (_) => RoomScreen(roomName: value)));
            }),
            SizedBox(height: 100),
            Text("Fetch users waiting to enter the room"),
            TextField(
              onSubmitted: (value) async {
                await RoomService.fetchWaitingUsers(value);
              },
            )
          ],
        )));
    /*
    return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'Messages',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () async => {
                          (temp = await createOffer(_peerConnection)),
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ConnectionScreen(data: temp))),
                        }),
                IconButton(
                  icon: Icon(Icons.account_tree_outlined),
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => Lecture())),
                )
              ],
            ),
            body: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (BuildContext context, int index) {
                final Message chat = chats[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ChatScreen(
                                user: chat.sender,
                              ))),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(2),
                          decoration: chat.sender.isOnline
                              ? BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 2,
                                      color: Theme.of(context).primaryColor),
                                  boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5)
                                    ])
                              : BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5)
                                    ]),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundImage: AssetImage(chat.sender.imageUrl),
                          ),
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width * 0.65,
                            padding: EdgeInsets.only(left: 20),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          chat.sender.name,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        chat.unread
                                            ? Container(
                                                margin: const EdgeInsets.only(
                                                    left: 5),
                                                width: 7,
                                                height: 7,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                              )
                                            : Container(child: null)
                                      ],
                                    ),
                                    Text(
                                      chat.time,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black54,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  child: Text(chat.text),
                                )
                              ],
                            ))
                      ],
                    ),
                  ),
                );
              },
            ),
          );
          */
  }
}
