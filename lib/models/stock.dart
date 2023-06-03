class Stock {
  int id;
  String sku;
  String materialName;
  String quantity;
  String materialCode;
  String uom;
  String categoryName;
  String warehouseName;
  String? imageUrl;
  String? rate;
  String? color;
  String? supplierName;
  int materialId;

  Stock({
    required this.id,
    required this.sku,
    required this.materialName,
    required this.quantity,
    required this.materialCode,
    required this.uom,
    required this.categoryName,
    required this.warehouseName,
    this.imageUrl,
    this.rate,
    this.color,
    this.supplierName,
    required this.materialId,
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
  };

  @override
  String toString() {
    return 'Stock{id: $id, sku: $sku, materialName: $materialName, quantity: $quantity, materialCode: $materialCode, uom: $uom, categoryName: $categoryName, warehouseName: $warehouseName, imageUrl: $imageUrl, rate: $rate, color: $color, supplierName: $supplierName, materialId: $materialId}';
  }


}
