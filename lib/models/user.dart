class User {
  int userId;
  String name;
  String email;

  User({
    required this.userId,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['id'],
      name: json['name'] ?? "",
      email: json['email'] ?? "",
    );
  }

}
