import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:maps_launcher/maps_launcher.dart';

import '../models/alert_type.dart';
import '../models/emergency_contact.dart';
import '../models/medical_info.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../widgets/alert_type_selector.dart';
import '../widgets/countdown_overlay.dart';
import '../widgets/emergency_button.dart';
import '../widgets/location_card.dart';
import '../widgets/medical_info_card.dart';
import 'contacts_screen.dart';
import 'medical_info_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storage;

  const HomeScreen({super.key, required this.storage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();

  // Location state
  double? _latitude;
  double? _longitude;
  double? _accuracy;
  String _address = 'Determining location...';
  String? _plusCode;
  bool _locationLoading = true;

  // App state
  AlertType _selectedAlert = AlertType.medical;
  MedicalInfo _medicalInfo = MedicalInfo();
  List<EmergencyContact> _contacts = [];
  int _countdownDuration = 5;
  bool _showCountdown = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initLocation();
  }

  Future<void> _loadData() async {
    final info = await widget.storage.getMedicalInfo();
    final contacts = await widget.storage.getContacts();
    final alertIndex = widget.storage.getSelectedAlertType();
    final countdown = widget.storage.getCountdownDuration();

    // Load cached location
    final cachedLat = widget.storage.cachedLatitude;
    final cachedLng = widget.storage.cachedLongitude;
    final cachedAddr = widget.storage.cachedAddress;

    if (mounted) {
      setState(() {
        _medicalInfo = info;
        _contacts = contacts;
        _countdownDuration = countdown;
        if (alertIndex < AlertType.values.length) {
          _selectedAlert = AlertType.values[alertIndex];
        }
        // Use cached location while we wait for fresh GPS
        if (cachedLat != null && cachedLng != null) {
          _latitude = cachedLat;
          _longitude = cachedLng;
          _address = cachedAddr ?? 'Cached location';
          _plusCode = LocationService.toPlusCode(cachedLat, cachedLng);
        }
      });
    }
  }

  Future<void> _initLocation() async {
    final hasPermission = await _locationService.ensurePermissions();
    if (!hasPermission) {
      if (mounted) {
        setState(() {
          _address = 'Location permission denied';
          _locationLoading = false;
        });
      }
      return;
    }

    _locationService.startListening((position) async {
      final address = await _locationService.getAddress(position);
      final plusCode =
          LocationService.toPlusCode(position.latitude, position.longitude);

      // Cache location for offline use
      await widget.storage
          .cacheLocation(position.latitude, position.longitude, address);

      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _accuracy = position.accuracy;
          _address = address;
          _plusCode = plusCode;
          _locationLoading = false;
        });
      }
    });
  }

  void _onEmergencyPressed() {
    HapticFeedback.heavyImpact();
    if (_countdownDuration > 0) {
      setState(() => _showCountdown = true);
    } else {
      _makeEmergencyCall();
    }
  }

  void _onEmergencyLongPress() {
    // Long press skips countdown
    HapticFeedback.heavyImpact();
    _makeEmergencyCall();
  }

  void _cancelCountdown() {
    HapticFeedback.lightImpact();
    setState(() => _showCountdown = false);
  }

  Future<void> _makeEmergencyCall() async {
    setState(() => _showCountdown = false);

    final number = _selectedAlert == AlertType.custom
        ? widget.storage.getCustomNumber()
        : _selectedAlert.number;

    try {
      await FlutterPhoneDirectCaller.callNumber(number);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not place call to $number')),
        );
      }
    }
  }

  void _openMap() {
    if (_latitude != null && _longitude != null) {
      MapsLauncher.launchCoordinates(_latitude!, _longitude!);
    }
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Emergency Button'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                onPressed: () => _openSettings(),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Alert type selector
                  AlertTypeSelector(
                    selected: _selectedAlert,
                    onSelected: (type) {
                      setState(() => _selectedAlert = type);
                      widget.storage
                          .setSelectedAlertType(AlertType.values.indexOf(type));
                    },
                  ),
                  const SizedBox(height: 24),

                  // Emergency button
                  Center(
                    child: EmergencyButton(
                      alertType: _selectedAlert,
                      onPressed: _onEmergencyPressed,
                      onLongPress: _onEmergencyLongPress,
                      size: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _countdownDuration > 0
                        ? 'Tap to call with ${_countdownDuration}s countdown'
                        : 'Tap to call immediately',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    'Long press to call instantly',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.6),
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Location card
                  LocationCard(
                    latitude: _latitude,
                    longitude: _longitude,
                    accuracy: _accuracy,
                    address: _address,
                    plusCode: _plusCode,
                    isLoading: _locationLoading,
                    onOpenMap: (_latitude != null) ? _openMap : null,
                  ),
                  const SizedBox(height: 12),

                  // Medical info card
                  MedicalInfoCard(
                    info: _medicalInfo,
                    onEdit: () => _openMedicalInfo(),
                  ),
                  const SizedBox(height: 12),

                  // Emergency contacts summary
                  _ContactsSummaryCard(
                    contacts: _contacts,
                    onTap: () => _openContacts(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),

        // Countdown overlay
        if (_showCountdown)
          CountdownOverlay(
            seconds: _countdownDuration,
            alertType: _selectedAlert,
            onComplete: _makeEmergencyCall,
            onCancel: _cancelCountdown,
          ),
      ],
    );
  }

  void _openContacts() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContactsScreen(storage: widget.storage),
      ),
    );
    // Refresh contacts after returning
    final contacts = await widget.storage.getContacts();
    if (mounted) setState(() => _contacts = contacts);
  }

  void _openMedicalInfo() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MedicalInfoScreen(storage: widget.storage),
      ),
    );
    final info = await widget.storage.getMedicalInfo();
    if (mounted) setState(() => _medicalInfo = info);
  }

  void _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(storage: widget.storage),
      ),
    );
    final countdown = widget.storage.getCountdownDuration();
    if (mounted) setState(() => _countdownDuration = countdown);
  }
}

class _ContactsSummaryCard extends StatelessWidget {
  final List<EmergencyContact> contacts;
  final VoidCallback onTap;

  const _ContactsSummaryCard({
    required this.contacts,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.contacts, color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Contacts',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      contacts.isEmpty
                          ? 'Add your emergency contacts'
                          : '${contacts.length} contact${contacts.length == 1 ? '' : 's'} saved',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
