class Style {
  int id;
  String? name;
  String code;
  String nameCode;
  String? description;

  Style({
    required this.id,
    this.name,
    required this.code,
    required this.nameCode,
    this.description,
  });

  factory Style.fromJson(Map<String, dynamic> json) {
    return Style(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      nameCode: json['name_code'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "name_code": nameCode,
    "description": description,
  };

  @override
  String toString() {
    return 'Style{id: $id, name: $name, code: $code, nameCode: $nameCode, description: $description}';
  }

}