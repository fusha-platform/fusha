# Shared Models

Shared Models is a pure Dart package for models that are genuinely shared
across multiple Fusha packages or applications.

## Responsibilities

This package may contain:

- Shared value objects.
- Shared domain-level contracts represented as models.
- Models that have the same meaning and stable structure across multiple
  application boundaries.

## What Does Not Belong Here

Keep the following inside their owning feature or infrastructure packages:

- Feature-specific domain entities.
- Feature-specific data models.
- Firebase documents and serialization models.
- REST API request and response models.
- UI presentation models.
- Models shared only by coincidence or similar field names.

## Architecture Rules

1. This package must remain pure Dart.
2. Do not depend on Flutter or Firebase.
3. Do not depend on infrastructure or presentation packages.
4. Do not introduce a model unless at least two packages genuinely need
   the same model contract.
5. Prefer feature ownership over premature generalization.
6. Export only intentional public APIs through `shared_models.dart`.

## Adding a Shared Model

Before adding a model:

1. Identify the packages that need it.
2. Confirm that they share the same meaning and contract.
3. Confirm that the model is not owned by a specific feature.
4. Add focused unit tests.
5. Export the model through the package entry point.
