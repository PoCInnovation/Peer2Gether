import 'package:peer_to_gether_app/RoomModel.dart';
import 'package:peer_to_gether_app/commonService.dart';
import 'user_model.dart';
import 'package:peer_to_gether_app/ChatScreen/offer.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class RoomService {
  static Future<bool> join(String roomName, String userName, String message) async {
    CommonService db = CommonService();
    String status = "";

    try {
      await db.get("rooms", roomName, "Status").then((value) => {
            status = value,
          });
    } catch (e) {
      print('Error in joining: $e');
    }
    if (status != "Open") {
      return false;
    }
    await db.add("rooms/$roomName/inWait", userName, {"message": message});
    return true;
  }

  static Future<bool> create(String roomName, int maxUsers) async {
    CommonService db = CommonService();
    bool result = true;

    await db.add("rooms", roomName, {"Status": "Open", "NumberOfUser": 1, "MaxUsers": maxUsers}).onError(
        (error, stackTrace) => {result = false});
    return result;
  }

  static Future<List<User>> getAllUsers(String collection) async {
    CommonService db = CommonService();
    List<User> users = [];

    var rooms = await db.db.collection(collection).get();
    var documents = rooms.docs;

    documents.forEach((doc) {
      users += [
        User(
            name: doc.id,
            message: doc.data()["message"],
            answer: doc.data()["answer"],
            iceCandidate: doc.data()["iceCandidate"])
      ];
    });

    return users;
  }

  static Future<List<Room>> getAllRooms(String collection) async {
    CommonService db = CommonService();
    List<Room> users = [];

    var rooms = await db.db.collection(collection).get();
    var documents = rooms.docs;

    documents.forEach((doc) {
      users += [
        Room(
            name: doc.id,
            status: doc.data()["Status"],
            numberOfUser: doc.data()["NumberOfUser"],
            maxUser: doc.data()["MaxUsers"])
      ];
    });

    return users;
  }

  static Future connectUser(String roomName, RTCPeerConnection _peerConnection, User user) async {
    await createOffer(_peerConnection)
        .then((value) => CommonService().add('rooms/${roomName}/inWait', user.name, {'offer': value}));

    String answer = "";
    String iceCandidate = "";

    for (int i = 0; (answer.length == 0 || iceCandidate.length == 0) && i < 3; i++) {
      answer = await CommonService().get("rooms/$roomName/inWait", user.name, "answer");
      iceCandidate = await CommonService().get("rooms/$roomName/inWait", user.name, "iceCandidate");
    }
    if (answer.length != 0 && iceCandidate.length != 0) {
      CommonService().deleteDocument("rooms/$roomName/inWait", user.name);
    }
    setRemoteDescription(_peerConnection, answer, true);
    addCandidate(_peerConnection, user.iceCandidate);
  }
}
