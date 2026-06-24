import 'measurement_item_model.dart';

class Project {
  final String id;
  final String name;
  final String client;
  final String location;
  final DateTime date;
  final String type;
  final String currency;
  final String observations;
  final List<MeasurementItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    this.client = '',
    this.location = '',
    required this.date,
    required this.type,
    required this.currency,
    this.observations = '',
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  Project copyWith({
    String? id,
    String? name,
    String? client,
    String? location,
    DateTime? date,
    String? type,
    String? currency,
    String? observations,
    List<MeasurementItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      client: client ?? this.client,
      location: location ?? this.location,
      date: date ?? this.date,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      observations: observations ?? this.observations,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'client': client,
      'location': location,
      'date': date.toIso8601String(),
      'type': type,
      'currency': currency,
      'observations': observations,
      'items': items.map((item) => item.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Project.fromMap(Map<dynamic, dynamic> map) {
    var rawItems = map['items'] as List? ?? [];
    List<MeasurementItem> itemList = rawItems
        .map((itemMap) => MeasurementItem.fromMap(Map<dynamic, dynamic>.from(itemMap)))
        .toList();

    return Project(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      client: map['client']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      date: map['date'] != null ? DateTime.parse(map['date'].toString()) : DateTime.now(),
      type: map['type']?.toString() ?? 'Autre',
      currency: map['currency']?.toString() ?? 'FCFA',
      observations: map['observations']?.toString() ?? '',
      items: itemList,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'].toString()) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'].toString()) : DateTime.now(),
    );
  }
}
