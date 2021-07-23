import 'package:flutter/material.dart';
import 'package:peer_to_gether_app/generate.dart';

class ConnectionScreen extends StatelessWidget {
  final String data;

  ConnectionScreen({this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection'),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 100.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
                onPressed: () => {Navigator.push(context, MaterialPageRoute(builder: (_) => GeneratePage(link: data)))},
                child: Text('Generation'))
          ],
        ),
      ),
    );
  }
}
