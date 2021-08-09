class User {
  final String name;
  final String message;
  final String answer;
  final String iceCandidate;

  User({
    this.name,
    this.message,
    this.answer,
    this.iceCandidate
  });

// @override
// String toString() {
//   return "{name: \"" + name + "\", message: \"" + message + "\"}";
// }
}

final User currentUser = User(
  name: 'PoC',
  message: 'Juste les boss enfaite',
);

final User ironMan = User(
  name: 'Tonny Stark',
  message: 'Je te donne mon armure si tu me laisse entrer',
);
