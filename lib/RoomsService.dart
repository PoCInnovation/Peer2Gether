import 'package:peer_to_gether_app/commonService.dart';
import 'user_model.dart';

class RoomService {
  static Future<bool> join(String roomName, String userName) async {
    CommonService db = CommonService();
    String status = "";

    try {
      await db.get("rooms", roomName, "status").then((value) => {
            status = value,
          });
    } catch (e) {
      print('Error in joining: $e');
    }
    if (status != "open") {
      return false;
    }
    await db.add("rooms/$roomName/inWait", userName, {"message": "Hey !"});
    return true;
  }

  static Future<bool> create(String roomName) async {
    CommonService db = CommonService();
    bool result = true;

    await db.add("rooms", roomName, {"status": "open"}).onError((error, stackTrace) => {result = false});
    return result;
  }

  static Future<List<User>> fetchWaitingUsers(String room) async {
    CommonService db = CommonService();
    List<User> users = [];

    var rooms = await db.db.collection("rooms").doc(room).collection("inWait").get();
    var documents = rooms.docs;

    documents.forEach((doc) {
      users += [User(name: doc.id, message: doc.data()["message"])];
    });
    print(users);

    return users;
  }
}
