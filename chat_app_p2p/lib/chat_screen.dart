import 'package:flutter/material.dart';
import 'package:chat_app_p2p/user_model.dart';

class ChatScreen extends StatefulWidget {
  final User user;

  ChatScreen({this.user});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        brightness: Brightness.dark,
        centerTitle: true,
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(text: widget.user.name),
              TextSpan(text: '\n'),
              TextSpan(
                  text: widget.user.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400))
            ],
          ),
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      child: Container(
                        alignment: Alignment.topLeft,
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        child: Text('gg for the Ultron fight'),
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5
                          ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  child: Text('data'),
                ),
                Container(
                  child: Text('data'),
                ),
              ],
            ),
          ),
          Container(
            child: Text('Send'),
          ),
        ],
      ),
    );
  }
}
