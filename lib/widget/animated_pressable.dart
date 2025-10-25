import 'package:flutter/material.dart';

class AnimatedPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final double scale;
  final BorderRadius? borderRadius;

  const AnimatedPressable({
    super.key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 90),
    this.scale = 0.98,
    this.borderRadius,
  });

  @override
  State<AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<AnimatedPressable> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (!mounted) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final double targetScale = _pressed ? widget.scale : 1.0;
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: widget.duration,
        curve: Curves.easeOut,
        scale: targetScale,
        child: widget.child,
      ),
    );
  }
}
