# Backend toolchain baseline

The initial Foundation pins the following baseline. Re-evaluate versions deliberately in a dependency-update change; do not use floating `latest` tags.

| Tool / package       | Pinned version | Purpose                                                                          |
| -------------------- | -------------: | -------------------------------------------------------------------------------- |
| Node.js              |        22.23.4 | Local and CI runtime (`.nvmrc`); Cloud Functions runtime major is Node 22        |
| npm                  |         10.9.2 | Independent package manager (`packageManager` in `package.json`)                 |
| Firebase CLI         |        15.37.0 | Local Firebase tooling; pinned as a development dependency                       |
| `firebase-functions` |          7.4.0 | Cloud Functions SDK (Gen 2 APIs are used when approved functions are introduced) |
| `firebase-admin`     |         14.5.1 | Trusted server-side Firebase access                                              |
| TypeScript           |          5.9.3 | Strict TypeScript compiler                                                       |
| Vitest               |          5.1.2 | Unit test runner                                                                 |
| ESLint               |         9.38.0 | Linting                                                                          |
| `typescript-eslint`  |         8.46.2 | TypeScript ESLint integration                                                    |
| Prettier             |          3.6.2 | Formatting                                                                       |

Node.js 22 is selected as the supported LTS runtime baseline, not Node.js 26 Preview. Firebase Admin SDK 14 requires Node.js 22 or newer. Firebase CLI 15.37.0 is the November 18, 2026 release.

The independent `package-lock.json` must be generated with the pinned npm version and committed. CI uses `npm ci`; it must not resolve dependencies without the lockfile.

References:

- https://docs.cloud.google.com/functions/docs/release-notes
- https://firebase.google.com/support/release-notes/cli
- https://firebase.google.com/support/release-notes/admin/node
- https://github.com/firebase/firebase-functions/releases
