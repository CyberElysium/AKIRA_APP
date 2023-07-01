class GoodIssue {
   int id;
    String code;
    String qty;
    String sku;
    String? materialCode;
    String? warehouseName;


    GoodIssue({
      required this.id,
      required this.code,
      required this.qty,
      required this.sku,
      this.materialCode,
      this.warehouseName,
    });

    factory GoodIssue.fromJson(Map<String, dynamic> json) {
      return GoodIssue(
        id: json['id'],
        code: json['code'],
        qty: json['qty'],
        sku: json['sku'],
        materialCode: json['material_code'],
        warehouseName: json['warehouse_name'],
      );
    }

    Map<String, dynamic> toJson() => {
      "id": id,
      "code": code,
      "qty": qty,
      "sku": sku,
      "material_code": materialCode,
      "warehouse_name": warehouseName,
    };

    @override
    String toString() {
      return 'GoodIssue{id: $id, code: $code, qty: $qty, sku: $sku}, material_code: $materialCode, warehouse_name: $warehouseName';
    }

}