import 'package:flutter/material.dart';

enum AlertType {
  medical(
    label: 'Medical',
    icon: Icons.local_hospital,
    color: Color(0xFFE53935),
    number: '112',
    description: 'Medical emergency',
  ),
  fire(
    label: 'Fire',
    icon: Icons.local_fire_department,
    color: Color(0xFFFF6F00),
    number: '112',
    description: 'Fire emergency',
  ),
  police(
    label: 'Police',
    icon: Icons.local_police,
    color: Color(0xFF1565C0),
    number: '112',
    description: 'Police emergency',
  ),
  custom(
    label: 'Custom',
    icon: Icons.sos,
    color: Color(0xFF6A1B9A),
    number: '112',
    description: 'Custom emergency',
  );

  const AlertType({
    required this.label,
    required this.icon,
    required this.color,
    required this.number,
    required this.description,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String number;
  final String description;
}
