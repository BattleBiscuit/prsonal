import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';

/// The "session heartbeat" signature motion (design_system.md, "Motion &
/// life"): a breathing accent dot that marks a live/active context.
class LiveDot extends StatefulWidget {
  const LiveDot({super.key, this.size = 8});

  final double size;

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _opacity = Tween(begin: 0.4, end: 1.0).animate(_controller);
    _scale = Tween(begin: 0.85, end: 1.0).animate(_controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The ticker itself — not just its visual effect — must stop under
    // reduced motion, or a repeat(reverse: true) loop keeps scheduling
    // frames forever and e.g. pumpAndSettle() in tests never terminates.
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    final dot = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
    );

    if (MediaQuery.of(context).disableAnimations) {
      return ExcludeSemantics(child: dot);
    }

    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: _opacity.value,
          child: Transform.scale(scale: _scale.value, child: child),
        ),
        child: dot,
      ),
    );
  }
}
