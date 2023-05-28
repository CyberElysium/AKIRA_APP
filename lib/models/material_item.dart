class MaterialItem {
  int id;
  String name;
  String quantity;

  MaterialItem({
    required this.id,
    required this.name,
    required this.quantity,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'],
      name: json['name_with_code'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "quantity": quantity,
  };

  @override
  String toString() {
    return 'Material{id: $id, name: $name, quantity: $quantity}';
  }
}