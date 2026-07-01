import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';

/// The shared loading placeholder (design_system.md, "Motion & life" —
/// skeleton content pulses, 1 → 0.4 → 1 over 1.5s, rather than sitting
/// static). Compose one or more of these to sketch incoming content instead
/// of a bare spinner.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({super.key, this.width, this.height = 16});

  final double? width;
  final double height;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _opacity = Tween(begin: 1.0, end: 0.4).animate(_controller);
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
    final box = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(color: colors.surface1),
    );

    if (MediaQuery.of(context).disableAnimations) {
      return ExcludeSemantics(child: box);
    }

    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) =>
            Opacity(opacity: _opacity.value, child: child),
        child: box,
      ),
    );
  }
}
