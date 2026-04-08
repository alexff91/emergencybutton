import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Provides location services with enhanced accuracy display
/// and Plus Code generation for universal location sharing.
class LocationService {
  StreamSubscription<Position>? _positionSubscription;

  /// Check and request location permissions.
  Future<bool> ensurePermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current position with high accuracy.
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.best),
    );
  }

  /// Start listening to position updates.
  void startListening(void Function(Position position) onPosition) {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5, // meters
      ),
    ).listen(onPosition);
  }

  /// Stop listening to position updates.
  void stopListening() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Reverse geocode a position to a human-readable address.
  Future<String> getAddress(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) return 'Address not found';

      final place = placemarks[0];
      final parts = <String>[
        if (place.street != null && place.street!.isNotEmpty) place.street!,
        if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty)
          place.subThoroughfare!,
        if (place.locality != null && place.locality!.isNotEmpty)
          place.locality!,
        if (place.postalCode != null && place.postalCode!.isNotEmpty)
          place.postalCode!,
        if (place.country != null && place.country!.isNotEmpty) place.country!,
      ];
      return parts.join(', ');
    } catch (e) {
      return 'Unable to determine address';
    }
  }

  /// Generate an Open Location Code (Plus Code) for the given coordinates.
  /// Plus Codes are universally shareable location identifiers from Google.
  /// Format: "8FVC9G8F+6W" (global code)
  static String toPlusCode(double latitude, double longitude,
      {int codeLength = 10}) {
    const codeAlphabet = '23456789CFGHJMPQRVWX';
    const separator = '+';
    const separatorPosition = 8;
    const pairCodeLength = 10;

    latitude = latitude.clamp(-90.0, 90.0);
    longitude = longitude.clamp(-180.0, 180.0);

    // Normalize longitude
    if (longitude < -180) longitude = -180;
    if (longitude >= 180) longitude = 180 - 1e-10;

    // Encode latitude and longitude
    double latVal = latitude + 90;
    double lngVal = longitude + 180;

    final code = StringBuffer();

    // Produce pairs for the first 10 characters
    double latPlaceVal = 20.0;
    double lngPlaceVal = 20.0;

    for (int i = 0; i < pairCodeLength; i += 2) {
      final latDigit = (latVal / latPlaceVal).floor();
      latVal -= latDigit * latPlaceVal;

      final lngDigit = (lngVal / lngPlaceVal).floor();
      lngVal -= lngDigit * lngPlaceVal;

      code.write(codeAlphabet[latDigit.clamp(0, 19)]);
      code.write(codeAlphabet[lngDigit.clamp(0, 19)]);

      if (i == separatorPosition - 2) {
        code.write(separator);
      }

      latPlaceVal /= 20;
      lngPlaceVal /= 20;
    }

    return code.toString();
  }

  /// Format accuracy as a human-readable string.
  static String formatAccuracy(double accuracyMeters) {
    if (accuracyMeters < 5) return 'Excellent (<5m)';
    if (accuracyMeters < 15) return 'Good (<15m)';
    if (accuracyMeters < 50) return 'Fair (<50m)';
    return 'Poor (${accuracyMeters.round()}m)';
  }

  /// Get an accuracy color for UI display.
  static int accuracyColorValue(double accuracyMeters) {
    if (accuracyMeters < 5) return 0xFF4CAF50; // green
    if (accuracyMeters < 15) return 0xFF8BC34A; // light green
    if (accuracyMeters < 50) return 0xFFFF9800; // orange
    return 0xFFF44336; // red
  }

  void dispose() {
    stopListening();
  }
}
