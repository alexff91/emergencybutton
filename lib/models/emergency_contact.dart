import 'dart:convert';

class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relationship;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'relationship': relationship,
      };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        relationship: json['relationship'] as String,
      );

  static String encodeList(List<EmergencyContact> contacts) =>
      jsonEncode(contacts.map((c) => c.toJson()).toList());

  static List<EmergencyContact> decodeList(String jsonString) {
    final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded
        .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  EmergencyContact copyWith({
    String? name,
    String? phone,
    String? relationship,
  }) =>
      EmergencyContact(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        relationship: relationship ?? this.relationship,
      );
}
