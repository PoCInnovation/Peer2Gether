import 'package:flutter/material.dart';
import 'package:chat_app_p2p/home_screen.dart';
import 'package:chat_app_p2p/RtcConnection/connectionPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ConnectionPage(title: 'WebRTC lets learn together'),
    );
  }
}
