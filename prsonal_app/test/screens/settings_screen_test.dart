import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prsonal_app/providers/app_providers.dart';
import 'package:prsonal_app/screens/settings_screen.dart';
import 'package:prsonal_app/services/backup_service.dart';

class _MockBackupService extends Mock implements BackupService {}

Future<_MockBackupService> _pump(WidgetTester tester, {String? pickedJson}) async {
  final service = _MockBackupService();
  when(() => service.counts()).thenAnswer((_) async => {
        BackupSection.library: 5,
        BackupSection.routines: 3,
        BackupSection.plans: 1,
        BackupSection.history: 12,
      });
  when(() => service.exportJson(sections: any(named: 'sections')))
      .thenAnswer((_) async => '{}');
  when(() => service.importJson(any(), sections: any(named: 'sections')))
      .thenAnswer((_) async {});
  await tester.pumpWidget(ProviderScope(
    overrides: [
      backupServiceProvider.overrideWithValue(service),
      appVersionProvider.overrideWithValue('1.0.0'),
      backupFilePickerProvider.overrideWithValue(() async => pickedJson),
    ],
    child: const MaterialApp(home: SettingsScreen()),
  ));
  await tester.pumpAndSettle();
  return service;
}

void main() {
  group('SettingsScreen', () {
    testWidgets('AC-001: Renders an Export backup action that opens the export sheet',
        (tester) async {
      await _pump(tester);
      await tester.tap(find.text('Export backup'));
      await tester.pumpAndSettle();
      expect(find.text('Export'), findsWidgets);
    });

    testWidgets('AC-002: Renders an Import backup action that opens the import sheet',
        (tester) async {
      await _pump(tester);
      await tester.tap(find.text('Import backup'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Restore'), findsWidgets);
    });

    testWidgets('AC-003: Confirming an export creates a backup of the selected sections',
        (tester) async {
      final service = await _pump(tester);
      await tester.tap(find.text('Export backup'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Export').last);
      await tester.pumpAndSettle();
      verify(() => service.exportJson(sections: any(named: 'sections'))).called(1);
    });

    testWidgets('AC-004: Confirming an import restores the selected sections from the chosen file',
        (tester) async {
      final service = await _pump(tester, pickedJson: '{"library":[]}');
      await tester.tap(find.text('Import backup'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Restore selected').last);
      await tester.pumpAndSettle();
      verify(() => service.importJson(any(), sections: any(named: 'sections'))).called(1);
    });

    testWidgets('AC-005: Renders the app version', (tester) async {
      await _pump(tester);
      expect(find.textContaining('1.0.0'), findsOneWidget);
    });
  });
}
