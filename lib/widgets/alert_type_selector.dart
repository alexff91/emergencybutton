import 'package:flutter/material.dart';
import '../models/alert_type.dart';

/// Horizontal selector for emergency alert types (Medical, Fire, Police, Custom).
class AlertTypeSelector extends StatelessWidget {
  final AlertType selected;
  final ValueChanged<AlertType> onSelected;

  const AlertTypeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: AlertType.values.map((type) {
        final isSelected = type == selected;
        return _AlertTypeChip(
          type: type,
          isSelected: isSelected,
          onTap: () => onSelected(type),
        );
      }).toList(),
    );
  }
}

class _AlertTypeChip extends StatelessWidget {
  final AlertType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _AlertTypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? type.color.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? type.color : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type.icon,
              color: isSelected ? type.color : theme.colorScheme.outline,
              size: 28,
              semanticLabel: type.label,
            ),
            const SizedBox(height: 4),
            Text(
              type.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected ? type.color : theme.colorScheme.outline,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
