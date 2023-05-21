class Warehouse {
   int id;
   String name;
   String code;

  Warehouse({
    required this.id,
    required this.name,
    required this.code,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
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
    return 'Warehouse{id: $id, name: $name, code: $code}';
  }
}
