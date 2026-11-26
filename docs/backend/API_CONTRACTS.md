# Fusha — Backend API & Application Contracts

**Document status:** Draft operation catalogue and contract requirements — wire contracts not frozen  
**Product:** Fusha | فُسحة  
**Default transport:** Firebase Callable Functions for authenticated application commands  
**Additional transport:** HTTPS Functions where a conventional HTTP interface is appropriate  
**Related sources:** `BACKEND_ARCHITECTURE.md`, `DATA_MODEL.md`, `SECURITY_RULES.md`, `OPEN_DECISIONS.md`

---

## 1. Purpose and Contract Status

This document organizes the backend operations already named or described in the Fusha architecture and data model. It defines the contract requirements each operation must satisfy and records which operations are client commands versus internal trusted operations.

**Operation names in this document are logical application/use-case names, not finalized exported Firebase Function names.** Exact Callable names, HTTPS routes, request payloads, response DTOs, and stable error-code strings are not yet approved. They must not be inferred from the examples.

The domain and application layers must remain independent of Firebase Callable request/response types. The access layer maps transport payloads into application commands and maps application results into stable transport responses.

The accepted API-R01 through API-R10 review principles refine this draft but do not freeze its external wire contracts. Logical operation names remain use-case labels, not deployment/export names. Each owning module controls its business contract and validation rules.

## 2. Transport Strategy

### 2.1 Callable Functions

Callable Functions are the default interface for authenticated Flutter application commands. Firebase-aware request context provides the authenticated identity context, but does not replace:

- Input validation.
- App Check enforcement where required.
- Authorization.
- Business rule enforcement.
- Idempotency.
- Transactional integrity.
- Audit requirements.

Every callable operation must independently enforce its authorization requirements.

Callable is a default transport choice, not a universal execution mechanism. Internal Application Operations and trusted workers/scheduled triggers do not require Callable entry points. The transport is selected per external operation and must not leak into Domain or Application Use Cases. A verified identity does not imply authorization.

### 2.2 HTTPS Functions

HTTPS Functions may be used for:

- External provider webhooks.
- Third-party integrations.
- Public endpoints with explicitly designed HTTP contracts.
- Future REST API compatibility endpoints.

External requests require an appropriate authentication or signature-verification mechanism. Internal application operations must not be exposed as unauthenticated HTTP endpoints.

HTTPS is not a way to bypass application authorization. Webhook authentication/signature verification is distinct from end-user Firebase Authentication and must be explicitly defined for each integration.

### 2.3 Direct Firebase SDK Access

Direct Firestore SDK access is limited to reads and any explicitly approved client-owned operations protected by Security Rules. The examples of public and owner-scoped reads in `BACKEND_ARCHITECTURE.md` are conditional on approved visibility and ownership rules.

No general direct-write allowlist is currently defined. Protected business state must be changed through trusted backend operations.

## 3. Common Request Requirements

Every operation contract must explicitly define:

1. Logical operation name and eventual transport/export name.
2. Caller class and authentication requirement.
3. App Check requirement, if applicable.
4. Authorization policy and required provider/resource scope.
5. Input schema, required fields, optional fields, types, bounds, and validation.
6. Whether the operation is read-only, transactional, or long-running.
7. Idempotency scope and replay behavior.
8. Transaction boundary and state invariants.
9. Success response schema.
10. Stable error categories/codes.
11. Retry behavior and whether the client may safely retry.
12. Audit and notification/outbox behavior.
13. Rate limit and operational constraints.
14. Versioning and backward-compatibility policy.

### 3.1 Identity, Actor, Provider Context, and Resource Scope

The backend derives the caller's UID from trusted authentication context. A client-provided `userId`, role, membership, permission list, account status, provider owner field, or other identity/authority claim is not authoritative.

Treat every client-supplied identifier as an untrusted reference, not proof of access. This includes provider identifiers such as `businessId` and `organizerId`, and resource identifiers such as `bookingId` and `activityId`. The backend must resolve the target resource and verify its actual provider/owner relationship and the caller's current authority over that scope.

Keep these concepts distinct:

- **Actor:** the authenticated user or trusted system/worker executing the operation.
- **Provider Context:** the provider scope the user selected or intends to act within; it is a context hint, not a permission grant.
- **Resource Scope:** the authoritative scope of the actual target resource, resolved and checked by the backend.

A user authorized in Business A must not gain access to Business B by substituting a client-supplied provider or resource ID. The backend checks current account state, membership status, permission, resource relationship, and operation-specific policy. Where the provider context can safely be derived from the resource, the client need not send a redundant context identifier; server-side derivation must still enforce authorization. Every sensitive operation independently enforces its authorization boundary.

### 3.2 Idempotency and Retry Classes

Every client-submitted state-changing Booking command must include an idempotency key. Other state-changing commands must define whether client idempotency is required according to their business effects and retry behavior. The backend derives actor identity from trusted context, never from a client-supplied `userId`.

Distinguish three retry mechanisms:

- **Client Retry:** the client resends the same logical command. Client Idempotency Key and replay rules apply.
- **Transaction Retry:** Firestore may rerun a transaction callback after contention. Transaction code must be retry-safe and free of external side effects; a client key does not replace this requirement.
- **Worker Retry:** an Outbox/worker execution may process the same durable event more than once. Worker/Event identity and idempotent effect handling apply independently of the client's idempotency key.

For client idempotency:

- The server derives the record identity from the authenticated actor, logical operation, and client key within the approved scope.
- The backend hashes normalized contract-approved payload fields, not raw JSON serialization whose property order or representation may vary.
- Same scoped key + same normalized payload returns the original logical result.
- Same scoped key + different normalized payload returns an idempotency conflict.
- The idempotency record and transactional business result commit atomically whenever the business operation is transactional.
- A transient infrastructure failure must not be stored as a terminal business failure.
- Expiration/cleanup of an idempotency record must never reverse a committed business operation or permit duplicate consequential effects.

For long-running group check-in, replay returns the same durable `GroupCheckInOperation` reference. Its persisted status tracks processing independently of the original command result. Worker/Event identity is not the same as the Client Idempotency Key.

The exact key format, retention duration, cleanup policy, and per-operation requirements remain open.

### 3.3 Transaction Boundaries, Events, and Outbox

Transaction boundaries are owned by the Application Use Case and are determined by the invariants that require atomicity. Not every use case requires a Firestore transaction; do not add transactions mechanically. When a transaction is required:

- Complete all required reads before the first write.
- Revalidate current persisted states inside the transaction.
- Use trusted backend time for expiration and attendance decisions.
- Protect all related state transitions and counters atomically.
- Keep transaction callbacks free of external side effects and do not rely on callback-local variables to record an effect that may be repeated or rolled back.
- Assume transaction callbacks may be retried.

Distinguish the following:

- **Business Event:** a fact representing a committed business state change.
- **Outbox Record:** durable work persisted transactionally when reliable follow-up processing is required.
- **Worker Execution:** one processing attempt for an Outbox item/event; it may be retried.
- **External Delivery:** sending FCM, email, webhook, or invoking an external provider.

A successful business transaction does not imply successful external delivery. Persist required Outbox work with the business commit, then execute delivery after commit through restartable/recoverable workers. Worker/Event identity and duplicate-effect protection are separate from client request idempotency. Do not send FCM, email, invoke payment providers, or make unrelated HTTP requests inside transaction callbacks.

### 3.4 Cross-Cutting Contract Ownership

- Each owning module defines and maintains the business contract and validation rules for its operations.
- Shared validation primitives may be reused, but shared infrastructure must not become the owner of every domain's business rules.
- Each operation receives least-privilege authorization and only the resource scope it requires.
- Commands document their business side effects and any asynchronous/external follow-up effects explicitly.
- Client-supplied role, status, price, ownership, identity, and context never substitute for server-side authority.
- The future per-operation contract review must account for logical name/type, entry point/transport, owning module, authentication/authorization, provider context/resource scope, request/response validation, error categories, idempotency, transaction boundary, events/outbox effects, operational limits, and tests. This checklist does not define concrete fields or freeze schemas.

## 4. Logical Operation Catalogue

The table below records application operations explicitly named or described in the source documents. It does not freeze their external API names.

| Logical operation | Caller / execution | Authorization boundary | Core invariants |
|---|---|---|---|
| `createRequestBooking` | Authenticated Customer command | Caller is the customer creating their own Booking | Validate Activity/Schedule, quantity, idempotency and capacity; create Pending Booking + Active hold atomically |
| `createInstantBooking` | Authenticated Customer command | Caller is the customer creating their own Booking | Validate Activity/Schedule and capacity; create Confirmed Booking and allocate confirmed capacity atomically; no CapacityReservation |
| `approveBooking` | Authenticated provider command | Current provider membership and approval permission; Booking belongs to provider scope | Convert only an Active, unexpired hold; update Booking, reservation, Schedule, participant set and counters atomically |
| `rejectBooking` | Authenticated provider command | Current provider membership and rejection permission; Booking belongs to provider scope | Release active hold once; if already expired, expire rather than reject; detect inconsistent states |
| `cancelBooking` | Authenticated customer or other explicitly authorized actor | Verify actor's cancellation authority and applicable cancellation policy | Distinguish Pending/Confirmed, Request/Instant, and reservation state; release capacity exactly once only when permitted |
| `approveProvider` | Administrative command | Current platform role, account status and administrative permission | Apply provider approval transition; audit result |
| `approveActivity` | Administrative command | Current platform role and activity-review permission | Review the submitted revision; do not bypass provider eligibility |
| `publishActivity` | Administrative command in the current operation catalogue | Current publishing authority and resource scope | Publish only through publishing workflow after provider and Activity approval checks |
| `suspendActivity` | Administrative command | Current moderation authority | Apply approved suspension policy and audit |
| `assignPlatformRole` | Administrative command | Trusted role-assignment policy | Server-only role assignment; never accept client self-elevation |
| `submitProviderApplication` | Applicant command described by the data model | Authenticated applicant and allowed onboarding flow | Validate application data and restricted document references; exact create/link workflow remains open |
| `submitActivityForReview` | Authorized provider command | Current provider membership, active provider eligibility, submit permission | Submit a revision without replacing the currently published revision prematurely |
| `createActivitySchedule` | Authorized provider command | Current provider scope and schedule-management permission | Validate schedule and capacity policy; exact schedule constraints remain to be specified |
| `reserveCapacity` | Internal booking/scheduling application operation | Invoked only as part of an authorized booking flow | Reconcile expired holds and update Schedule counters transactionally |
| `confirmRequestBooking` | Internal domain step within `approveBooking`; not a separate endpoint by default | Provider approval authority | Convert a valid active hold exactly once |
| `expireCapacityReservation` | Trusted scheduled/background operation | Trusted worker identity only | Expire only Active and expired reservations; update Booking and Schedule atomically |
| `issueTickets` / `generateTickets` | Internal application operation | Invoked after the applicable Booking confirmation conditions | Issue required booking-level and/or participant Tickets according to Activity policy |
| `validateTicket` | Authenticated staff/client command as authorized by the ticket workflow | Verify staff identity, provider scope, Ticket token and associated Booking/Activity/Schedule | Exact response and whether validation has any side effect must be defined; validation must not be confused with check-in |
| `checkInTicket` | Authenticated authorized staff command | Current membership, check-in permission, Ticket/Booking scope | Validate token, Ticket state, attendance window, Booking and participant; commit successful check-in atomically |
| `checkInParticipant` / `CheckInParticipant` | Authenticated authorized staff application command | Exact participant belongs to Booking; staff has check-in permission | First transition only; update participant, Booking counter, Ticket, CheckIn, audit and idempotency state atomically |
| `checkInParticipants` / `CheckInParticipants` | Authenticated authorized staff application command | Explicit group-check-in permission and exact selected participant set | Durable GroupCheckInOperation for two or more unique participants; resumable, idempotent progress |
| `recordParticipantAttendance` | Authorized application operation | Explicit attendance permission and policy | Record only an allowed participant attendance transition; no client direct write |
| `finalizeBookingAttendance` | Trusted scheduled/background operation | Trusted worker identity only | Claim/lease/fencing protocol; bounded participant batches; preserve CheckedIn/NoShow; finalize only complete stable set |
| `markParticipantNoShow` | Internal finalization step | Trusted finalization worker only | Only after attendance window closes and under current claim; never overwrite CheckedIn |
| `recordAuditEvent` | Internal module operation | Called by the owning trusted use case | Audit record commits with the sensitive business transaction where required |

**Note:** Some rows describe internal application operations, not separate public endpoints. The final API surface may expose fewer transport operations than the logical catalogue.

The catalogue distinguishes logical operations from external entry points and trusted execution triggers. For example, an external entry point may invoke an Application Use Case that calls internal operations; an Outbox Worker may execute ticket issuance without exposing it as a client-callable Function. Cross-module calls use approved Application interfaces, Domain Events, or Read Models, never another module's private repository for direct mutation.

## 5. Booking Contract Requirements

### 5.1 Request Booking Creation

The contract must define:

- Activity and Schedule reference.
- Requested booking quantity and unit.
- Required participant data according to Activity policy.
- Price and currency snapshot inputs/derivation.
- Client idempotency key.
- Any customer-provided booking options allowed by the policy.

The backend must derive customer identity from the auth context, validate Activity and Schedule eligibility, reconcile expired reservations, check available capacity, and atomically create:

- Booking with `Pending` status.
- CapacityReservation with `Active` status.
- Increased `heldQuantity`.
- Required idempotency result.
- Required notification/outbox record.

The default hold duration is 30 minutes and is configurable within platform-defined limits. The exact configuration schema and permitted limits remain open.

### 5.2 Instant Booking Creation

The contract must define the same applicable booking inputs but must not create a temporary CapacityReservation.

One server-side transaction must create a `Confirmed` Booking, finalize the eligible participant set when applicable, initialize attendance counters, and increase `confirmedQuantity`.

### 5.3 Provider Approval and Rejection

The backend must verify current provider membership, permission, provider scope, Booking state, CapacityReservation state, and expiration using trusted server time.

An expired Active hold must not be converted. Rejection after expiration must result in Booking `Expired`, not `Rejected`, and must release held capacity exactly once.

### 5.4 Cancellation

The contract must validate the cancellation policy and distinguish:

- Pending Request Booking with active unexpired hold.
- Pending Request Booking whose hold has expired.
- Confirmed Request Booking with Converted reservation.
- Confirmed Instant Booking without a CapacityReservation.
- Completed or NoShow Booking.
- Any prohibited cancellation window or state.

Completed and NoShow Bookings do not release capacity through ordinary cancellation or attendance finalization.

The exact cancellation and refund policy is not yet defined.

## 6. Check-in and Attendance Contract Requirements

### 6.1 Ticket Validation

The backend must validate the opaque token or secure reference, Ticket state, Booking eligibility, Activity/Schedule association, attendance window, and staff authorization before accepting a check-in.

QR data must not contain personal information or sensitive Booking details.

The API must distinguish validation from a successful attendance action. The exact validation response and whether a validation-only operation exists as a separate endpoint remain open.

### 6.2 Individual Participant Check-in

The operation must identify one participant and, when applicable, the Ticket used. A successful first transition from `NotCheckedIn` to `CheckedIn` must atomically:

- Update the participant attendance state and check-in metadata.
- Increment `checkedInParticipantCount` exactly once when participant-level counters apply.
- Update the associated Ticket according to its type.
- Create one CheckIn record.
- Create the corresponding audit record.
- Complete the relevant idempotency/progress state.

Repeated requests must not create duplicate CheckIn records or increment counters again.

### 6.3 Group Check-in

Every explicit request selecting two or more participants must create a durable `GroupCheckInOperation`, even when it can be completed in one transaction. A single participant uses the individual check-in use case.

The selected participant IDs must be unique, belong to the Booking, and be normalized deterministically for request hashing. The operation must persist participant progress and support retry/recovery without reprocessing successful participants.

A booking-level QR does not automatically check in all participants. Staff must explicitly select the participants or invoke the authorized group operation.

### 6.4 Attendance Finalization

`finalizeBookingAttendance` is internal and must never be directly callable by untrusted clients.

The worker must:

- Verify the Booking is Confirmed and the attendance window has closed.
- Acquire/reclaim a unique claim ID and lease transactionally.
- Coordinate with check-in through the parent Booking document.
- Process the complete eligible participant set in bounded deterministic batches.
- Verify claim ID and lease inside every batch transaction.
- Preserve existing `CheckedIn` and `NoShow` states.
- Convert eligible `NotCheckedIn` participants to `NoShow`.
- Perform a final complete-set verification.
- Commit Booking `Completed` or `NoShow`, `attendanceFinalizationStatus = Completed`, `attendanceFinalizedAt`, audit details, and cleared active claim fields only after successful verification.
- Never release confirmed capacity.

Lease durations and renewal intervals are configurable backend settings; no fixed numeric values are prescribed.

## 7. Stable Error Contract and Asynchronous Outcomes

The application contract uses stable error categories/codes independent of Firebase Callable errors, HTTP status codes, and localized message text. Transport adapters map application outcomes to the selected transport without making transport-specific codes the public application contract.

The following categories are already identified and must be mapped to stable application error codes during API finalization:

- Authentication failure.
- Authorization failure.
- Invalid input.
- Resource not found or not available to the caller (without leaking private resource existence).
- Invalid state transition / state conflict.
- Insufficient capacity.
- Expired reservation.
- Idempotency conflict.
- Concurrency or retryable transaction failure.
- Retryable capacity-processing or reconciliation backlog.
- Attendance window closed.
- Participant already checked in.
- Attendance already finalized.
- Attendance reconciliation required.
- Rate limiting.
- Internal unexpected failure.

Distinguish outcome classes:

- **Request Failure:** authentication, authorization, or validation prevents the request from being accepted.
- **Business Failure:** a business rule prevents the requested transition, such as insufficient capacity or invalid state.
- **Operational Failure:** infrastructure/concurrency/processing failure; retryability must be explicit and safe.
- **Accepted / Processing:** an asynchronous operation has been accepted and is pending. This is not necessarily an error or business failure; the response must make the pending state and operation reference clear where applicable.

Error responses must not expose stack traces, secrets, sensitive personal data, unnecessary internal Firestore paths, or private resource existence. Safe messages may be localized, while the stable application error code remains unchanged.

Exact error-code strings, Firebase/HTTP transport mapping, message localization, and retry metadata remain open.

## 8. Response Contract Requirements

Each operation must define:
 - A response schema that is validated/projected by the backend; output validation must prevent private, internal, or unauthorized fields from leaking.

- A typed success result with only the data required by the client.
- A stable error code and safe message for failure.
- Whether the result is terminal, retryable, or still processing.
- A correlation/request identifier where appropriate.
- Idempotent replay behavior.
- Pagination or continuation information for list operations, where applicable.

Do not place secrets, QR bearer tokens, credentials, or unnecessary personal data in replay snapshots or logs.

No common JSON envelope or exact response field names are approved yet. Do not invent one in implementation.

For asynchronous/long-running work, the contract must distinguish acceptance from completion and define how the client reads authoritative persisted progress. A conceptual list contract may need bounded items, an opaque continuation cursor, and a has-more indication, but these are not approved field names or a common response envelope.

## 9. API Versioning and Operational Limits

The following are not yet defined and must be resolved before the external API is frozen:

Versioning applies to published external contracts and their compatibility/deprecation policy; internal Application Use Cases do not require artificial API versioning.

- Function naming convention and API versioning strategy.
- Exact Callable versus HTTPS mapping for each operation.
- Request/response JSON schemas.
- Pagination conventions, deterministic ordering, opaque cursor representation, and page-size limits. Cursors must not bypass authorization or query scope.
- Request size limits and validation bounds.
- Rate limits and abuse controls.
- Retry/backoff policy and client timeout expectations.
- Group check-in worker parallelism and operational limits.
- Idempotency key format and retention duration.
- Stable error-code registry.
- Notification/outbox contract.
- External webhook signature and replay-protection details.
- Payment integration boundaries, if introduced in a later phase.

## 10. Contract Test Requirements

Before release, tests must cover:

1. Authentication and authorization for every operation.
2. Provider membership, permission, and resource-scope enforcement.
3. Account suspension/disable behavior.
4. Idempotency replay with the same payload.
5. Idempotency conflict with a different payload.
6. Duplicate booking and capacity prevention under concurrency.
7. Expiration racing with approval, rejection, and cancellation.
8. Instant Booking without CapacityReservation.
9. Request Booking conversion and release exactly once.
10. Protected state changes rejected from direct clients.
11. Ticket validation separated from check-in.
12. Repeated and concurrent participant check-in.
13. Group operation initialization, retry, partial failure, and recovery.
14. Check-in racing with finalization claim acquisition.
15. Stale finalization worker rejected after claim replacement or lease expiration.
16. Error mapping without leaking secrets or internal details.
17. Notification/outbox delivery after successful commit.
18. App Check and MFA enforcement according to the finalized policy.
19. Negative authorization tests that substitute `businessId`, `organizerId`, `bookingId`, `activityId`, or other resource identifiers to attempt cross-provider/resource access.
20. Backward-compatibility tests against externally published contracts and supported client versions, not only TypeScript interface comparisons.
21. Request and Response schema validation, including unknown-field behavior and output redaction/projection.
22. Worker retry and duplicate-event processing without duplicate business effects; correlation propagation across request, Use Case, Outbox, and Worker stages where applicable.

## 11. Implementation Readiness

**Current status: Logical operation catalogue ready for detailed contract design; external wire contracts not frozen.**

API-R01 through API-R10 architectural principles are accepted. The catalogue still requires an operation-by-operation audit to distinguish external entry points, internal Application Operations, and trusted worker/scheduled triggers; assign module ownership; and specify authorization/resource scope and side effects.

Do not generate production Callable/HTTPS exports or client DTOs from this document until the open decisions are resolved and each operation has an approved request schema, response schema, authorization rule, error mapping, idempotency policy, and test plan.
