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
- `backupFilePickerProvider` — returns the JSON contents of a chosen file (import)
- `appVersionProvider` — async version string from `package_info_plus` (build `versionName`,
  set from the release tag; pubspec `version` in dev). Exposed as a `FutureProvider<String>`.

## Acceptance Criteria
- AC-001: Renders an Export backup action that opens the export sheet
- AC-002: Renders an Import backup action that opens the import sheet
- AC-003: Confirming an export creates a backup of the selected sections
- AC-004: Confirming an import restores the selected sections from the chosen file
- AC-005: Renders the app version
- AC-006: The version shown reflects the value reported by `appVersionProvider` (the build version), not a hardcoded constant
