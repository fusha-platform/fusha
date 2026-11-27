# Fusha — Security Rules & Authorization Specification

**Document status:** Draft security design specification — not deployable Rules code  
**Product:** Fusha | فُسحة  
**Applies to:** Firestore, Cloud Storage, Cloud Functions access boundaries  
**Related sources:** `BACKEND_ARCHITECTURE.md`, `DATA_MODEL.md`, `API_CONTRACTS.md`, `OPEN_DECISIONS.md`

---

## 1. Purpose and Status

This document consolidates the security requirements already established by the Fusha backend architecture and data model. It defines the access-control model, protected data, policy matrix, and requirements for converting the design into Firebase Security Rules.

**This is not a production-ready `firestore.rules` or `storage.rules` file.** The current Data Model explicitly describes a proposed Firestore structure, and several entity schemas, permission names, public/private field boundaries, and storage paths remain unresolved. Writing deployable rules before those decisions are approved would require inventing security behavior.

The default policy is **deny unless an explicit access path is defined and tested**.

## 2. Security Principles

1. Firebase Authentication establishes identity; it does not grant business permissions.
2. The backend obtains the caller UID from trusted Firebase request context. A client-supplied `userId` is never proof of identity.
3. Authorization is evaluated for every sensitive operation and resource.
4. Platform roles and provider memberships are separate authorization dimensions.
5. A Business or Organizer membership never grants platform Admin or Super Admin privileges.
6. Provider access requires current membership, membership status, role, explicit permission, provider eligibility, resource ownership/scope, and target resource state.
7. Firebase custom claims may be a coarse authorization hint, but mutable memberships and high-impact platform roles must be checked against authoritative backend data.
8. App Check reduces requests from unauthorized application instances; it is not Authentication or Authorization.
9. Firestore and Storage Rules default to deny.
10. Cloud Functions using the Firebase Admin SDK bypass Firestore Rules. Every server operation must enforce authorization and validation itself.
11. Clients must never write protected business state directly.
12. Sensitive and high-privilege accounts require MFA. The exact enforcement and recovery policy remains open.

## 3. Principals and Authorization Context

### 3.1 Principal Types

The product and backend documents identify these actor types:

- Guest
- Customer
- Business Owner
- Organizer
- Staff
- Admin
- Super Admin
- Trusted backend worker / system actor

These are not all mutually exclusive roles. A user may be a Customer and also hold one or more provider memberships. Provider membership must not be stored as a global platform role.

### 3.2 Required Authorization Inputs

For each protected request, the backend must establish:

- Verified authenticated UID, or a defined trusted system identity for background processing.
- Current User account status.
- Current platform role where platform-level access is required.
- Current BusinessMembership or OrganizerMembership where provider access is required.
- Explicit permission for the requested operation.
- Resource ownership and provider scope.
- Provider approval/suspension state.
- Target resource state and applicable business policy.
- MFA satisfaction for sensitive/high-privilege operations, once enforcement policy is finalized.
- App Check result where App Check is required for that endpoint.

A client-provided role, permission list, provider ID, owner ID, or account status must not be trusted without backend verification.

## 4. Role and Membership Boundaries

| Authorization dimension | Source represented in the model | Security requirement |
|---|---|---|
| User identity | Firebase Authentication UID and `users/{userId}` | Resolve UID from trusted auth context; verify account status |
| Platform role | PlatformRole concept / protected role records or claims | Server-managed only; authoritative current state for privileged actions |
| Business access | `BusinessMembership` | Verify current membership, status, role, explicit permission, and Business scope |
| Organizer access | `OrganizerMembership` | Verify current membership, status, role, explicit permission, and Organizer scope |
| Provider eligibility | Business / Organizer `approvalStatus` | Pending, Rejected, or Suspended providers must not perform restricted publishing/booking operations |
| Resource scope | Resource provider association and ownership | Verify the target resource belongs to the authorized provider |
| Trusted worker | Backend execution identity | Internal-only; no client-callable path for worker-only operations |

### 4.1 Membership Status

BusinessMembership statuses currently defined:

- `Pending`
- `Active`
- `Suspended`
- `Revoked`

Only an `Active` membership may be considered for normal provider access, and it still requires the relevant permission and scope checks.

OrganizerMembership has a `status` field, but its exact status enumeration is not separately defined in the Data Model. Do not assume a finalized enum until this is resolved.

### 4.2 Ownership Ambiguity

The Business model contains `ownerUserId`, while BusinessMembership also supports role `Owner`. The authoritative ownership source and synchronization invariant are unresolved. Until decided, authorization must not grant or preserve Owner-level access based on either field alone when they disagree. Treat a mismatch as a controlled authorization/data-integrity issue.

### 4.3 Platform Administration

- Admin and Super Admin are platform-level roles.
- Provider memberships never imply platform administration.
- Admin and Super Admin permissions must be separately protected.
- Clients cannot assign or elevate platform roles.
- High-impact administrative operations must check current authoritative role and account status, not only potentially stale custom claims.
- Role assignment must be performed only by trusted administrative backend operations.
- The bootstrap process for the first Super Admin and the exact Admin-to-Admin role delegation policy remain unresolved.

## 5. Access Policy Matrix

The matrix below records the access intent supported by the source documents. It is not a complete allowlist of direct Firestore operations.

| Resource / operation | Guest | Customer | Provider member | Admin / Super Admin | Client direct write |
|---|---|---|---|---|---|
| Published public Activities | Read public fields | Read public fields | Read public fields | Read/manage as authorized | No status or protected-field writes |
| Public categories | Read | Read | Read | Manage through trusted/admin-authorized path | No direct write until explicitly allowed |
| Public Business / Organizer profile | Read public fields | Read public fields | Read within authorized scope | Read/manage as authorized | No approval or ownership writes |
| Public schedules / availability projection | Read public projection | Read public projection | Read within authorized scope | Read/manage as authorized | No capacity-counter writes |
| Own private Booking information | No | Read own records | Only when authorized by provider scope | Platform access according to permission | No Booking lifecycle writes |
| Own Tickets | No | Read own Tickets | Only for authorized operational need | Platform access according to permission | No Ticket validity writes |
| Provider-owned Activities / schedules | No | No | Read/manage within membership permission and scope | Platform access according to permission | Only a future explicit editable-field allowlist |
| Provider memberships | No | No | No general direct read; only explicitly authorized membership operations | Manage through protected backend operations | No role/permission/status writes |
| Provider applications and verification documents | No | Applicant access only after an explicit applicant-read policy is approved | Only if explicitly authorized | Authorized review access | No approval or document-visibility elevation |
| Booking / capacity transitions | No | Through authenticated commands for own Booking | Through authorized provider commands | Through authorized admin commands | Prohibited |
| Ticket validation / check-in | No | No, unless a separate approved customer feature exists | Authorized staff operation only | Authorized platform operation | Prohibited |
| Attendance finalization | No | No | No direct execution | No direct client execution | Prohibited; trusted worker only |
| Audit logs | No | No | No general direct access | Read according to protected audit permission | Prohibited |
| Platform roles / permissions | No | No | No | Trusted role-management policy only | Prohibited |

**Important:** “Read public fields” requires a storage design that does not expose private fields in the same readable Firestore document. Firestore Rules authorize document access; they are not a mechanism for returning only selected fields from a document. If a document combines public profile fields with private contact, verification, or operational data, use a separately designed public projection or a trusted query endpoint. The exact projection model is an open storage decision.

## 6. Protected Fields and Server-Owned State

The following fields and records are server-owned and must not be writable by untrusted clients:

- Platform role assignments and administrative permissions.
- Provider approval and suspension status.
- Activity review, approval, publication, suspension, and moderation state.
- Booking status and lifecycle timestamps.
- Payment status and financial state.
- Schedule capacity counters (`confirmedQuantity`, `heldQuantity`).
- CapacityReservation state and transition timestamps.
- Ticket validity, usage, and expiration state.
- CheckIn records.
- BookingParticipant attendance state and check-in metadata.
- Booking attendance counters.
- Booking attendance finalization state, claim ID, lease, and finalization timestamps.
- GroupCheckInOperation progress and counters.
- IdempotencyRecord claims, leases, terminal results, and retention metadata.
- Audit logs.
- Notification delivery state where it reflects backend delivery processing.

Client-side validation is not a security boundary.

## 7. Firestore Rules Design Requirements

### 7.1 Default Deny

Rules must deny reads and writes unless a specific collection/document access policy has been explicitly approved.

Do not create broad authenticated-user read access to a collection merely because its documents contain marketplace data.

### 7.2 Query Compatibility

Every direct Firestore query must be designed together with its Rules predicate. A query that could return documents outside the caller's authorized scope must be rejected by Rules; the application must not assume Rules will silently filter unauthorized documents.

### 7.3 Public Data

The architecture identifies these potential public read categories, subject to explicit data visibility rules:

- Published public Activities.
- Public categories.
- Public Business and Organizer profiles.
- Public ActivitySchedules and availability projections.

Only non-sensitive public representations may be exposed. Public visibility must not expose provider verification documents, private contact details, internal review notes, member lists, customer data, or internal moderation metadata.

### 7.4 Customer-Owned Data

Customer access must be scoped to the authenticated UID and the relevant ownership relationship. The backend must not trust a client-supplied customer ID to establish ownership.

The exact read scope for BookingParticipants, Tickets, CheckIns, and booking-level QR references must be defined before Rules are finalized. QR tokens and other bearer credentials must not be exposed through broad collection reads.

### 7.5 Provider-Owned Data

Provider access must validate the membership relationship and the exact provider resource scope. A membership in one Business or Organizer must not authorize access to another provider's resources.

Organizer-Business association does not automatically grant cross-provider access.

The exact role-to-permission vocabulary and direct read/write matrix are unresolved and must be approved before implementation.

### 7.6 Protected State

Direct client writes to protected fields are prohibited even when the client can read the containing document. Prefer trusted Cloud Functions for state transitions.

Where limited client-owned writes are eventually approved, Rules must use an explicit affected-field allowlist and validate immutable ownership fields. No such general allowlist is currently defined by the source documents.

### 7.7 Admin SDK

Firestore Rules do not protect writes performed by the Firebase Admin SDK. Every Cloud Function and scheduled worker must independently enforce:

- Caller identity or trusted worker identity.
- Current authorization state.
- Resource ownership and scope.
- Valid state transition.
- Input validation.
- Idempotency and transaction integrity.
- Audit requirements.

## 8. Cloud Storage Security Design

### 8.1 File Classes

The architecture identifies at least two broad classes:

1. Public marketplace media: Business/Organizer images and Activity images approved for public display.
2. Private provider verification documents: restricted documents submitted during onboarding or review.

These classes must have separate access policies. Private verification documents must never be publicly readable.

### 8.2 Required Controls

Storage Rules and upload workflows must enforce, as applicable:

- Authentication.
- Provider ownership or membership authorization.
- File classification and intended visibility.
- Maximum file size.
- Allowed content types.
- Upload path ownership.
- No client ability to overwrite approved/public assets outside an authorized workflow.
- Restricted access to verification documents.
- Backend validation of file metadata and content where required.

Do not trust file extensions or client-supplied content types alone. A shared download URL must not be treated as proof that a private file is safe to expose.

### 8.3 Unresolved Storage Details

Exact bucket path conventions, filename strategy, upload authorization flow, file size/type limits, malware/content inspection, download URL strategy, retention, and deletion behavior remain open. Do not invent paths in deployed Rules.

## 9. Authentication, App Check, MFA, and Abuse Controls

- Firebase Authentication verifies identity.
- App Check helps establish that a request originates from an attested application instance; it does not establish user permissions.
- Sensitive and high-privilege accounts require MFA.
- The exact MFA enrollment, enforcement, step-up, recovery, and exception policies remain open.
- The exact App Check enforcement matrix by Callable Function, HTTPS endpoint, and direct SDK access remains open.
- Rate limits, abuse thresholds, request quotas, and account lockout behavior must be designed before public launch.
- A user account marked `Suspended` or `Disabled` must not be treated as an ordinary active account. The precise effect on existing tokens, sessions, reads, and recovery flows must be specified.

## 10. Audit and Privacy

Sensitive actions must create audit records with actor, action, target, relevant previous/new state where appropriate, timestamp, request/correlation identifier, and result.

Audit records must not be directly writable or editable by ordinary clients. Avoid copying secrets, QR tokens, credentials, full payment data, or unnecessary personal data into audit metadata.

The following require explicit policy before production:

- Audit retention and access.
- User data retention and deletion.
- Provider application document retention.
- Customer personal-data access and export.
- Data residency and country-specific privacy obligations.
- Backup, restore, and incident-response access.

## 11. Security Test Requirements

Use Firebase Emulator Suite and automated tests to verify at minimum:

1. Unauthenticated reads and writes are denied by default.
2. Guest reads are limited to approved public representations.
3. Customer A cannot read Customer B's private Booking, Ticket, or participant information.
4. A provider member cannot access another provider's resources.
5. Pending, Suspended, or Revoked memberships do not grant normal provider access.
6. Business membership does not grant Organizer access unless an explicit relationship and permission policy authorizes it.
7. Organizer membership does not grant Business access automatically.
8. Provider membership never grants Admin or Super Admin access.
9. Client attempts to change platform roles, provider approval, publication status, Booking state, payment state, capacity, Ticket state, attendance, finalization claims, idempotency claims, or audit logs are denied.
10. Public reads cannot expose private fields accidentally.
11. Private verification documents cannot be read by guests or unrelated providers.
12. Storage uploads violating approved size/type/path policies are denied.
13. Admin SDK-backed functions reject unauthorized callers independently of Rules.
14. High-privilege operations enforce the finalized MFA policy.
15. Queries that exceed a caller's authorized scope fail rather than returning mixed-scope data.

## 12. Decisions Required Before Rules Can Be Deployed

See `OPEN_DECISIONS.md`. The blocking items include:

- Exact Firestore paths and schemas for PlatformRole, Permission, OrganizerBusinessLink, and ActivityReview.
- Owner authority between `Business.ownerUserId` and Owner membership.
- OrganizerMembership role/status enumeration.
- Complete role-to-permission matrix.
- Public/private field projections.
- Direct client-write allowlist, if any.
- Exact Storage paths and file constraints.
- Admin/Super Admin permission separation and bootstrap.
- MFA and App Check enforcement policies.
- Retention, deletion, and audit access policies.

## 13. Implementation Readiness

**Current status: Design-ready for review; not deployable.**

The security principles and protected-state boundaries are sufficiently defined to guide backend design. Production Firestore Rules and Storage Rules must not be authored from this document alone until the open decisions are resolved, exact paths and fields are frozen, and emulator tests pass.
