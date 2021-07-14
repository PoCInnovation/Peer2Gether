import 'package:peer_to_gether_app/scan.dart';
import 'package:flutter/material.dart';

class Lecture extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan first'),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 100.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => ScanPage())),
                child: Text('Scan the second'))
          ],
        ),
      ),
    );
  }
}
