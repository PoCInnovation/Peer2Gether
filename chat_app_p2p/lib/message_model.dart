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

List<Message> chats = [
  Message(
    sender: ironMan,
    time: '5h00',
    text: 'Jarvis is broken :(',
    unread: false,
  ),
  Message(
    sender: PoC,
    time: '10h00',
    text: 'Proof of community',
    unread: true,
  ),
];
