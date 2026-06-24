class UnitPrice {
  final String id;
  final String designation;
  final String category;
  final String unit;
  final double price;
  final String currency;

  UnitPrice({
    required this.id,
    required this.designation,
    required this.category,
    required this.unit,
    required this.price,
    required this.currency,
  });

  UnitPrice copyWith({
    String? id,
    String? designation,
    String? category,
    String? unit,
    double? price,
    String? currency,
  }) {
    return UnitPrice(
      id: id ?? this.id,
      designation: designation ?? this.designation,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      currency: currency ?? this.currency,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'designation': designation,
      'category': category,
      'unit': unit,
      'price': price,
      'currency': currency,
    };
  }

  factory UnitPrice.fromMap(Map<dynamic, dynamic> map) {
    return UnitPrice(
      id: map['id']?.toString() ?? '',
      designation: map['designation']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      unit: map['unit']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency']?.toString() ?? 'FCFA',
    );
  }
}
