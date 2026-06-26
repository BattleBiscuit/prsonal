import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';

class PrRow extends StatelessWidget {
  const PrRow({
    super.key,
    required this.exerciseName,
    required this.dateLabel,
    required this.weightLabel,
    required this.oneRmLabel,
    this.onTap,
  });

  final String exerciseName;
  final String dateLabel;
  final String weightLabel;
  final String oneRmLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exerciseName,
                    style: TextStyle(
                      color: colors.text1,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateLabel,
                    style: TextStyle(color: colors.text2, fontSize: 13),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  weightLabel,
                  style: TextStyle(
                    color: colors.text1,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  oneRmLabel,
                  style: TextStyle(color: colors.text3, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
