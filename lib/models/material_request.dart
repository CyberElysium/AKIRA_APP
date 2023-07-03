class MaterialRequest {
  int id;
  String code;
  String? quantity;
  String? styleCode;
  String? materialNameWithQty;
  int? materialId;

  MaterialRequest({
    required this.id,
    required this.code,
    this.quantity,
    this.styleCode,
    this.materialNameWithQty,
    this.materialId,
  });

  factory MaterialRequest.fromJson(Map<String, dynamic> json) {
    return MaterialRequest(
      id: json['id'],
      code: json['code'],
      quantity: json['quantity'],
      styleCode: json['style_code'],
      materialNameWithQty: json['material_name_with_qty'],
      materialId: json['material_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "quantity": quantity,
        "style_code": styleCode,
        "material_name_with_qty": materialNameWithQty,
        "material_id": materialId,
      };

  @override
  String toString() {
    return 'MaterialRequest{id: $id, code: $code, quantity: $quantity, styleCode: $styleCode, materialNameWithQty: $materialNameWithQty, materialId: $materialId}';
  }
}
