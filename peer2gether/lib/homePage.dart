import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peer2gether/guestRoomPage.dart';
import 'package:peer2gether/models.dart';

import 'commonService.dart';
import 'createRoomPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Room> rooms = [];

  @override
  void initState() {
    super.initState();
    CommonService().getAllDocuments("rooms").then((value) {
      setState(() {
        rooms = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black87,
          title: const Text("Peer2Gether"),
          centerTitle: false,
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateRoomPage()));
                },
                child: const Text("Créer un salon"))
          ],
        ),
        body: ListView.separated(
          separatorBuilder: (BuildContext context, int index) => const Divider(
            color: Colors.black87,
          ),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                rooms[index].name,
                style: const TextStyle(fontSize: 25),
              ),
              subtitle: Text(
                rooms[index].music,
                style: const TextStyle(fontSize: 15),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.arrow_forward,
                  color: Colors.blue,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext popupContext) {
                      return CupertinoAlertDialog(
                        title: const Text("Choisissez un pseudo"),
                        content: CupertinoTextField(
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              Navigator.of(popupContext).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => GuestRoomPage(
                                    roomName: rooms[index].name,
                                    userName: value,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
      onRefresh: () => CommonService().getAllDocuments("rooms").then(
        (value) {
          setState(
            () {
              rooms = value;
            },
          );
        },
      ),
    );
  }
}
