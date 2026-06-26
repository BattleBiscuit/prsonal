import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The app-bar title used across chrome screens: the "PRsonal" wordmark
/// ("PR" in primary text, "sonal" in accent) followed by a "·" divider and the
/// page title — matching gym-app's header.
class BrandTitle extends StatelessWidget {
  const BrandTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'PR',
                style: TextStyle(
                  color: colors.text1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: 'sonal',
                style: TextStyle(
                  color: colors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          semanticsLabel: 'PRsonal',
          style: const TextStyle(fontSize: 15),
        ),
        Text('  ·  ', style: TextStyle(color: colors.text3, fontSize: 14)),
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.text1,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
