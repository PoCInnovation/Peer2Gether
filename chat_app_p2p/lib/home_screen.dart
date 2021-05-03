import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'P2P',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {},
          color: Colors.white,
         ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {}
              )
        ],
      ),
      body: Container(
        child: Text('Test'),
      ),
    );
  }
}
