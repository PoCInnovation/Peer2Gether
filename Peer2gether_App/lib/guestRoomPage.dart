import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peer2gether/webrtc_viewmodel.dart';

class GuestRoomPage extends StatefulWidget {
  final roomName;
  final userName;

  GuestRoomPage({this.roomName, this.userName});

  @override
  _GuestRoomPageState createState() => _GuestRoomPageState();
}

class _GuestRoomPageState extends State<GuestRoomPage> {
  final WebRtcViewModel viewModel = WebRtcViewModel();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final TextEditingController controller = new TextEditingController();
  int changeCounter = 0;

  void getSdp() async {
    await db.collection("rooms/${widget.roomName}/inWait").doc(widget.userName).get().then((document) {
      RTCSessionDescription offer;
      try {
        offer = RTCSessionDescription(
          document.get("sdp")["sdp"],
          document.get("sdp")["type"],
        );
      } catch (e) {
        print("An error occurred when application tried to get sdp");
        changeCounter = 1;
        return;
      }
      viewModel.answerConnection(offer, widget.roomName, widget.userName);
    });
  }

  Future<void> joinRoom() async {
    await db.collection("rooms/${widget.roomName}/inWait").doc(widget.userName).set({});
    await db.collection("rooms/${widget.roomName}/inWait").doc(widget.userName).snapshots().listen(
      (DocumentSnapshot document) async {
        if (changeCounter == 1) {
          print("GET OFFER");
          Future.delayed(Duration(seconds: 1));
          await getSdp();
        }
        changeCounter++;
      },
    );
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
            child: Container(
              child: Text("Messages here comming soon"),
            ),
          ),
          TextField(
            controller: controller,
            decoration: InputDecoration(border: OutlineInputBorder()),
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
