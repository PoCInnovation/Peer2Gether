class User {
  final String name;
  final String message;

  User({
    this.name,
    this.message,
  });
}

final User currentUser = User(
  name: 'PoC',
  message: 'Just le boss enfaite',
);

final User ironMan = User(
  name: 'Tonny Stark',
  message: 'Je te donne mon armure si tu me laisse rentrer',
);
