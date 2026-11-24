# Shared Widgets

A shared Flutter package for reusable, cross-feature UI widgets used across Fusha applications.

## Responsibility

The `shared_widgets` package contains reusable, composed UI widgets that are generic enough to be shared across multiple features or applications.

It builds on the visual foundations and components provided by `design_system` instead of duplicating them.

## Architecture Boundaries

### What belongs here?

- Reusable UI widgets shared across multiple features.
- Generic composed widgets built using `design_system`.
- UI components that do not depend on a specific feature or business domain.
- General UI states only when they are genuinely reusable across applications.

### What does not belong here?

- Design foundations such as colors, typography, spacing, and base components. These belong in `design_system`.
- Feature-specific widgets such as `ActivityCard` or `BookingCard`. These belong in their respective feature packages.
- Business logic, application state management, or feature-specific BLoCs and Cubits.
- Backend implementations, API clients, or Firebase services.
- Widgets that are used by only one feature without a clear cross-feature reuse requirement.

## Package Structure

The package starts with a minimal structure and grows only when actual shared widgets are introduced.

```text
shared_widgets/
|-- lib/
|   -- shared_widgets.dart
|-- pubspec.yaml
|-- analysis_options.yaml
|-- README.md
|-- CHANGELOG.md
|-- LICENSE
|-- .gitignore


```

Directories and files under `src/` and `test/` should be added when needed. Empty placeholder directories and files should not be created.

## Usage

Import the package through its public entry point:

```dart
import 'package:shared_widgets/shared_widgets.dart';
```

The `shared_widgets.dart` file is the package's public API boundary.

Implementation files should remain inside `lib/src/` and should only be exposed through the public entry point when they are intended for package consumers.

## Design System Integration

When a shared widget requires design foundations or components, it should depend on `design_system` and reuse its existing APIs.

Do not duplicate design tokens, base components, or styling utilities.

Add the dependency only when the first actual widget requires it.

## Development Guidelines

Before adding a widget, verify that:

1. It is reusable across multiple features or applications.
2. It does not belong to a specific feature or business domain.
3. Existing `design_system` components can be reused instead of duplicated.
4. It does not introduce unnecessary dependencies or business logic.
5. Its public API is exposed intentionally through `shared_widgets.dart`.

Add tests alongside actual widget implementations. Do not add placeholder widgets or tests without real behavior to verify.

## Dependencies

The package currently depends only on Flutter.

Additional dependencies should be introduced only when a real implementation requires them.
