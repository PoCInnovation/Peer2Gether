class User {
  final int id;
  final String name;

  User({
    this.id,
    this.name,
  });
}

final User currentUser = User(
  id: 0,
  name: "Alexandre",
);

final User ironMan = User(
  id: 1,
  name: "Iron Man",
);