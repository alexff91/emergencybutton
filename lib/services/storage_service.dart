import 'package:shared_preferences/shared_preferences.dart';
import '../models/emergency_contact.dart';
import '../models/medical_info.dart';

/// Handles all local persistence for emergency data.
/// Ensures contacts and medical info are available offline.
class StorageService {
  static const _contactsKey = 'emergency_contacts';
  static const _medicalInfoKey = 'medical_info';
  static const _countdownDurationKey = 'countdown_duration';
  static const _selectedAlertTypeKey = 'selected_alert_type';
  static const _customNumberKey = 'custom_emergency_number';
  static const _lastLatKey = 'last_latitude';
  static const _lastLngKey = 'last_longitude';
  static const _lastAddressKey = 'last_address';

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Emergency Contacts ---

  Future<List<EmergencyContact>> getContacts() async {
    final jsonString = _prefs.getString(_contactsKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      return EmergencyContact.decodeList(jsonString);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveContacts(List<EmergencyContact> contacts) async {
    await _prefs.setString(_contactsKey, EmergencyContact.encodeList(contacts));
  }

  // --- Medical Info ---

  Future<MedicalInfo> getMedicalInfo() async {
    final jsonString = _prefs.getString(_medicalInfoKey);
    if (jsonString == null || jsonString.isEmpty) return MedicalInfo();
    try {
      return MedicalInfo.decode(jsonString);
    } catch (_) {
      return MedicalInfo();
    }
  }

  Future<void> saveMedicalInfo(MedicalInfo info) async {
    await _prefs.setString(_medicalInfoKey, info.encode());
  }

  // --- Settings ---

  int getCountdownDuration() => _prefs.getInt(_countdownDurationKey) ?? 5;

  Future<void> setCountdownDuration(int seconds) async {
    await _prefs.setInt(_countdownDurationKey, seconds);
  }

  int getSelectedAlertType() => _prefs.getInt(_selectedAlertTypeKey) ?? 0;

  Future<void> setSelectedAlertType(int index) async {
    await _prefs.setInt(_selectedAlertTypeKey, index);
  }

  String getCustomNumber() => _prefs.getString(_customNumberKey) ?? '112';

  Future<void> setCustomNumber(String number) async {
    await _prefs.setString(_customNumberKey, number);
  }

  // --- Cached Location ---

  Future<void> cacheLocation(double lat, double lng, String address) async {
    await _prefs.setDouble(_lastLatKey, lat);
    await _prefs.setDouble(_lastLngKey, lng);
    await _prefs.setString(_lastAddressKey, address);
  }

  double? get cachedLatitude => _prefs.getDouble(_lastLatKey);
  double? get cachedLongitude => _prefs.getDouble(_lastLngKey);
  String? get cachedAddress => _prefs.getString(_lastAddressKey);
}
