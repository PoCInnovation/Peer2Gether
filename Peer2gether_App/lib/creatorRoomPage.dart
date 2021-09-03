import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peer2gether/commonService.dart';
import 'package:peer2gether/homePage.dart';
import 'package:peer2gether/webrtc_viewmodel.dart';

import 'models.dart';

class CreatorRoomPage extends StatefulWidget {
  final String roomName;

  CreatorRoomPage({this.roomName});

  @override
  _CreatorRoomPageState createState() => _CreatorRoomPageState();
}

class _CreatorRoomPageState extends State<CreatorRoomPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  TextEditingController controller = new TextEditingController();
  List<WebRtcViewModel> viewModels = [];
  List<User> users = [];
  Stream collectionStream;
  bool tryToConnect = false;
  int connectionIndex = 0;

  @override
  void dispose() {
    super.dispose();
    CommonService().deleteDocument("rooms", widget.roomName);
  }

  @override
  void initState() {
    super.initState();
    db.collection("rooms").doc(widget.roomName).set({});
    CommonService().getAllUsers("rooms/${widget.roomName}/inWait").then((value) {
      setState(() {
        users = value;
      });
    });
    collectionStream = FirebaseFirestore.instance.collection('rooms/${widget.roomName}/inWait').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: Colors.blue,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext popupContext) {
                  return CupertinoAlertDialog(
                    title: Text("Etes vous sur de vouloir quitter le salon ?"),
                    content: Wrap(
                      children: [
                        Padding(
                            padding: EdgeInsets.only(right: 15),
                            child: ElevatedButton(
                              onPressed: () {
                                viewModels.forEach((element) {
                                  element.closeConnection();
                                });
                                CommonService().deleteDocument("rooms", widget.roomName);
                                Navigator.of(popupContext).pop();
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
                              },
                              child: Text("Fermer le salon"),
                            )),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(popupContext).pop();
                            },
                            child: Text("Annuler"))
                      ],
                    ),
                  );
                },
              );
            },
          ),
          title: Text("${widget.roomName}"),
          backgroundColor: Colors.black87,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: collectionStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Something went wrong'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text("Loading"),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(15),
                    margin: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                        border: Border(
                      bottom: BorderSide(color: Colors.black87, width: 2),
                    )),
                    child: ListView(
                      children: snapshot.data.docs.map(
                        (DocumentSnapshot document) {
                          return ListTile(
                            title: Text(document.id),
                            leading: Icon(Icons.account_circle_rounded),
                            trailing: IconButton(
                              onPressed: () {
                                viewModels.add(new WebRtcViewModel());
                                viewModels[connectionIndex].offerConnection(widget.roomName, document.id);
                                new Timer(const Duration(milliseconds: 400), () {
                                  db.collection("rooms/${widget.roomName}/inWait").doc(document.id).snapshots().listen(
                                    (DocumentSnapshot doc) {
                                      if (!tryToConnect) {
                                        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                                        if (data["sdp"] != null) {
                                          if (doc.get("sdp")["type"] == "answer") {
                                            RTCSessionDescription answer;
                                            try {
                                              answer = RTCSessionDescription(
                                                doc.get("sdp")["sdp"],
                                                doc.get("sdp")["type"],
                                              );
                                            } catch (e) {
                                              print("An error occurred when application tried to get sdp");
                                              tryToConnect = false;
                                              return;
                                            }
                                            viewModels[connectionIndex].acceptAnswer(answer);
                                            tryToConnect = true;
                                            connectionIndex++;
                                          }
                                        }
                                      }
                                    },
                                  );
                                });
                              },
                              icon: Icon(
                                Icons.add,
                                color: Colors.blue,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: 8,
                    itemBuilder: (BuildContext messageContext, index) {
                      return Column(
                        children: [Text("data")],
                      );
                    },
                  ),
                ),
                Container(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Message",
                    ),
                    controller: controller,
                    onSubmitted: (value) {
                      viewModels.forEach((element) {
                        element.sendMessage(value);
                      });
                    },
                  ),
                )
              ],
            );
          },
        ),
      ),
      onWillPop: () {},
    );
  }
}
