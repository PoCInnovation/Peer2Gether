import 'package:peer_to_gether_app/CreateRoom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'RoomModel.dart';

import 'package:peer_to_gether_app/WaitJoinScreen.dart';
import 'package:peer_to_gether_app/RoomsService.dart';

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
  }

  String temp = 'll';
  List<Room> room = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    RoomService.join(room[index].name, 'Tom', "Hey boy");
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => WaitJoinScreen(roomName: room[index].name)));
                  }),
            ));
          },
        ));
  }
}
