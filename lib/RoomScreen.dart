import 'package:flutter/material.dart';
import 'package:peer_to_gether_app/RoomsService.dart';
import 'package:peer_to_gether_app/commonService.dart';
import 'package:peer_to_gether_app/user_model.dart';

class RoomScreen extends StatefulWidget {
  final String roomName;

  RoomScreen({this.roomName});

  @override
  RoomScreenState createState() => RoomScreenState();
}

class RoomScreenState extends State<RoomScreen> {
  List<User> user = [];

  @override
  void initState() {
    super.initState();

    RoomService.fetchWaitingUsers(widget.roomName).then((value) => setState(() => {user = value}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.autorenew),
              onPressed: () {
                RoomService.fetchWaitingUsers(widget.roomName).then((value) => setState(() => {user = value}));
              })
        ],
      ),
      body: ListView.builder(
        itemCount: user.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.person),
            title: Text('${user[index].name}'),
            subtitle: Text('${user[index].message}'),
            trailing: IconButton(
                icon: Icon(Icons.person_add_alt),
                onPressed: () {
                  CommonService().add('rooms/${widget.roomName}/inWait', user[index].name, {'offer': "void"});
                }),
          );
        },
      ),
    );
  }
}