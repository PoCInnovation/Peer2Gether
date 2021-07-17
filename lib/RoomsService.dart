import 'package:peer_to_gether_app/RoomModel.dart';
import 'package:peer_to_gether_app/commonService.dart';
import 'user_model.dart';

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

    await db.add("rooms", roomName, {"Status": "Open", "NumberOfUser": 1, "MaxUsers": maxUsers})..onError((error, stackTrace) => {result = false});
    return result;
  }

  static Future<List<User>> getAllUsers(String collection) async {
    CommonService db = CommonService();
    List<User> users = [];

    var rooms = await db.db.collection(collection).get();
    var documents = rooms.docs;

    documents.forEach((doc) {
      users += [User(name: doc.id, message: doc.data()["message"])];
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
}
