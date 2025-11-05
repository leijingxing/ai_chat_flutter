# Repository Guidelines

## Project Structure & Module Organization
Core package code lives in `lib/`, with `ai_chat_flutter.dart` exporting modules under `lib/src/` (`controllers`, `models`, `providers`, `services`, `themes`, `widgets`). The `example/lib/main.dart` app showcases integration and is the place to prove new UI flows. Tests live in `test/`, mirroring library structure, while generated artifacts sit in `.dart_tool/` and should remain untouched.

## Build, Test, and Development Commands
- `flutter pub get` — sync dependencies before code generation or builds.
- `dart run build_runner build --delete-conflicting-outputs` — regenerate Hive adapters and JSON serializers when models change.
- `dart format lib test example` — apply the standard code style prior to committing.
- `flutter analyze` — run static analysis enforced by `flutter_lints`.
- `cd example && flutter run` — launch the showcase app to validate UI changes.

## Coding Style & Naming Conventions
Follow the defaults from `analysis_options.yaml`, which extends `flutter_lints` (two-space indentation, trailing commas to aid formatting). Use `PascalCase` for widgets and providers, `camelCase` for fields and methods, and `snake_case.dart` for files. Keep Riverpod providers suffixed with `Provider`, and colocate companion themes, widgets, and controllers under matching subdirectories.

## Testing Guidelines
Use `flutter test` for unit and widget suites; group tests by feature (`group('ChatController', ...)`) and store files as `feature_test.dart`. Aim to cover streaming and error states with fake providers, and prefer pumping `ChatView` via `WidgetTester` for UI changes. Capture coverage locally with `flutter test --coverage` when touching core message flows.

## Commit & Pull Request Guidelines
The distributed package does not include commit history, so adopt Conventional Commits (for example `feat:`, `fix:`, `docs:`) written in imperative voice under 72 characters. Reference related issues, describe user-facing changes, and attach `example/` screenshots or screen recordings for UI work. Before requesting review, ensure formatting, analysis, tests, and the example app all pass without warnings.

## Security & Configuration Tips
Do not hardcode API secrets in the package; load them from the host app and keep secret files out of version control as enforced by `.gitignore`. When debugging providers, prefer using mock adapters rather than pointing to production endpoints.
