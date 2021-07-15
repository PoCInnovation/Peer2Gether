import 'package:peer_to_gether_app/commonService.dart';

class RoomService {
  static Future<bool> join(String roomName, String userName) async {
    CommonService db = CommonService();
    String statu = "";

    await db.get("rooms", roomName, "statu").then((value) => {
          statu = value,
        });
    if (statu != "open") {
      return false;
    }
    await db.add("rooms/$roomName/inWait", userName, {"offer": "myOffer"});
    return true;
  }

  static Future<bool> create(String roomName) async {
    CommonService db = CommonService();
    bool result = true;

    await db.add("rooms", roomName, {"statu": "open"}).onError(
        (error, stackTrace) => {result = false});
    return result;
  }

  static Future<List<String>> fetchWaitingUsers(String room) async {
    CommonService db = CommonService();
    List<String> array = [];

    var rooms = await db.db.collection("rooms").doc(room).collection("inWait").get();
    var documents = rooms.docs;

    documents.forEach((doc) { array += [doc.id]; });
    print(array);

    return array;
  }
}
