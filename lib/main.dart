import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:peer_to_gether_app/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat app',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
