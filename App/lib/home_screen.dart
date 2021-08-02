import 'package:peer_to_gether_app/CreateRoom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'RoomModel.dart';

import 'package:peer_to_gether_app/WaitJoinScreen.dart';
import 'package:peer_to_gether_app/RoomsService.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userId = "";

  @override
  void initState() {
    super.initState();
    RoomService.getAllRooms('rooms').then((value) {
      setState(() {
        room = value;
      });
    });
    getStringFromSharedPref().then((value) {
      setState(() {
        userName = value;
      });
    });
  }

  Future<String> getStringFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    final result = prefs.getString('userName');

    if (result == null) {
      return "";
    }
    return result;
  }

  Future<void> setStringToSharedPref(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', value);
  }

  String temp = 'll';
  List<Room> room = [];

  String userName = "";

  TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (userName.length == 0) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Register"),
          centerTitle: true,
        ),
        body: Wrap(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.fromLTRB(20, 25, 0, 0),
                child: Text(
                  "Name",
                  style: TextStyle(fontSize: 18),
                )),
            Padding(
                padding: EdgeInsets.fromLTRB(10, 25, 10, 25),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: "Write your pseudo here", border: OutlineInputBorder()),
                )),
            Center(
                child: ElevatedButton(
              child: Text("Confirm"),
              onPressed: () {
                setState(() {
                  userName = controller.text;
                });
                setStringToSharedPref(controller.text);
              },
            ))
          ],
        ),
      );
    } else {
      return RefreshIndicator(
          child: Scaffold(
              appBar: AppBar(
                title: Text("Rooms"),
                centerTitle: true,
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.autorenew),
                      onPressed: () {
                        RoomService.getAllRooms('rooms').then((value) {
                          setState(() {
                            room = value;
                          });
                        });
                      }),
                  IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => CreateRoom()));
                      }),
                ],
              ),
              body: ListView.builder(
                itemCount: room.length,
                itemBuilder: (context, index) {
                  return Card(
                      child: ListTile(
                    leading: Icon(Icons.add_to_home_screen, size: 40),
                    title: Text(
                      room[index].name,
                      style: TextStyle(fontSize: 25),
                    ),
                    subtitle: Text(
                      '${room[index].status} ${room[index].numberOfUser}/${room[index].maxUser}',
                      style: TextStyle(fontSize: 15),
                    ),
                    trailing: IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: () {
                          RoomService.join(
                              room[index].name,
                              userName,
                              "I "
                              "want To join !");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => WaitJoinScreen(
                                        roomName: room[index].name,
                                        userName: userName,
                                      )));
                        }),
                  ));
                },
              )),
          onRefresh: () => RoomService.getAllRooms('rooms').then((value) {
                setState(() {
                  room = value;
                });
              }));
    }
  }
}
