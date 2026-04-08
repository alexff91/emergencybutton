import 'package:flutter_test/flutter_test.dart';
import 'package:emergencybutton/models/emergency_contact.dart';
import 'package:emergencybutton/models/medical_info.dart';
import 'package:emergencybutton/services/location_service.dart';

void main() {
  group('EmergencyContact', () {
    test('serializes and deserializes correctly', () {
      final contact = EmergencyContact(
        id: '1',
        name: 'John Doe',
        phone: '+1234567890',
        relationship: 'Spouse',
      );
      final json = contact.toJson();
      final restored = EmergencyContact.fromJson(json);
      expect(restored.id, '1');
      expect(restored.name, 'John Doe');
      expect(restored.phone, '+1234567890');
      expect(restored.relationship, 'Spouse');
    });

    test('encodes and decodes list correctly', () {
      final contacts = [
        EmergencyContact(
            id: '1', name: 'Alice', phone: '111', relationship: 'Friend'),
        EmergencyContact(
            id: '2', name: 'Bob', phone: '222', relationship: 'Parent'),
      ];
      final encoded = EmergencyContact.encodeList(contacts);
      final decoded = EmergencyContact.decodeList(encoded);
      expect(decoded.length, 2);
      expect(decoded[0].name, 'Alice');
      expect(decoded[1].name, 'Bob');
    });

    test('copyWith creates modified copy', () {
      final contact = EmergencyContact(
        id: '1',
        name: 'John',
        phone: '111',
        relationship: 'Spouse',
      );
      final modified = contact.copyWith(name: 'Jane');
      expect(modified.name, 'Jane');
      expect(modified.phone, '111');
      expect(modified.id, '1');
    });
  });

  group('MedicalInfo', () {
    test('empty check works', () {
      expect(MedicalInfo().isEmpty, true);
      expect(MedicalInfo(bloodType: 'A+').isEmpty, false);
    });

    test('serializes and deserializes correctly', () {
      final info = MedicalInfo(
        bloodType: 'O-',
        allergies: 'Penicillin',
        medications: 'Metformin',
        conditions: 'Diabetes',
        emergencyNotes: 'Pacemaker',
      );
      final encoded = info.encode();
      final restored = MedicalInfo.decode(encoded);
      expect(restored.bloodType, 'O-');
      expect(restored.allergies, 'Penicillin');
      expect(restored.medications, 'Metformin');
      expect(restored.conditions, 'Diabetes');
      expect(restored.emergencyNotes, 'Pacemaker');
    });

    test('copyWith preserves unmodified fields', () {
      final info = MedicalInfo(
        bloodType: 'AB+',
        allergies: 'Latex',
      );
      final modified = info.copyWith(bloodType: 'A-');
      expect(modified.bloodType, 'A-');
      expect(modified.allergies, 'Latex');
    });
  });

  group('LocationService', () {
    test('Plus Code generation produces valid format', () {
      // Google HQ coordinates
      final code = LocationService.toPlusCode(37.4220, -122.0841);
      expect(code.contains('+'), true);
      expect(code.length, 11); // 10 chars + separator
    });

    test('Plus Code handles edge coordinates', () {
      // North pole
      final northPole = LocationService.toPlusCode(90.0, 0.0);
      expect(northPole.contains('+'), true);

      // South pole
      final southPole = LocationService.toPlusCode(-90.0, 0.0);
      expect(southPole.contains('+'), true);

      // Date line
      final dateLine = LocationService.toPlusCode(0.0, 179.99999);
      expect(dateLine.contains('+'), true);
    });

    test('accuracy formatting returns correct categories', () {
      expect(LocationService.formatAccuracy(2.0), 'Excellent (<5m)');
      expect(LocationService.formatAccuracy(10.0), 'Good (<15m)');
      expect(LocationService.formatAccuracy(30.0), 'Fair (<50m)');
      expect(LocationService.formatAccuracy(100.0), 'Poor (100m)');
    });

    test('accuracy color values are correct', () {
      expect(LocationService.accuracyColorValue(2.0), 0xFF4CAF50); // green
      expect(LocationService.accuracyColorValue(10.0), 0xFF8BC34A); // light green
      expect(LocationService.accuracyColorValue(30.0), 0xFFFF9800); // orange
      expect(LocationService.accuracyColorValue(100.0), 0xFFF44336); // red
    });
  });
}
