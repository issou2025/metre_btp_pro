class ClientModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String companyName;

  ClientModel({
    required this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.companyName = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'companyName': companyName,
    };
  }

  factory ClientModel.fromMap(Map<dynamic, dynamic> map) {
    return ClientModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      companyName: map['companyName']?.toString() ?? '',
    );
  }
}
