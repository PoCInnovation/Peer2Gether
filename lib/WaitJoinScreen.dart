import 'package:flutter/material.dart';
import 'dart:async';

class WaitJoinScreen extends StatefulWidget {
  @override
  WaitJoinScreenState createState() => WaitJoinScreenState();
}

class WaitJoinScreenState extends State<WaitJoinScreen> {
  Timer _timer;
  int _counter = 10;

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      print(_counter);
      if (_counter > 0) {
        _counter--;
      }
      else {
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
            Center(child: Text("Waiting owner approbation\n", style: TextStyle(fontSize: 20))),
            Container(padding: EdgeInsets.only(top: 25.0), child: CircularProgressIndicator())
          ],
        ),
      ),
    ));
  }
}
