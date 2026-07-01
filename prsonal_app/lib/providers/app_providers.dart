import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../database/app_database.dart';
import '../services/library_service.dart';
import '../services/plans_service.dart';
import '../services/routines_service.dart';
import '../widgets/exercise_search_input_widget.dart';

export '../services/routines_service.dart'
    show RoutineSummary, RoutineDraft, RoutineExerciseDraft;
export '../services/library_service.dart' show LibraryExercise;
export '../services/plans_service.dart'
    show PlanDraft, PlanEntryDraft, PlanEntryInput;

/// Provides the singleton [AppDatabase] instance.
///
/// Override this in tests with [AppDatabase.forTesting].
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Provides a factory that returns the current [DateTime].
///
/// Override this in tests to inject a fixed clock.
final nowProvider = Provider<DateTime Function()>((ref) => DateTime.now);

// ---------------------------------------------------------------------------
// Cross-aggregate change signal
// ---------------------------------------------------------------------------

/// Emits a fresh sentinel whenever any table feeding a cross-screen aggregate
/// (plans, plan entries, routines, completed sessions) changes.
///
/// Providers that recompute one-shot, multi-query aggregates (e.g. plan
/// streaks, progress summaries) watch this single signal instead of each
/// wiring up its own set of per-table watch streams.
final dataChangedProvider = StreamProvider<Object>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final controller = StreamController<Object>();
  final subscriptions = [
    db.watchAllPlans().listen((_) => controller.add(Object())),
    db.watchAllPlanEntries().listen((_) => controller.add(Object())),
    db.watchAllRoutines().listen((_) => controller.add(Object())),
    db.watchCompletedSessions().listen((_) => controller.add(Object())),
  ];
  ref.onDispose(() {
    for (final s in subscriptions) {
      s.cancel();
    }
    controller.close();
  });
  return controller.stream;
});

// ---------------------------------------------------------------------------
// Routines
// ---------------------------------------------------------------------------

/// Stream of all routines; override with StreamProvider.overrideWith in tests.
final routinesListProvider = StreamProvider<List<RoutineSummary>>((ref) {
  final service = ref.watch(routinesServiceProvider);
  return service.watchRoutines();
});

/// Draft for a single routine (null = create mode).
final routineDraftProvider = FutureProvider.family<RoutineDraft?, String?>((
  ref,
  routineId,
) async {
  if (routineId == null) return null;
  final service = ref.watch(routinesServiceProvider);
  return service.getRoutineForEdit(routineId);
});

// ---------------------------------------------------------------------------
// Library
// ---------------------------------------------------------------------------

/// Stream of all library exercises.
final libraryListProvider = StreamProvider<List<LibraryExercise>>((ref) {
  final service = ref.watch(libraryServiceProvider);
  return service.watchExercises();
});

/// Stream of ExerciseOption (for ExerciseForm picker).
final libraryOptionsProvider = StreamProvider<List<ExerciseOption>>((
  ref,
) async* {
  final service = ref.watch(libraryServiceProvider);
  await for (final exercises in service.watchExercises()) {
    yield exercises
        .map(
          (e) => ExerciseOption(
            id: e.id,
            name: e.name,
            type: e.type,
            primaryMuscles: e.primaryMuscles,
          ),
        )
        .toList();
  }
});

// ---------------------------------------------------------------------------
// Plans
// ---------------------------------------------------------------------------

/// Draft for a single plan (null = create mode).
final planDraftProvider = FutureProvider.family<PlanDraft?, String?>((
  ref,
  planId,
) async {
  if (planId == null) return null;
  final service = ref.watch(plansServiceProvider);
  return service.getPlanForEdit(planId);
});

// ---------------------------------------------------------------------------
// App meta
// ---------------------------------------------------------------------------

/// App version string, read at runtime from the build via `package_info_plus`.
///
/// In release builds this is the Android `versionName`, which the release
/// workflow sets from the git tag (`--build-name=${tag#v}`), so the app
/// reflects the GitHub Release version. In dev builds it falls back to the
/// `version:` in `pubspec.yaml`. Override in tests.
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

// ---------------------------------------------------------------------------
// Backup file IO
//
// The backup *logic* (serialise/restore) lives in BackupService and deals only
// in JSON strings. These two providers are the thin platform glue that moves
// those strings to and from a file the user chooses, backed by `file_picker`.
// They are overridden with stubs in tests so widgets never touch the platform.
// ---------------------------------------------------------------------------

/// Presents a file picker and returns the chosen file's contents as a JSON
/// string, or `null` if the user cancels.
Future<String?> _pickBackupJson() async {
  final result = await FilePicker.platform.pickFiles(withData: true);
  if (result == null || result.files.isEmpty) return null;
  final file = result.files.first;
  if (file.bytes != null) return utf8.decode(file.bytes!);
  final path = file.path;
  if (path != null) return File(path).readAsString();
  return null;
}

/// Presents a save dialog and writes [contents] to the chosen location.
/// Returns the saved path/name, or `null` if the user cancels.
Future<String?> _saveBackupJson(String fileName, String contents) async {
  final bytes = Uint8List.fromList(utf8.encode(contents));
  final path = await FilePicker.platform.saveFile(
    dialogTitle: 'Save backup',
    fileName: fileName,
    bytes: bytes,
  );
  if (path == null) return null;
  // On Android/iOS `saveFile` already wrote the bytes. On desktop it only
  // returns the chosen (non-existing) path, so we write the file ourselves.
  if (!Platform.isAndroid && !Platform.isIOS) {
    await File(path).writeAsBytes(bytes);
  }
  return path;
}

/// A function that presents a file picker and returns the JSON string or null.
/// Override in tests with a stub.
final backupFilePickerProvider = Provider<Future<String?> Function()>(
  (ref) => _pickBackupJson,
);

/// A function that presents a save dialog, writes the export JSON to the chosen
/// location, and returns the saved file name/path (or null if cancelled).
/// Override in tests with a stub.
final backupFileSaverProvider =
    Provider<Future<String?> Function(String fileName, String contents)>(
      (ref) => _saveBackupJson,
    );
