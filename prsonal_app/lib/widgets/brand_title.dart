import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'brand_mark.dart';

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
        BrandMark(size: 18, color: colors.text1),
        const SizedBox(width: 7),
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
          style: const TextStyle(fontSize: 13),
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
