import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'models.dart';

class CommonService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<String> get(String collection, String document, String field) async {
    String content = "";
    DocumentReference doc = db.collection(collection).doc(document);

    content = (await doc.get()).get(field);

    return content.replaceAll('\\n', '\n');
  }

  Future<void> add(String collection, String document, final field) async {
    await db.collection(collection).doc(document).set(field);
  }

  Future deleteDocument(String collection, String document) async {
    await db.collection(collection).doc(document).delete();
  }

  Future<List<Room>> getAllDocuments(String collection) async {
    CommonService db = CommonService();
    List<Room> tmpRooms = [];

    var dbRooms = await db.db.collection(collection).get();
    var documents = dbRooms.docs;

    documents.forEach((doc) {
      tmpRooms += [
        Room(
          name: doc.id,
          music: doc.data()["music"] != null ? doc.data()["music"] : "Unknown",
        )
      ];
    });
    return tmpRooms;
  }

  Future<List<User>> getAllUsers(String collection) async {
    CommonService db = CommonService();
    List<User> users = [];

    var rooms = await db.db.collection(collection).get();
    var documents = rooms.docs;

    documents.forEach((doc) {
      users += [
        User(
          name: doc.id,
          message: doc.data()["message"],
        )
      ];
    });

    return users;
  }

  Future<RTCSessionDescription> getSdp(String roomName, String userName) async {
    var sdp;
    await db.collection("rooms/$roomName/inWait").doc(userName).get().then((value) {
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
}
