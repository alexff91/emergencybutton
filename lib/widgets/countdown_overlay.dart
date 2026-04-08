import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/alert_type.dart';

/// Full-screen countdown overlay shown before an emergency call is placed.
/// Gives the user a chance to cancel accidental presses.
class CountdownOverlay extends StatefulWidget {
  final int seconds;
  final AlertType alertType;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const CountdownOverlay({
    super.key,
    required this.seconds,
    required this.alertType,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay>
    with SingleTickerProviderStateMixin {
  late int _remaining;
  Timer? _timer;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      HapticFeedback.mediumImpact();
      if (_remaining <= 1) {
        timer.cancel();
        widget.onComplete();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.alertType.icon,
              color: widget.alertType.color,
              size: 64,
              semanticLabel: widget.alertType.label,
            ),
            const SizedBox(height: 16),
            Text(
              'Calling ${widget.alertType.number} in',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: Text(
                '$_remaining',
                style: TextStyle(
                  color: widget.alertType.color,
                  fontSize: 120,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 200,
              height: 56,
              child: FilledButton.tonal(
                onPressed: widget.onCancel,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white24,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap cancel to abort',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
