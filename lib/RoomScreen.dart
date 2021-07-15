import 'package:flutter/material.dart';
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
                print('reload');
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
                  print('Add');
                }),
          );
        },
      ),
    );
  }
}
