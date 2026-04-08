import 'dart:convert';

class MedicalInfo {
  final String bloodType;
  final String allergies;
  final String medications;
  final String conditions;
  final String emergencyNotes;

  MedicalInfo({
    this.bloodType = '',
    this.allergies = '',
    this.medications = '',
    this.conditions = '',
    this.emergencyNotes = '',
  });

  bool get isEmpty =>
      bloodType.isEmpty &&
      allergies.isEmpty &&
      medications.isEmpty &&
      conditions.isEmpty &&
      emergencyNotes.isEmpty;

  Map<String, dynamic> toJson() => {
        'bloodType': bloodType,
        'allergies': allergies,
        'medications': medications,
        'conditions': conditions,
        'emergencyNotes': emergencyNotes,
      };

  factory MedicalInfo.fromJson(Map<String, dynamic> json) => MedicalInfo(
        bloodType: json['bloodType'] as String? ?? '',
        allergies: json['allergies'] as String? ?? '',
        medications: json['medications'] as String? ?? '',
        conditions: json['conditions'] as String? ?? '',
        emergencyNotes: json['emergencyNotes'] as String? ?? '',
      );

  String encode() => jsonEncode(toJson());

  static MedicalInfo decode(String jsonString) =>
      MedicalInfo.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  MedicalInfo copyWith({
    String? bloodType,
    String? allergies,
    String? medications,
    String? conditions,
    String? emergencyNotes,
  }) =>
      MedicalInfo(
        bloodType: bloodType ?? this.bloodType,
        allergies: allergies ?? this.allergies,
        medications: medications ?? this.medications,
        conditions: conditions ?? this.conditions,
        emergencyNotes: emergencyNotes ?? this.emergencyNotes,
      );
}
