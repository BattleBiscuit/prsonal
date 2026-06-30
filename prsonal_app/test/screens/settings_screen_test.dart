import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prsonal_app/providers/app_providers.dart';
import 'package:prsonal_app/screens/settings_screen.dart';
import 'package:prsonal_app/services/backup_service.dart';

class _MockBackupService extends Mock implements BackupService {}

/// Records every call made to the injected file saver so tests can assert on
/// the contents that were handed off, and can simulate a cancelled dialog.
class _SaverRecorder {
  final List<String> savedContents = [];
  String? returnValue = 'prsonal-backup.json';

  Future<String?> call(String fileName, String contents) async {
    savedContents.add(contents);
    return returnValue;
  }
}

Future<({_MockBackupService service, _SaverRecorder saver})> _pump(
  WidgetTester tester, {
  String? pickedJson,
  String version = '1.0.0',
  bool saverCancels = false,
  Object? importError,
}) async {
  final service = _MockBackupService();
  final saver = _SaverRecorder();
  if (saverCancels) saver.returnValue = null;

  when(() => service.counts()).thenAnswer(
    (_) async => {
      BackupSection.library: 5,
      BackupSection.routines: 3,
      BackupSection.plans: 1,
      BackupSection.history: 12,
    },
  );
  when(
    () => service.exportJson(sections: any(named: 'sections')),
  ).thenAnswer((_) async => '{"_version":1}');
  if (importError != null) {
    when(
      () => service.importJson(any(), sections: any(named: 'sections')),
    ).thenThrow(importError);
  } else {
    when(
      () => service.importJson(any(), sections: any(named: 'sections')),
    ).thenAnswer((_) async {});
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        backupServiceProvider.overrideWithValue(service),
        appVersionProvider.overrideWith((ref) async => version),
        backupFilePickerProvider.overrideWithValue(() async => pickedJson),
        backupFileSaverProvider.overrideWithValue(saver.call),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return (service: service, saver: saver);
}

void main() {
  group('SettingsScreen', () {
    testWidgets(
      'AC-001: Renders an Export backup action that opens the export sheet',
      (tester) async {
        await _pump(tester);
        await tester.tap(find.text('Export backup'));
        await tester.pumpAndSettle();
        expect(find.text('Export'), findsWidgets);
      },
    );

    testWidgets(
      'AC-002: Renders an Import backup action that opens the import sheet',
      (tester) async {
        await _pump(tester);
        await tester.tap(find.text('Import backup'));
        await tester.pumpAndSettle();
        expect(find.textContaining('Restore'), findsWidgets);
      },
    );

    testWidgets(
      'AC-003: Confirming an export writes the selected sections to a backup file via the saver',
      (tester) async {
        final h = await _pump(tester);
        await tester.tap(find.text('Export backup'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ElevatedButton, 'Export').last);
        await tester.pumpAndSettle();
        verify(
          () => h.service.exportJson(sections: any(named: 'sections')),
        ).called(1);
        // The serialised document was handed to the saver.
        expect(h.saver.savedContents, ['{"_version":1}']);
      },
    );

    testWidgets(
      'AC-004: Confirming an import restores the selected sections from the chosen file',
      (tester) async {
        final h = await _pump(tester, pickedJson: '{"library":[]}');
        await tester.tap(find.text('Import backup'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Restore selected').last,
        );
        await tester.pumpAndSettle();
        verify(
          () => h.service.importJson(any(), sections: any(named: 'sections')),
        ).called(1);
      },
    );

    testWidgets('AC-005: Renders the app version', (tester) async {
      await _pump(tester);
      expect(find.textContaining('1.0.0'), findsOneWidget);
    });

    testWidgets(
      'AC-006: The version shown reflects the value reported by appVersionProvider (the build version), not a hardcoded constant',
      (tester) async {
        await _pump(tester, version: '2.5.1');
        expect(find.textContaining('2.5.1'), findsOneWidget);
        expect(find.textContaining('1.0.0'), findsNothing);
      },
    );

    testWidgets(
      'AC-007: A successful export shows a confirmation; cancelling the save dialog writes nothing',
      (tester) async {
        // Cancel path: saver returns null → no "saved" confirmation, but the
        // export was still serialised and handed to the (cancelled) saver.
        final cancelled = await _pump(tester, saverCancels: true);
        await tester.tap(find.text('Export backup'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ElevatedButton, 'Export').last);
        await tester.pumpAndSettle();
        expect(find.textContaining('aved'), findsNothing);
        expect(cancelled.saver.savedContents, hasLength(1));

        // Success path: saver returns a path → confirmation snackbar.
        final ok = await _pump(tester);
        await tester.tap(find.text('Export backup'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ElevatedButton, 'Export').last);
        await tester.pumpAndSettle();
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('aved'), findsOneWidget);
        expect(ok.saver.savedContents, hasLength(1));
      },
    );

    testWidgets(
      'AC-008: A malformed backup file surfaces an error on import instead of crashing',
      (tester) async {
        await _pump(
          tester,
          pickedJson: 'not json',
          importError: const FormatException(
            'Backup document must be a JSON object.',
          ),
        );
        await tester.tap(find.text('Import backup'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Restore selected').last,
        );
        await tester.pumpAndSettle();
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('failed'), findsOneWidget);
      },
    );
  });
}
