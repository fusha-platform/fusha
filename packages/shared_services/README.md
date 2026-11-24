# Shared Services

Shared cross-feature services for the Fusha monorepo.

This package provides a dedicated location for services that are genuinely
shared across multiple features or applications.

## Responsibility

The package is responsible for:

- Hosting reusable cross-feature service abstractions and implementations.
- Providing shared service capabilities when multiple features need them.
- Exposing approved public APIs through `shared_services.dart`.

## Architecture Boundaries

The package must remain focused on shared service responsibilities.

The following do not belong here:

- Firebase-specific implementations, which belong in `firebase_backend`.
- Feature-specific services, which belong inside their respective features.
- UI components and widgets, which belong in `shared_widgets` or `design_system`.
- Business logic and domain-specific rules, which belong in their respective
  domain layers.

## Dependencies

No additional dependencies are introduced until an approved shared service
requires them.

## Structure

```text
lib/
├── shared_services.dart
└── src/
```

The `src/` directory contains internal implementations and supporting code.
Its structure will evolve as actual shared services are introduced.

## Public API

Consumers should import the package through:

```dart
import 'package:shared_services/shared_services.dart';
```

Internal implementation files must not be imported directly by other packages.

## Development Guidelines

- Add a service only when it has a genuine cross-feature reuse case.
- Keep feature-specific responsibilities within their owning features.
- Keep Firebase-specific code inside `firebase_backend`.
- Expose only intentionally public APIs through the barrel file.
- Add tests for actual service behavior when services are introduced.
