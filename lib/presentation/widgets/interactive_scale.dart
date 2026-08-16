import 'package:flutter/material.dart';

/// Widget wrapper untuk memberikan efek interaktif pada elemen (tombol, kartu, chip).
/// Memberikan efek:
/// - Cursor Pointer (tangan) saat hover
/// - Skala mikro saat Hover (scale 1.02)
/// - Skala mikro saat Ditekan / Tap (scale 0.96)
class InteractiveScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double hoverScale;
  final double pressScale;
  final BorderRadius? borderRadius;

  const InteractiveScale({
    Key? key,
    required this.child,
    this.onTap,
    this.hoverScale = 1.02,
    this.pressScale = 0.96,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<InteractiveScale> createState() => _InteractiveScaleState();
}

class _InteractiveScaleState extends State<InteractiveScale> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    double scale = 1.0;
    if (_isPressed) {
      scale = widget.pressScale;
    } else if (_isHovered) {
      scale = widget.hoverScale;
    }

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}
