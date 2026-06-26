# prsonal_app — Development Rules

## Spec-Driven Development Workflow

This project uses a strict spec-first, test-first workflow. The order is **always**:

```
1. Write / update spec  →  2. Write / update tests  →  3. Implement
```

Never skip or reverse a step, even for small changes.

---

## Specs

Specs live in `specs/` and are the single source of truth for what the app does.

| Type | Location | Dart counterpart |
|------|----------|-----------------|
| Model | `specs/models/<name>.md` | `lib/models/<name>.dart` |
| Screen | `specs/screens/<name>.md` | `lib/screens/<name>_screen.dart` |
| Widget | `specs/widgets/<name>.md` | `lib/widgets/<name>_widget.dart` |
| Service | `specs/services/<name>.md` | `lib/services/<name>_service.dart` |
| Decision | `specs/<name>.md` (top-level) | n/a — no code counterpart |

`specs/architecture.md` is a decision doc. Read it before implementing anything — it defines
state management, navigation, folder structure, and error handling for the whole app.

**Status lifecycle:**
- `draft` — being written; no implementation allowed
- `approved` — reviewed and agreed; tests must be written next
- `implemented` — all acceptance criteria have passing tests and code

**Rules:**
- Never create a file in `lib/` without an `approved` spec in `specs/`
- Always copy from `specs/_templates/`; never start a spec from blank
- Never implement a `draft` spec

---

## Tests

Tests live in `test/` and mirror the spec directory structure.

```
specs/models/user.md          →  test/models/user_test.dart
specs/screens/login.md        →  test/screens/login_screen_test.dart
specs/widgets/avatar.md       →  test/widgets/avatar_widget_test.dart
specs/services/auth.md        →  test/services/auth_service_test.dart
```

End-to-end flows go in `integration_test/`.

**Rules:**
- Write all tests for a spec **before** writing the implementation (tests will fail — that is correct)
- Every acceptance criterion (`AC-NNN`) in a spec must be quoted verbatim as a test description:
  ```dart
  test('AC-001: email must not be empty', () { ... });
  ```
- Tests must pass (not just compile) before marking a spec `implemented`
- Use `mocktail` to mock dependencies in unit and widget tests

---

## Preflight Check

Run before marking any task complete:

```bash
./scripts/preflight.sh
```

This runs `flutter analyze`, `flutter test`, and the spec coverage check in sequence.
All three must pass. The coverage check verifies every AC-NNN in every spec has a matching
test description — not just that a test file exists.

---

## Adding a Feature — Checklist

1. [ ] Create or update spec in `specs/<type>/<name>.md` (status: `draft`)
2. [ ] Review spec; set status to `approved`
3. [ ] Write all tests in `test/<type>/` — reference every AC-NNN; tests will fail initially
4. [ ] Run `./scripts/check_spec_coverage.sh` — must pass (tests failing is expected at this point)
5. [ ] Implement in `lib/<type>/`
6. [ ] Run `./scripts/preflight.sh` — analyze + tests + coverage must all pass
7. [ ] Set spec status to `implemented`
