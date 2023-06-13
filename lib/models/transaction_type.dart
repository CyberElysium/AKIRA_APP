class TransactionType {
  int id;
  String name;

  TransactionType({
    required this.id,
    required this.name,
  });

  factory TransactionType.fromJson(Map<String, dynamic> json) {
    return TransactionType(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };

  @override
  String toString() {
    return 'TransactionType{id: $id, name: $name}';
  }
}