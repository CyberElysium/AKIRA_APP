class Category {
  int id;
  String name;
  String code;

  Category({
    required this.id,
    required this.name,
    required this.code,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
  };

  @override
  String toString() {
    return 'Category{id: $id, name: $name, code: $code}';
  }
}