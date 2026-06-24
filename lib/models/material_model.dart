class MaterialModel {
  final String id;
  final String name;
  final String unit;
  final double defaultPrice;
  final String category;

  MaterialModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.defaultPrice,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'defaultPrice': defaultPrice,
      'category': category,
    };
  }

  factory MaterialModel.fromMap(Map<dynamic, dynamic> map) {
    return MaterialModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      unit: map['unit']?.toString() ?? '',
      defaultPrice: (map['defaultPrice'] as num?)?.toDouble() ?? 0.0,
      category: map['category']?.toString() ?? '',
    );
  }
}
