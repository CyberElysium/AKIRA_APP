class UOM {
  int id;
  String name;
  String code;

  UOM({
    required this.id,
    required this.name,
    required this.code,
  });

  factory UOM.fromJson(Map<String, dynamic> json) {
    return UOM(
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
    return 'UOM{id: $id, name: $name, code: $code}';
  }
}