import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_motion.dart';

/// The "on load" motion (design_system.md, "Motion & life"): content fades
/// in and rises 8dp into place over `AppDurations.normal`, once, on mount.
class FadeRiseIn extends StatefulWidget {
  const FadeRiseIn({super.key, required this.child});

  final Widget child;

  @override
  State<FadeRiseIn> createState() => _FadeRiseInState();
}

class _FadeRiseInState extends State<FadeRiseIn>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _opacity;
  Animation<double>? _offset;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null && !MediaQuery.of(context).disableAnimations) {
      final controller = AnimationController(
        vsync: this,
        duration: AppDurations.normal,
      )..forward();
      _controller = controller;
      _opacity = Tween(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
      _offset = Tween(
        begin: 8.0,
        end: 0.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, child) => Opacity(
        key: const ValueKey('fadeRiseInOpacity'),
        opacity: _opacity!.value,
        child: Transform.translate(
          key: const ValueKey('fadeRiseInOffset'),
          offset: Offset(0, _offset!.value),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
