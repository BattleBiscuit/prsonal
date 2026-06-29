import 'package:flutter/material.dart';
import '../widgets/brand_title.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../services/backup_service.dart';
import '../theme/app_colors.dart';
import '../widgets/settings_row_widget.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    final version = ref.watch(appVersionProvider).maybeWhen(
          data: (v) => 'Version $v',
          orElse: () => 'Version …',
        );

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
            onTap: () => _showExportSheet(context, ref),
          ),
          SettingsRow(
            title: 'Import backup',
            subtitle: 'Restore from a backup file',
            trailing: Icon(Icons.download_outlined, color: colors.text3),
            onTap: () => _showImportSheet(context, ref),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              version,
              style: TextStyle(color: colors.text3, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ExportSheet(service: ref.read(backupServiceProvider)),
    );
  }

  void _showImportSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ImportSheet(
        service: ref.read(backupServiceProvider),
        filePicker: ref.read(backupFilePickerProvider),
      ),
    );
  }
}

class _ExportSheet extends StatefulWidget {
  const _ExportSheet({required this.service});

  final BackupService service;

  @override
  State<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<_ExportSheet> {
  final Set<BackupSection> _selected = {...BackupSection.values};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Export',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await widget.service.exportJson(sections: _selected);
            },
            child: const Text('Export'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ImportSheet extends StatefulWidget {
  const _ImportSheet({required this.service, required this.filePicker});

  final BackupService service;
  final Future<String?> Function() filePicker;

  @override
  State<_ImportSheet> createState() => _ImportSheetState();
}

class _ImportSheetState extends State<_ImportSheet> {
  final Set<BackupSection> _selected = {...BackupSection.values};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Restore from backup',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final json = await widget.filePicker();
              if (json == null) return;
              if (!mounted) return;
              // ignore: use_build_context_synchronously
              Navigator.of(this.context).pop();
              await widget.service.importJson(json, sections: _selected);
            },
            child: const Text('Restore selected'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
