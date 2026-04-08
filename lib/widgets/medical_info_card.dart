import 'package:flutter/material.dart';
import '../models/medical_info.dart';

/// Displays medical information in a compact, scannable card format.
/// Designed for first responders to quickly read critical info.
class MedicalInfoCard extends StatelessWidget {
  final MedicalInfo info;
  final VoidCallback? onEdit;

  const MedicalInfoCard({
    super.key,
    required this.info,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (info.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.medical_information,
                    color: theme.colorScheme.primary, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Medical Info',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Blood type, allergies, medications...',
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

    return Card(
      elevation: 0,
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_information,
                    color: theme.colorScheme.error, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Medical Information',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
                const Spacer(),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: onEdit,
                    tooltip: 'Edit medical info',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (info.bloodType.isNotEmpty)
              _InfoRow(
                icon: Icons.bloodtype,
                label: 'Blood Type',
                value: info.bloodType,
              ),
            if (info.allergies.isNotEmpty)
              _InfoRow(
                icon: Icons.warning_amber,
                label: 'Allergies',
                value: info.allergies,
              ),
            if (info.medications.isNotEmpty)
              _InfoRow(
                icon: Icons.medication,
                label: 'Medications',
                value: info.medications,
              ),
            if (info.conditions.isNotEmpty)
              _InfoRow(
                icon: Icons.health_and_safety,
                label: 'Conditions',
                value: info.conditions,
              ),
            if (info.emergencyNotes.isNotEmpty)
              _InfoRow(
                icon: Icons.note,
                label: 'Notes',
                value: info.emergencyNotes,
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
