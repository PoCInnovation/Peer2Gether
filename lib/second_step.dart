import 'package:peer_to_gether_app/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/rendering.dart';

class GeneratePageNd extends StatefulWidget {
  final String link;

  GeneratePageNd({this.link});
  @override
  State<StatefulWidget> createState() => GeneratePageNdState();
}

class GeneratePageNdState extends State<GeneratePageNd> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Generator'),
        actions: <Widget>[],
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            QrImage(
              //place where the QR Image will be shown
              data: widget.link,
            ),
            SizedBox(
              height: 40.0,
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
              ),
              child: Text('Home'),
              style: TextButton.styleFrom(
                primary: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  final qrdataFeed = TextEditingController();
}
