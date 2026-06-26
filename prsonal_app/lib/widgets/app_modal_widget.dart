import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';

class AppModal extends StatelessWidget {
  const AppModal({
    super.key,
    this.title,
    this.onClose,
    required this.child,
    this.actions,
  });

  final String? title;
  final VoidCallback? onClose;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: TextStyle(
                      color: colors.text1,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Semantics(
                  label: 'Close',
                  button: true,
                  child: GestureDetector(
                    onTap: onClose,
                    child: Icon(Icons.close, color: colors.text2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...actions!,
          ],
        ],
      ),
    );
  }
}
