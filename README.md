# Emergency Button

A personal safety app built with Flutter that helps you contact emergency services instantly with your precise location. Designed for reliability when seconds count.

## Features

### One-Tap Emergency Calling
- Large, animated SOS button with haptic feedback
- **Countdown timer** (0-10s configurable) with cancel option to prevent accidental calls
- Long-press to skip countdown and call instantly
- Direct dialing to emergency services (112 / configurable)

### Multiple Alert Types
| Type | Icon | Use Case |
|------|------|----------|
| Medical | Hospital | Health emergencies, injuries |
| Fire | Flame | Fire, gas leaks, hazards |
| Police | Shield | Crime, threats, accidents |
| Custom | SOS | Custom number (family, security) |

### Precise Location Sharing
- Real-time GPS tracking with **accuracy indicator** (Excellent/Good/Fair/Poor)
- Reverse geocoding to human-readable addresses
- **Plus Codes** (Open Location Codes) for universal location sharing
- One-tap copy coordinates or Plus Code to clipboard
- Open location directly in Maps app
- **Offline caching** of last known location

### Medical Information Card
- Blood type, allergies, medications, conditions
- Emergency notes for first responders (pacemaker, DNR, service animal)
- Prominently displayed for quick scanning by emergency personnel
- Stored locally on device for privacy

### Emergency Contacts
- Add unlimited emergency contacts with name, phone, relationship
- One-tap calling from contact list
- Contacts cached locally for offline access

### Design & Accessibility
- **Material 3** design with dynamic color theming
- Automatic **dark mode** support
- Large touch targets for high-stress situations
- Semantic labels for screen readers
- Portrait-locked for consistent UI orientation

## Architecture

```
lib/
  main.dart                    # App entry, Material 3 theming
  models/
    alert_type.dart            # Emergency type enum (medical/fire/police/custom)
    emergency_contact.dart     # Contact model with JSON serialization
    medical_info.dart          # Medical data model
  services/
    location_service.dart      # GPS, geocoding, Plus Code generation
    storage_service.dart       # SharedPreferences persistence layer
  screens/
    home_screen.dart           # Main screen with SOS button
    contacts_screen.dart       # Emergency contacts CRUD
    medical_info_screen.dart   # Medical info form
    settings_screen.dart       # Countdown timer, custom number
  widgets/
    alert_type_selector.dart   # Alert type horizontal picker
    countdown_overlay.dart     # Full-screen countdown with cancel
    emergency_button.dart      # Animated SOS button
    location_card.dart         # Location display with accuracy
    medical_info_card.dart     # Medical info display card
```

## Getting Started

### Prerequisites
- Flutter SDK >= 3.0.0
- Android SDK / Xcode for respective platforms
- Physical device recommended (GPS required)

### Installation

```bash
# Clone the repository
git clone https://github.com/alexff91/emergencybutton.git
cd emergencybutton

# Install dependencies
flutter pub get

# Run on connected device
flutter run
```

### Permissions

The app requires:
- **Location** (Fine + Coarse) - for GPS coordinates and address
- **Phone** - for direct emergency calling

These are requested at runtime with clear explanations.

## Configuration

| Setting | Default | Range | Description |
|---------|---------|-------|-------------|
| Countdown | 5s | 0-10s | Delay before placing call |
| Custom Number | 112 | Any | Phone number for Custom alert type |
| Alert Type | Medical | 4 types | Default emergency category |

## Tech Stack

- **Flutter** 3.x with Material 3
- **Geolocator** - GPS positioning
- **Geocoding** - Reverse geocoding
- **SharedPreferences** - Local data persistence
- **Maps Launcher** - Native maps integration
- **Flutter Phone Direct Caller** - Direct dialing

## Privacy

All data (contacts, medical info, location cache) is stored **locally on the device** using SharedPreferences. No data is sent to external servers. No analytics or tracking.

## Contributing

Contributions are welcome. Please open an issue first to discuss what you would like to change.

## License

This project is open source. See the repository for license details.
