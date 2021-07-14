class User {
  final int id;
  final String name;
  final String imageUrl;
  final bool isOnline;

  User({
    this.id,
    this.name,
    this.imageUrl,
    this.isOnline,
  });
}

final User currentUser = User(
  id: 0,
  name: 'PoC',
  imageUrl: 'assets/poc.jpg',
  isOnline: true,
);

final User ironMan = User(
  id: 0,
  name: 'PoC',
  imageUrl: 'assets/poc.jpg',
  isOnline: true,
);
