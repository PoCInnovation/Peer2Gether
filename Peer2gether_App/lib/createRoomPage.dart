import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peer2gether/commonService.dart';
import 'package:peer2gether/creatorRoomPage.dart';
import 'package:peer2gether/webrtc_viewmodel.dart';

class CreateRoomPage extends StatefulWidget {
  @override
  _CreateRoomPageState createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final viewModel = new WebRtcViewModel();
  TextEditingController controller = new TextEditingController();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  String roomName;

  Future<RTCSessionDescription> getSdp() async {
    var sdp;
    await db.collection("rooms").doc(roomName).get().then((value) {
      sdp = value.get("sdp");
    });
    print(sdp);
    RTCSessionDescription offer;
    try {
      offer = RTCSessionDescription(
        sdp["sdp"],
        sdp["type"],
      );
    } catch (e) {
      print("An error occurred when application tried to get sdp");
    }
    return offer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        leading: BackButton(
          color: Colors.blue,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 18),
            height: 100,
            child: Text(
              "Création de salon",
              style: TextStyle(fontSize: 30),
            ),
          ),
          Text(
            "Nom du salon",
          ),
          Wrap(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 25, top: 5),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          ElevatedButton(
              onPressed: () {
                if (controller.text.isEmpty) {
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatorRoomPage(
                      roomName: controller.text,
                    ),
                  ),
                );
              },
              child: Text("Créer le salon"))
        ],
      ),
    );
  }
}
