import 'package:flutter/material.dart';
import 'package:peer_to_gether_app/RoomsService.dart';
import 'package:peer_to_gether_app/RoomScreen.dart';

class CreateRoom extends StatefulWidget {
  @override
  CreateRoomState createState() => CreateRoomState();
}

class CreateRoomState extends State<CreateRoom> {
  String roomName = "";
  int maxUser = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Creation of a room"),
          centerTitle: true,
        ),
        body: Form(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Name of the room"),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (value) {
                    setState(() {
                      roomName = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                        child: Text(
                      "Max users in the room: ",
                      style: TextStyle(fontSize: 18),
                    )),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 70),
                            child: DropdownButton(
                              hint: Text(
                                '$maxUser',
                                style: TextStyle(color: Colors.blue),
                              ),
                              isExpanded: true,
                              iconSize: 30.0,
                              style: TextStyle(color: Colors.blue),
                              items: [1, 2, 3, 4, 5].map(
                                (val) {
                                  return DropdownMenuItem<int>(
                                    value: val,
                                    child: Text('$val'),
                                  );
                                },
                              ).toList(),
                              onChanged: (val) {
                                setState(
                                  () {
                                    maxUser = val;
                                  },
                                );
                              },
                            )))
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      RoomService.create(roomName, maxUser);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => RoomScreen(
                                    roomName: roomName,
                                  )));
                    },
                    child: Text("Create"),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
