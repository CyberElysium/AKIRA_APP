class MaterialData {
  int id;
  String name;
  String code;
  String nameWithCode;
  String? uomName;
  String? categoryName;
  String? color;
  String? imageUrl;

  MaterialData({
    required this.id,
    required this.name,
    required this.code,
    required this.nameWithCode,
    this.uomName,
    this.categoryName,
    this.color,
    this.imageUrl,
  });

  factory MaterialData.fromJson(Map<String, dynamic> json) {
    return MaterialData(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      nameWithCode: json['code_name'],
      uomName: json['uom_name'],
      categoryName: json['category_name'],
      color: json['color'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "code_name": nameWithCode,
    "uom_name": uomName,
    "category_name": categoryName,
    "color": color,
    "image_url": imageUrl,
  };

  @override
  String toString() {
    return 'MaterialData{id: $id, name: $name, code: $code, nameWithCode: $nameWithCode, uomName: $uomName, categoryName: $categoryName, color: $color, imageUrl: $imageUrl}';
  }

}
