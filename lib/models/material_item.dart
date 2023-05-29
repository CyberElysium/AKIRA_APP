class MaterialItem {
  int id;
  String name;
  String code;
  String name_with_code;
  String uom_name;
  String category_name;
  String quantity;
  String sku;

  MaterialItem({
    required this.id,
    required this.name,
    required this.code,
    required this.name_with_code,
    required this.uom_name,
    required this.category_name,
    required this.quantity,
    required this.sku,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'],
      name: json['material_name'],
      code: json['material_code'],
      name_with_code: json['name_with_code'],
      uom_name: json['uom_name'],
      category_name: json['category_name'],
      quantity: json['quantity'],
      sku: json['sku'],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "name_with_code": name_with_code,
    "uom_name": uom_name,
    "category_name": category_name,
    "quantity": quantity,
    "sku": sku,
  };

  @override
  String toString() {
    return 'MaterialItem{id: $id, name: $name, code: $code, name_with_code: $name_with_code, uom_name: $uom_name, category_name: $category_name, quantity: $quantity, sku: $sku}';
  }
}