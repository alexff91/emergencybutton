import 'package:flutter/material.dart';
import '../models/alert_type.dart';

/// Large, animated emergency button with ripple effect and haptic feedback.
class EmergencyButton extends StatefulWidget {
  final AlertType alertType;
  final VoidCallback onPressed;
  final VoidCallback onLongPress;
  final double size;

  const EmergencyButton({
    super.key,
    required this.alertType,
    required this.onPressed,
    required this.onLongPress,
    this.size = 200,
  });

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.alertType.color.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: widget.alertType.color.withValues(alpha: 0.2),
            blurRadius: 60,
            spreadRadius: 15,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          onLongPress: widget.onLongPress,
          customBorder: const CircleBorder(),
          child: Ink(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.alertType.color,
                  Color.lerp(widget.alertType.color, Colors.black, 0.3)!,
                ],
                center: const Alignment(-0.2, -0.2),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.alertType.icon,
                    color: Colors.white,
                    size: widget.size * 0.3,
                    semanticLabel: '${widget.alertType.label} emergency button',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.size * 0.15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
