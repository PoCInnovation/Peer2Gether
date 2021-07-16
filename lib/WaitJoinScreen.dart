import 'package:flutter/material.dart';
import 'package:peer_to_gether_app/RoomsService.dart';
import 'dart:async';

import 'package:peer_to_gether_app/commonService.dart';

class WaitJoinScreen extends StatefulWidget {
  final String roomName;

  WaitJoinScreen({this.roomName});

  @override
  WaitJoinScreenState createState() => WaitJoinScreenState();
}

class WaitJoinScreenState extends State<WaitJoinScreen> {
  Timer _timer;
  int _counter = 60;
  CommonService db = CommonService();
  String message = "Waiting owner approbation\n";
  String offer = "";

  void startTimer() async {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      print(_counter);
      if (_counter > 0) {
        try {
          db.get('rooms/${widget.roomName}/inWait', 'Tom', 'offer').catchError((error) {
            print('Error: $error');
          }).then((value) {
            if (value.length != 0)
              setState(() {
                offer = value;
                message = "Joining";
              });
            _timer.cancel();
          });
        } catch (e) {
          print('Error in joining: $e');
        }
        _counter--;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text("Joining..."),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.only(top: 150.0),
        child: Column(
          children: <Widget>[
            Center(child: Text(message, style: TextStyle(fontSize: 20))),
            Container(padding: EdgeInsets.only(top: 25.0), child: CircularProgressIndicator())
          ],
        ),
      ),
    ));
  }
}
