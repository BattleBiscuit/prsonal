---
name: Settings
type: screen
status: approved
---

## Description
App settings (Settings tab, route `/settings`). Two sections: **Data** (export / import backup) and
**About** (app version). gym-app's violent mode, GitHub update check, developer tools, and the raw
recovery screen are intentionally not ported (see [[architecture]]).

The displayed version is the build's real version, not a hardcoded string: `appVersionProvider`
reads it at runtime via `package_info_plus`. In release builds this is the Android `versionName`,
which `.github/workflows/release.yml` sets from the git tag (`--build-name=${tag#v}`), so the app
always reflects the GitHub Release version. In local/dev builds it falls back to the `version:` in
`pubspec.yaml`. While the value is loading the row shows `Version …`.

## Layout

```
┌───────────────────────────────────────┐
│ PRsonal · Settings                    │
├───────────────────────────────────────┤
│ DATA                                  │
│ Export backup            ↑            │
│ Import backup            ↓            │
│ ABOUT                                 │
│ PRsonal · v1.0.0                      │
└───────────────────────────────────────┘
```

## Widgets used

| Widget | Spec |
|--------|------|
| AppPageShell · AppModal · AppButton | shared |
| SettingsRow | `widgets/settings_row.md` |

## State dependencies
- `backupServiceProvider` — export/import + counts
- `backupFilePickerProvider` — presents a file picker and returns the JSON contents of the
  chosen file, or `null` if the user cancels (import)
- `backupFileSaverProvider` — presents a save dialog and writes the export JSON to the chosen
  location; returns the saved file name/path, or `null` if the user cancels (export)
- `appVersionProvider` — async version string from `package_info_plus` (build `versionName`,
  set from the release tag; pubspec `version` in dev). Exposed as a `FutureProvider<String>`.

## Behaviour
- **Export** serialises the selected sections via `backupServiceProvider.exportJson` and hands
  the result to `backupFileSaverProvider` with a suggested file name (`prsonal-backup.json`).
  On success a confirmation is shown; if the user cancels the save dialog nothing is written.
- **Import** reads the chosen file via `backupFilePickerProvider` and restores the selected
  sections via `backupServiceProvider.importJson`. Cancelling the picker is a no-op. A malformed
  or unrecognised file (the service throws `FormatException`) surfaces an error message rather
  than crashing.

## Acceptance Criteria
- AC-001: Renders an Export backup action that opens the export sheet
- AC-002: Renders an Import backup action that opens the import sheet
- AC-003: Confirming an export writes the selected sections to a backup file via the saver
- AC-004: Confirming an import restores the selected sections from the chosen file
- AC-005: Renders the app version
- AC-006: The version shown reflects the value reported by `appVersionProvider` (the build version), not a hardcoded constant
- AC-007: A successful export shows a confirmation; cancelling the save dialog writes nothing
- AC-008: A malformed backup file surfaces an error on import instead of crashing
