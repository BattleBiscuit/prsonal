---
name: BodyService
type: service
status: approved
---

## Description
Logs and reads body measurements ([[body_metric]]). Powers the Body screen and supplies the app's
working bodyweight (latest `weight` entry, default 80 kg) used by the session engine to resolve
bodyweight-relative sets. Exposed via `bodyServiceProvider`.

## Methods

| Method | Inputs | Output | Side Effects |
|--------|--------|--------|--------------|
| watchLatest | — | `Stream<Map<BodyMetricType, BodyMetric?>>` | none — most recent per type |
| watchHistory | `BodyMetricType type, {int days}` | `Stream<List<BodyMetric>>` | none — within window, newest first |
| log | `BodyMetricType type, double value, {DateTime? at}` | `Future<void>` | inserts a metric |
| deleteEntry | `String id` | `Future<void>` | removes one entry |
| currentBodyweight | — | `Future<double>` | none — latest weight, or 80 |

## Acceptance Criteria
- AC-001: log inserts a metric of the given type and value
- AC-002: watchLatest returns the most recent entry for each metric type
- AC-003: watchHistory returns entries for a type within the window, newest first
- AC-004: deleteEntry removes a single entry
- AC-005: currentBodyweight returns the latest logged weight, or 80 when none exists
