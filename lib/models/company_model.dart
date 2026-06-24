class CompanyInfo {
  final String name;
  final String phone;
  final String email;
  final String address;
  final String nif;
  final String? logoPath;

  CompanyInfo({
    this.name = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.nif = '',
    this.logoPath,
  });

  CompanyInfo copyWith({
    String? name,
    String? phone,
    String? email,
    String? address,
    String? nif,
    String? logoPath,
  }) {
    return CompanyInfo(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      nif: nif ?? this.nif,
      logoPath: logoPath ?? this.logoPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'nif': nif,
      'logoPath': logoPath,
    };
  }

  factory CompanyInfo.fromMap(Map<dynamic, dynamic> map) {
    return CompanyInfo(
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      nif: map['nif']?.toString() ?? '',
      logoPath: map['logoPath']?.toString(),
    );
  }
}
