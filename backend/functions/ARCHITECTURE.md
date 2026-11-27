# Backend Functions Foundation

## Runtime and workspace

This is an independent Node.js workspace. Dart Workspace and Melos continue to own Flutter applications and Dart packages. The trusted backend uses Firebase Admin SDK and Firebase Functions SDK; it must not depend on Firebase Client SDK packages from `packages/firebase_backend`.

## Module boundaries

A future module is organized under `src/modules/<module>/` with `domain`, `application`, `infrastructure`, and `presentation` boundaries. The dependency direction is inward: Presentation -> Application -> Domain. Infrastructure implements ports declared by inner layers. Domain code has no Firebase, transport, or other infrastructure imports.

Cross-module collaboration is limited to approved application interfaces, events, and read models. Private repositories and infrastructure adapters are not cross-module APIs.

## Shared kernel

`src/shared/kernel` contains only generic primitives that are genuinely shared. It must not become a home for business entities, module policies, or speculative frameworks.

## Firebase Admin boundary

`src/infrastructure/firebase/admin-app.ts` is the only initialization boundary for the Firebase Admin app in this Foundation. Initialization is lazy and idempotent. Do not initialize Firebase Admin at module import time, and do not add production project identifiers or credentials here.

## Function exports and data contracts

`src/index.ts` intentionally exports no Cloud Functions. Do not add commercial Function exports, Firestore collections/paths, domain schemas, or external API contracts until their owning decisions and gates are approved. Firebase CLI configuration remains at the repository level and is intentionally not created in this stage.

## Completion checks

A change must pass formatting, linting, TypeScript strict type-checking, unit tests, and production build. Sensitive future operations additionally require authorization, emulator, concurrency, idempotency, and recovery tests appropriate to their contracts.
