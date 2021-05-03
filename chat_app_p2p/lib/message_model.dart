import 'package:chat_app_p2p/user_model.dart';

class Message {
  final User sender;
  final String time;
  final String text;
  final bool unread;

  Message({
    this.sender,
    this.time,
    this.text,
    this.unread,
  });
}

List<Message> chat = [
  Message(
    sender: ironMan,
    time: '5h00',
    text: 'Jarvis is broken :(',
    unread: false,
  ),
];