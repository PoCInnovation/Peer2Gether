import 'package:flutter/material.dart';
import 'package:chat_app_p2p/user_model.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'dart:convert';
import 'package:chat_app_p2p/message_model.dart';
import 'package:tuple/tuple.dart';

import 'message_model.dart';
import 'user_model.dart';

class ChatScreen extends StatefulWidget {
  final User user;

  ChatScreen({this.user});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

Future<Tuple2<RTCPeerConnection, RTCDataChannel>> initPeerConnection(
    Function _onDataChannel,
    Function _onIceCandidate,
    Function _onIceConnectionState,
    Function _onAddStream) async {
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

  pc.onDataChannel = _onDataChannel;
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

    pc.onAddStream = (stream) {
      print('addStream: ' + stream.id);
    };

  return new Tuple2(pc, dataChannel);
}

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

Future<MediaStream> getUserMedia() async {
  final Map<String, dynamic> mediaConstraints = {
    'audio': true,
    'video': {
      'facingMode': 'user',
    },
  };

  MediaStream stream = await navigator.getUserMedia(mediaConstraints);
  return stream;
}

class _ChatScreenState extends State<ChatScreen> {
  bool _offer = false;
  RTCPeerConnection _peerConnection;

  RTCDataChannelInit _dataChannelDict;
  RTCDataChannel _dataChannel;

  final sdpController = TextEditingController();

  @override
  dispose() {
    sdpController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    initPeerConnection(_onDataChannel, () => {}, () => {}, () => {})
        .then((data) {
      _peerConnection = data.item1;
      _dataChannel = data.item2;
    });
    super.initState();
  }

  void _createOffer() async {
    RTCSessionDescription description =
        await _peerConnection.createOffer({'offerToReceiveVideo': 1});
    var session = parse(description.sdp);
    print(json.encode(session));
    _offer = true;

    _peerConnection.setLocalDescription(description);
  }

  void _createAnswer() async {
    RTCSessionDescription description =
        await _peerConnection.createAnswer({'offerToReceiveVideo': 1});

    var session = parse(description.sdp);
    print(json.encode(session));

    _peerConnection.setLocalDescription(description);
  }

  void _setRemoteDescription() async {
    String jsonString = sdpController.text;
    dynamic session = await jsonDecode('$jsonString');

    String sdp = write(session, null);

    RTCSessionDescription description =
        new RTCSessionDescription(sdp, _offer ? 'answer' : 'offer');
    print(description.toMap());

    await _peerConnection.setRemoteDescription(description);
  }

  void _addCandidate() async {
    String jsonString = sdpController.text;
    dynamic session = await jsonDecode('$jsonString');
    print(session['candidate']);
    dynamic candidate = new RTCIceCandidate(
        session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
    await _peerConnection.addCandidate(candidate);
  }

  _onDataChannel(RTCDataChannel dataChannel) {
    dataChannel.onMessage = (message) {
      if (message.type == MessageType.text) {
        print("message.text");
        Message msg = Message(
            text: message.text,
            sender: currentUser,
            time: "now",
            unread: false);
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

  _createPeerConnection() async {
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

    _dataChannel = await pc.createDataChannel('dataChannel', _dataChannelDict);

    pc.onDataChannel = _onDataChannel;

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

    pc.onAddStream = (stream) {
      print('addStream: ' + stream.id);
    };

    return pc;
  }

  _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      },
    };

    MediaStream stream = await navigator.getUserMedia(mediaConstraints);

    return stream;
  }

  Row offerAndAnswerButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
        new RaisedButton(
          onPressed: () async =>
              {(await createOffer(_peerConnection)), _offer = true},
          child: Text('Offer'),
          color: Colors.amber,
        ),
        RaisedButton(
          onPressed: () async => {(await createAnswer(_peerConnection))},
          child: Text('Answer'),
          color: Colors.amber,
        ),
      ]);

  Row sdpCandidateButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
        RaisedButton(
          onPressed: () async => {
            setRemoteDescription(_peerConnection, sdpController.text, _offer)
          },
          child: Text('Set Remote Desc'),
          color: Colors.amber,
        ),
        RaisedButton(
          onPressed: () async =>
              {addCandidate(_peerConnection, sdpController.text)},
          child: Text('Add Candidate'),
          color: Colors.amber,
        )
      ]);

  Padding sdpCandidatesTF() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: sdpController,
          keyboardType: TextInputType.multiline,
          maxLines: 4,
          maxLength: TextField.noMaxLength,
        ),
      );

  _chatBubble(Message message, bool isMe, bool isSameUser) {
    if (isMe) {
      return Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topRight,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.80,
              ),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          !isSameUser
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      message.time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Container(
                  child: null,
                ),
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.80,
              ),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          !isSameUser
              ? Row(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      message.time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                )
              : Container(
                  child: null,
                ),
        ],
      );
    }
  }

  _sendMessageArea() {
    TextEditingController controller = new TextEditingController();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      height: 70,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration.collapsed(
                hintText: 'Send a message...',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              Message msg = Message(
                  text: controller.text,
                  sender: currentUser,
                  time: "now",
                  unread: false);
              _dataChannel.send(RTCDataChannelMessage(msg.text));
              setState(() {
                messages.add(msg);
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int prevUserId;
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        brightness: Brightness.dark,
        centerTitle: true,
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                  text: widget.user.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  )),
              TextSpan(text: '\n'),
              widget.user.isOnline
                  ? TextSpan(
                      text: 'Online',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  : TextSpan(
                      text: 'Offline',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    )
            ],
          ),
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: EdgeInsets.all(20),
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                final Message message = messages[index];
                final bool isMe = message.sender.id == currentUser.id;
                final bool isSameUser = prevUserId == message.sender.id;
                prevUserId = message.sender.id;
                return _chatBubble(message, isMe, isSameUser);
              },
            ),
          ),
          _sendMessageArea(),
          Container(
              child: Column(children: [
            offerAndAnswerButtons(),
            sdpCandidatesTF(),
            sdpCandidateButtons(),
            IconButton(
              icon: const Icon(Icons.volume_up),
              tooltip: 'Increase volume by 10',
              onPressed: () {
                _dataChannel.send(RTCDataChannelMessage(sdpController.text));
              },
            ),
          ]))
        ],
      ),
    );
  }
}
