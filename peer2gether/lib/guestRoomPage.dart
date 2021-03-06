import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peer2gether/commonService.dart';
import 'package:peer2gether/webrtc_viewmodel.dart';

class GuestRoomPage extends StatefulWidget {
  final roomName;
  final userName;

  const GuestRoomPage({Key? key, this.roomName, this.userName})
      : super(key: key);

  @override
  _GuestRoomPageState createState() => _GuestRoomPageState();
}

class _GuestRoomPageState extends State<GuestRoomPage> {
  final WebRtcViewModel viewModel = WebRtcViewModel();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final TextEditingController controller = TextEditingController();
  int changeCounter = 0;
  List<String> messages = [];

  Future<void> connectNewUser() async {
    RTCSessionDescription offer;

    DocumentReference doc =
        db.collection("rooms/${widget.roomName}/inWait").doc(widget.userName);

    var sdp = (await doc.get()).get("sdp");
    try {
      offer = RTCSessionDescription(
        sdp["sdp"],
        sdp["type"],
      );
    } catch (e) {
      print("An error occurred when application tried to get sdp");
      return;
    }

    viewModel.answerConnection(
        offer, widget.roomName, widget.userName, messageHandler);
  }

  Future<void> joinRoom() async {
    await db
        .collection("rooms/${widget.roomName}/inWait")
        .doc(widget.userName)
        .set({});
    db
        .collection("rooms/${widget.roomName}/inWait")
        .doc(widget.userName)
        .snapshots()
        .listen(
      (DocumentSnapshot document) {
        if (changeCounter == 1) {
          sleep(const Duration(seconds: 3));
          connectNewUser();
          changeCounter++;
          return;
        }
        changeCounter++;
      },
    );
  }

  void messageHandler(String message) {
    setState(() {
      messages.add(message);
    });
  }

  @override
  void initState() {
    super.initState();

    joinRoom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (BuildContext messageContext, messagesIndex) {
                return Column(
                  children: [
                    Text(
                      messages[messagesIndex],
                    ),
                  ],
                );
              },
            ),
          ),
          TextField(
            controller: controller,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            onSubmitted: (value) {
              viewModel.sendMessage(value);
              controller.clear();
            },
            onEditingComplete: () {},
          ),
        ],
      ),
    );
  }
}
