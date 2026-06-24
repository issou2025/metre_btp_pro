class MeasurementItem {
  final String id;
  final String projectId;
  final String category;
  final String designation;
  final String unit;
  final double quantity;
  final double unitPrice;
  final double amount;
  final String formulaUsed;
  final String notes;

  MeasurementItem({
    required this.id,
    required this.projectId,
    required this.category,
    required this.designation,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
    this.formulaUsed = '',
    this.notes = '',
  });

  MeasurementItem copyWith({
    String? id,
    String? projectId,
    String? category,
    String? designation,
    String? unit,
    double? quantity,
    double? unitPrice,
    double? amount,
    String? formulaUsed,
    String? notes,
  }) {
    return MeasurementItem(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      category: category ?? this.category,
      designation: designation ?? this.designation,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      amount: amount ?? this.amount,
      formulaUsed: formulaUsed ?? this.formulaUsed,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'category': category,
      'designation': designation,
      'unit': unit,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'amount': amount,
      'formulaUsed': formulaUsed,
      'notes': notes,
    };
  }

  factory MeasurementItem.fromMap(Map<dynamic, dynamic> map) {
    return MeasurementItem(
      id: map['id']?.toString() ?? '',
      projectId: map['projectId']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      designation: map['designation']?.toString() ?? '',
      unit: map['unit']?.toString() ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      formulaUsed: map['formulaUsed']?.toString() ?? '',
      notes: map['notes']?.toString() ?? '',
    );
  }
}
