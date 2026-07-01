import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/theme/app_typography.dart';
import 'package:prsonal_app/theme/app_spacing.dart';

/// PR row — ported from gym-app's PR list rows. When [celebrate] is set (a
/// PR that was *just* set), it plays the one-shot "PR moment" motion from
/// design_system.md: a brief accent background flash plus a number-roll pop
/// on the weight value, once, on mount.
class PrRow extends StatefulWidget {
  const PrRow({
    super.key,
    required this.exerciseName,
    required this.dateLabel,
    required this.weightLabel,
    required this.oneRmLabel,
    this.onTap,
    this.celebrate = false,
  });

  final String exerciseName;
  final String dateLabel;
  final String weightLabel;
  final String oneRmLabel;
  final VoidCallback? onTap;
  final bool celebrate;

  @override
  State<PrRow> createState() => _PrRowState();
}

class _PrRowState extends State<PrRow> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _flash;
  Animation<double>? _rollScale;
  Animation<double>? _rollOpacity;

  @override
  void initState() {
    super.initState();
    if (widget.celebrate) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..forward();
      _controller = controller;
      _flash = Tween(
        begin: 0.20,
        end: 0.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
      _rollScale = Tween(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
        ),
      );
      _rollOpacity = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    final weightText = Text(
      widget.weightLabel,
      style: monoNumerals(
        TextStyle(
          color: colors.text1,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: space4, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.exerciseName,
                  style: TextStyle(
                    color: colors.text1,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.dateLabel,
                  style: TextStyle(color: colors.text2, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _controller == null
                  ? weightText
                  : AnimatedBuilder(
                      animation: _controller!,
                      builder: (context, child) => Opacity(
                        opacity: _rollOpacity!.value,
                        child: Transform.scale(
                          scale: _rollScale!.value,
                          child: child,
                        ),
                      ),
                      child: weightText,
                    ),
              const SizedBox(height: 2),
              Text(
                widget.oneRmLabel,
                style: monoNumerals(
                  TextStyle(color: colors.text3, fontSize: 12),
                ),
              ),
            ],
          ),
          if (widget.onTap != null) ...[
            const SizedBox(width: space2),
            Icon(Icons.chevron_right_outlined, color: colors.text2),
          ],
        ],
      ),
    );

    if (_controller != null) {
      content = AnimatedBuilder(
        animation: _controller!,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: _flash!.value),
          ),
          child: child,
        ),
        child: content,
      );
    }

    return InkWell(onTap: widget.onTap, child: content);
  }
}
