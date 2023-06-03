class Supplier {
  int id;
  String name;
  String code;
  String? address;
  String? contact;
  String? email;
  String? company;

  Supplier({
    required this.id,
    required this.name,
    required this.code,
    this.address,
    this.contact,
    this.email,
    this.company,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      address: json['address'],
      contact: json['contact'],
      email: json['email'],
      company: json['company'],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "address": address,
    "contact": contact,
    "email": email,
    "company": company,
  };

  @override
  String toString() {
    return 'Supplier{id: $id, name: $name, code: $code, address: $address, contact: $contact, email: $email, company: $company}';
  }
}