class Stock {
  int id;
  String sku;
  String materialName;
  String quantity;
  String? materialCode;
  String? uom;
  String? categoryName;
  String? warehouseName;
  String? imageUrl;
  String? rate;
  String? color;
  String? supplierName;
  int materialId;
  String? nameWithCode;

  Stock({
    required this.id,
    required this.sku,
    required this.materialName,
    required this.quantity,
    this.materialCode,
    this.uom,
    this.categoryName,
    this.warehouseName,
    this.imageUrl,
    this.rate,
    this.color,
    this.supplierName,
    required this.materialId,
    this.nameWithCode,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'],
      sku: json['sku'],
      materialName: json['material_name'],
      quantity: json['quantity'],
      materialCode: json['material_code'],
      uom: json['uom_name'],
      categoryName: json['category_name'],
      warehouseName: json['warehouse_name'],
      imageUrl: json['image_url'],
      rate: json['rate'],
      color: json['color'],
      supplierName: json['supplier_name'],
      materialId: json['material_id'],
      nameWithCode: json['name_with_code'],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "sku": sku,
        "materialName": materialName,
        "quantity": quantity,
        "materialCode": materialCode,
        "uom": uom,
        "categoryName": categoryName,
        "warehouseName": warehouseName,
        "imageUrl": imageUrl,
        "rate": rate,
        "color": color,
        "supplierName": supplierName,
        "materialId": materialId,
        "nameWithCode": nameWithCode,
      };

  @override
  String toString() {
    return 'Stock{id: $id, sku: $sku, materialName: $materialName, quantity: $quantity, materialCode: $materialCode, uom: $uom, categoryName: $categoryName, warehouseName: $warehouseName, imageUrl: $imageUrl, rate: $rate, color: $color, supplierName: $supplierName, materialId: $materialId, nameWithCode: $nameWithCode}';
  }
}
