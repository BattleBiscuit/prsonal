import 'package:flutter/material.dart';
import '../widgets/brand_title.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../services/backup_service.dart';
import '../theme/app_colors.dart';
import '../widgets/settings_row_widget.dart';
import 'package:prsonal_app/theme/app_spacing.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    final version = ref
        .watch(appVersionProvider)
        .maybeWhen(data: (v) => 'Version $v', orElse: () => 'Version …');

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const BrandTitle('Settings'),
        backgroundColor: colors.bg,
      ),
      body: ListView(
        children: [
          SettingsRow(
            title: 'Export backup',
            subtitle: 'Save your data to a file',
            trailing: Icon(Icons.upload_outlined, color: colors.text3),
            onTap: () => _runExport(context, ref),
          ),
          const Divider(),
          SettingsRow(
            title: 'Import backup',
            subtitle: 'Restore from a backup file',
            trailing: Icon(Icons.download_outlined, color: colors.text3),
            onTap: () => _runImport(context, ref),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(space4),
            child: Text(
              version,
              style: TextStyle(color: colors.text3, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  /// Pick sections, serialise them, then hand the JSON to the saver. Feedback is
  /// shown via the screen's [ScaffoldMessenger] so it survives the sheet closing.
  Future<void> _runExport(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final sections = await showModalBottomSheet<Set<BackupSection>>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) =>
          const _SectionSheet(title: 'Export', confirmLabel: 'Export'),
    );
    if (sections == null || sections.isEmpty) return;

    final service = ref.read(backupServiceProvider);
    final save = ref.read(backupFileSaverProvider);
    try {
      final json = await service.exportJson(sections: sections);
      final saved = await save('prsonal-backup.json', json);
      if (saved == null) return; // user cancelled the save dialog
      messenger.showSnackBar(const SnackBar(content: Text('Backup saved')));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Export failed')));
    }
  }

  /// Pick sections, read a file via the picker, then restore. Surfaces a
  /// readable error if the file is not a recognised backup.
  Future<void> _runImport(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final sections = await showModalBottomSheet<Set<BackupSection>>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const _SectionSheet(
        title: 'Restore from backup',
        confirmLabel: 'Restore selected',
      ),
    );
    if (sections == null || sections.isEmpty) return;

    final pick = ref.read(backupFilePickerProvider);
    final json = await pick();
    if (json == null) return; // user cancelled the file picker

    final service = ref.read(backupServiceProvider);
    try {
      await service.importJson(json, sections: sections);
      messenger.showSnackBar(const SnackBar(content: Text('Backup restored')));
    } on FormatException {
      messenger.showSnackBar(
        const SnackBar(content: Text('Import failed: not a valid backup file')),
      );
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Import failed')));
    }
  }
}

/// Bottom sheet that lets the user choose which [BackupSection]s to act on and
/// pops with the selected set (or `null` if dismissed without confirming).
class _SectionSheet extends StatefulWidget {
  const _SectionSheet({required this.title, required this.confirmLabel});

  final String title;
  final String confirmLabel;

  @override
  State<_SectionSheet> createState() => _SectionSheetState();
}

class _SectionSheetState extends State<_SectionSheet> {
  final Set<BackupSection> _selected = {...BackupSection.values};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(space4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: space4),
          ...BackupSection.values.map(
            (section) => CheckboxListTile(
              title: Text(section.name),
              value: _selected.contains(section),
              onChanged: (v) => setState(() {
                if (v == true) {
                  _selected.add(section);
                } else {
                  _selected.remove(section);
                }
              }),
            ),
          ),
          const SizedBox(height: space4),
          ElevatedButton(
            onPressed: _selected.isEmpty
                ? null
                : () => Navigator.of(context).pop(_selected),
            child: Text(widget.confirmLabel),
          ),
          const SizedBox(height: space4),
        ],
      ),
    );
  }
}
