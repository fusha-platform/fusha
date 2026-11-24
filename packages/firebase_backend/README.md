# Firebase Backend

Firebase infrastructure and integrations for Fusha applications.

This package isolates Firebase-specific implementations from application
features and provides a shared entry point for Firebase initialization,
service instances, and exception mapping.

## Responsibility

The `firebase_backend` package owns Firebase infrastructure used across
Fusha applications.

Its responsibilities include:

- Initializing the default Firebase application.
- Providing access to Firebase service instances.
- Mapping Firebase exceptions to application-level failures from `app_core`.
- Keeping Firebase-specific dependencies and implementations outside
  feature packages.

## Architecture Boundaries

### What belongs here?

- Firebase initialization.
- Firebase service instances.
- Firebase-specific infrastructure and integrations.
- Firebase exception handling and failure mapping.

### What does not belong here?

- Feature-specific repositories and business rules.
- Feature entities and domain models.
- UI components and application screens.
- Feature-specific BLoCs and Cubits.
- Generated Firebase configuration belonging to individual applications.

Feature repositories should remain inside their owning feature packages.
They may depend on this package for Firebase infrastructure while keeping
their domain contracts independent of Firebase.

## Firebase Configuration

Each consuming application is responsible for providing its generated
`firebase_options.dart` configuration.

The generated configuration must not be placed inside this package.

Initialize Firebase before accessing Firebase services:

```dart
import 'package:firebase_backend/firebase_backend.dart';
import 'package:flutter/widgets.dart';
import 'package:your_app/firebase_options.dart';

Future<void> main() async {
  await FirebaseInitializer.initialize(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
```

`FirebaseInitializer` initializes the default Firebase application.

## Firebase Service Instances

Use `FirebaseInstances` to access the default application's Firebase
services:

```dart
final firebase = FirebaseInstances();

final auth = firebase.auth;
final firestore = firebase.firestore;
final storage = firebase.storage;
final messaging = firebase.messaging;
```

All services exposed by this container are associated with the default
Firebase application.

Firebase Messaging currently supports the default application only in the
installed SDK version. The package does not expose a multi-app abstraction.

## Failure Mapping

Convert Firebase exceptions into application-level failures:

```dart
import 'package:firebase_backend/firebase_backend.dart';
import 'package:firebase_core/firebase_core.dart';

try {
  // Firebase operation.
} on FirebaseException catch (exception) {
  final failure = FirebaseFailureMapper.fromException(exception);

  // Handle the application-level failure.
}
```

The mapper supports the failure types provided by `app_core`:

- `NetworkFailure`
- `UnauthorizedFailure`
- `ValidationFailure`
- `ServerFailure`
- `UnknownFailure`

The original Firebase error code is preserved in `Failure.code`.

## Public API

Import the package through its public entry point:

```dart
import 'package:firebase_backend/firebase_backend.dart';
```

Implementation files remain under `lib/src/` and should only be exposed
through the public entry point when intended for package consumers.

## Dependencies

This package depends on:

- Flutter.
- `app_core`.
- Firebase Core.
- Firebase Authentication.
- Cloud Firestore.
- Firebase Storage.
- Firebase Messaging.

Additional dependencies should only be introduced when required by an
actual infrastructure implementation.

## Development Guidelines

- Keep Firebase-specific code inside this package.
- Keep feature-specific repositories inside their owning features.
- Keep domain contracts independent of Firebase.
- Do not expose implementation details unnecessarily.
- Add tests for actual infrastructure behavior.
- Avoid introducing abstractions for capabilities that are not currently
  required or supported.