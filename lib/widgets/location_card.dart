import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/location_service.dart';

/// Displays current location with accuracy indicator, address,
/// and Plus Code for easy sharing.
class LocationCard extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final String address;
  final String? plusCode;
  final bool isLoading;
  final VoidCallback? onOpenMap;

  const LocationCard({
    super.key,
    this.latitude,
    this.longitude,
    this.accuracy,
    required this.address,
    this.plusCode,
    this.isLoading = false,
    this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accuracyColor = accuracy != null
        ? Color(LocationService.accuracyColorValue(accuracy!))
        : theme.colorScheme.outline;
    final accuracyText = accuracy != null
        ? LocationService.formatAccuracy(accuracy!)
        : 'Determining...';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.my_location, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Your Location',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Accuracy badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accuracyColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.gps_fixed, size: 14, color: accuracyColor),
                      const SizedBox(width: 4),
                      Text(
                        accuracyText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accuracyColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Address
            if (isLoading)
              const _LoadingRow(text: 'Locating...')
            else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.place, size: 18, color: theme.colorScheme.outline),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      address,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],

            // Coordinates
            if (latitude != null && longitude != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.explore,
                      size: 18, color: theme.colorScheme.outline),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Copy coordinates',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                        text:
                            '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}',
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Coordinates copied'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],

            // Plus Code
            if (plusCode != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.grid_on,
                      size: 18, color: theme.colorScheme.outline),
                  const SizedBox(width: 6),
                  Text(
                    'Plus Code: $plusCode',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Copy Plus Code',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: plusCode!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Plus Code copied'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],

            // Open Map button
            if (onOpenMap != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onOpenMap,
                  icon: const Icon(Icons.map),
                  label: const Text('Open in Maps'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadingRow extends StatelessWidget {
  final String text;
  const _LoadingRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
