import 'package:flutter/material.dart';

class AnimatedCardWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const AnimatedCardWrapper({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<AnimatedCardWrapper> createState() => _AnimatedCardWrapperState();
}

class _AnimatedCardWrapperState extends State<AnimatedCardWrapper> {
  double scale = 1.0;

  void _onTapDown(_) => setState(() => scale = 0.96);
  void _onTapUp(_) => setState(() => scale = 1.0);
  void _onTapCancel() => setState(() => scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}