import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/widgets/app_button_widget.dart';

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
        borderRadius: BorderRadius.zero,
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
                Tooltip(
                  message: 'Close',
                  child: Semantics(
                    label: 'Close',
                    button: true,
                    child: GestureDetector(
                      onTap: onClose,
                      child: Icon(Icons.close, color: colors.text2),
                    ),
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

/// Presents [child] as a bottom-sheet modal with the app's scrim and slide-up,
/// wrapping the [AppModal] content. Returns the value the sheet is popped with.
Future<T?> showAppModal<T>(
  BuildContext context, {
  String? title,
  required Widget child,
  List<Widget> Function(BuildContext sheetContext)? actionsBuilder,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.70),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom:
            12 +
            MediaQuery.of(ctx).viewInsets.bottom +
            MediaQuery.of(ctx).padding.bottom,
      ),
      child: AppModal(
        title: title,
        onClose: isDismissible ? () => Navigator.of(ctx).pop() : null,
        actions: actionsBuilder?.call(ctx),
        child: child,
      ),
    ),
  );
}

/// A confirm/cancel bottom sheet. Resolves to `true` when confirmed.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  AppButtonVariant confirmVariant = AppButtonVariant.danger,
}) async {
  final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
  final result = await showAppModal<bool>(
    context,
    title: title,
    child: message == null
        ? const SizedBox.shrink()
        : Text(message, style: TextStyle(color: colors.text2, fontSize: 14)),
    actionsBuilder: (ctx) => [
      AppButton(
        label: confirmLabel,
        variant: confirmVariant,
        full: true,
        onPressed: () => Navigator.of(ctx).pop(true),
      ),
      const SizedBox(height: 8),
      AppButton(
        label: cancelLabel,
        variant: AppButtonVariant.ghost,
        full: true,
        onPressed: () => Navigator.of(ctx).pop(false),
      ),
    ],
  );
  return result ?? false;
}
