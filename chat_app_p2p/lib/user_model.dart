class User {
  final int id;
  final String name;
  final String image;
  final bool isOnline;

  User({
    this.id,
    this.name,
    this.image,
    this.isOnline,
  });
}

final User currentUser = User(
  id: 0,
  name: "Alexandre",
  image: "assets/poc.jpg  ",
  isOnline: true,
);

final User ironMan = User(
  id: 1,
  name: "Iron Man",
  image: "assets/iron-man.png",
  isOnline: false,
);

final User PoC = User(
  id: 1,
  name: "PoC",
  image: "assets/poc.jpg",
  isOnline: true,
);