# Fusha — Backend Architecture

**Document:** Backend Architecture
**Product:** Fusha | فُسحة
**Architecture Style:** Firebase-first Modular Monolith
**Backend Language:** TypeScript
**Server Runtime:** Firebase Cloud Functions Gen 2
**Primary Database:** Cloud Firestore
**Status:** Proposed Architecture
**Scope:** MVP and future evolution

---

## 1. Purpose

This document defines the backend architecture for Fusha, a Palestinian multi-vendor experiences and activities discovery and booking marketplace.

It translates the approved Product Requirements Document (PRD) and Data Model into a technical architecture that defines:

- Backend architectural style and boundaries.
- Application, domain, and infrastructure layers.
- Backend modules and their responsibilities.
- Flutter-to-backend communication.
- Firebase infrastructure responsibilities.
- Authentication, authorization, and data access boundaries.
- Booking lifecycle and capacity management architecture.
- Provider and activity approval workflows.
- Ticket issuance and check-in.
- Participant-level attendance tracking.
- Scheduled processing and notifications.
- Reliability, idempotency, concurrency, testing, and observability.
- Future migration boundaries.

This document defines architectural responsibilities and constraints. Detailed endpoint payloads and Firestore Security Rules belong in their respective documents. The Data Model is authoritative for entity fields and Firestore paths.

### 1.1 Source of Truth

The backend must remain consistent with:

- `docs/product/PRD.md`
- `docs/backend/DATA_MODEL.md`

The Data Model is the reference for domain entities, field definitions, relationships, and proposed Firestore document paths.

This document must not independently redefine those entities or introduce conflicting collection names.

When a technical implementation requires a change to an approved domain rule or data structure, the relevant source document must be reviewed and updated deliberately.

---

## 2. Architectural Decision

### 2.1 Selected Architecture

Fusha will use a **Firebase-first Modular Monolith**.

The backend is deployed as one logical application using Firebase Cloud Functions Gen 2. Internally, its business capabilities are separated into independent modules with explicit responsibilities and controlled dependencies.

The architecture is not based on independently deployed microservices.

### 2.2 Technology Decisions

| Concern | Decision |
|---|---|
| Architectural pattern | Modular Monolith |
| Backend platform | Firebase-first |
| Backend language | TypeScript |
| Server runtime | Cloud Functions Gen 2 |
| Runtime environment | Node.js LTS supported by the selected Firebase Functions SDK |
| Primary database | Cloud Firestore |
| Authentication | Firebase Authentication |
| File storage | Cloud Storage for Firebase |
| Push notifications | Firebase Cloud Messaging |
| Scheduled processing | Cloud Scheduler through scheduled Cloud Functions |
| Application validation | Server-side validation |
| Authorization | Server-side policies and authorization services |
| Client protection | Firebase App Check |
| Database access control | Firestore Security Rules |
| File access control | Cloud Storage Security Rules |
| Local integration testing | Firebase Emulator Suite |
| API interaction | Callable Functions and HTTPS Functions where appropriate |

The exact Node.js runtime and package versions must be pinned and verified during implementation. They must not be inferred from an outdated example.

### 2.3 Why a Modular Monolith?

A modular monolith provides:

- Clear domain ownership.
- Centralized enforcement of business rules.
- Atomic operations across related booking data.
- Simpler deployment and operational management.
- Lower infrastructure and maintenance overhead than microservices.
- A practical path to extract modules later if scale or organizational requirements justify it.

Modules are logical boundaries, not independently deployed services.

A module must not bypass another module's business rules by directly modifying its internal data.

### 2.4 Why Firebase-first?

Firebase provides the infrastructure needed for the MVP:

- Firebase Authentication for identity.
- Firestore for operational data.
- Cloud Functions for trusted business operations.
- Cloud Storage for uploaded files.
- FCM for notifications.
- Scheduled Functions for expiration and maintenance jobs.

Firebase is an infrastructure choice, not the definition of the business domain.

The domain and application layers must not depend directly on Firebase SDK classes.

---

## 3. High-Level Architecture

```text
+------------------------------------------------------+
|                 Flutter Applications                 |
|                                                      |
|       Customer Mobile       Management Dashboard     |
+-----------------------------+------------------------+
                              |
                              v
+------------------------------------------------------+
|                  Backend Access Layer                |
|                                                      |
| Authentication | App Check | Validation | Authorization|
|             Callable Functions / HTTPS              |
+------------------------------------------------------+
                              |
                              v
+------------------------------------------------------+
|                 Application Layer                    |
|                                                      |
| Commands | Queries | Use Cases | Application Services|
+------------------------------------------------------+
                              |
                              v
+------------------------------------------------------+
|                    Domain Layer                      |
|                                                      |
| Entities | Value Objects | Policies | State Rules    |
| Repository Interfaces | Domain Invariants            |
+------------------------------------------------------+
                              |
                              v
+------------------------------------------------------+
|               Infrastructure Adapters                |
|                                                      |
| Firestore | Auth | Storage | FCM | Scheduled Jobs     |
+------------------------------------------------------+
                              |
                              v
+------------------------------------------------------+
|                  Firebase Platform                   |
+------------------------------------------------------+
```

### 3.1 Architectural Layers

#### Access Layer

Responsible for receiving external requests and enforcing the request boundary.

Responsibilities:

- Authenticate the caller.
- Validate App Check where required.
- Parse and validate input.
- Resolve the caller's identity and relevant authorization context.
- Invoke the appropriate application use case.
- Map application results to stable API responses.
- Prevent infrastructure errors from leaking sensitive information.

It must not contain complex domain business rules.

#### Application Layer

Coordinates use cases and domain operations.

Responsibilities:

- Execute application workflows.
- Load the required domain state through repository interfaces.
- Invoke domain policies.
- Coordinate operations across modules through explicit interfaces.
- Define transaction boundaries through application ports.
- Return application-level results.

Examples:

- Create Request Booking.
- Create Instant Booking.
- Approve Booking.
- Reject Booking.
- Cancel Booking.
- Approve Provider.
- Approve Activity.
- Publish Activity.
- Check In Ticket.
- Record Participant Attendance.
- Finalize Booking Attendance.

#### Domain Layer

Contains business rules independent of Firebase.

Responsibilities:

- Define domain entities and value objects.
- Define valid state transitions.
- Enforce business invariants.
- Define booking and capacity policies.
- Define provider and activity approval rules.
- Define ticket and check-in rules.
- Define participant-level attendance rules.
- Define repository and service interfaces where needed.

The domain layer must not import:

- Firebase Admin SDK.
- Firebase Functions SDK.
- Firestore SDK types.
- HTTP framework types.
- Cloud Storage or FCM SDK types.

#### Infrastructure Layer

Implements the interfaces required by the application and domain layers.

Responsibilities:

- Firestore repositories.
- Transaction and persistence adapters.
- Firebase Authentication adapters.
- Cloud Storage adapters.
- FCM adapters.
- Scheduled processing adapters.
- External integration adapters.

Firebase-specific implementation details remain in this layer.

---

## 4. Backend Module Boundaries

Each module owns a specific business capability and the rules governing its state.

### 4.1 Module Overview

| Module | Responsibilities |
|---|---|
| `identity` | Users, platform roles, identity-related policies |
| `providers` | Businesses, branches, organizers, memberships, provider applications |
| `catalog` | Activities, categories, activity details and versions |
| `publishing` | Provider review, activity review, approval, publishing and suspension |
| `scheduling` | Activity schedules, schedule status and capacity policy |
| `bookings` | Booking creation, state transitions, cancellation and capacity reservations |
| `tickets` | Ticket issuance, QR token validation, Ticket validity and Ticket lifecycle rules |
| `attendance` | Check-in application use cases, participant attendance records, group check-in orchestration and Booking attendance finalization |
| `discovery` | Public discovery, search, filtering and favorites |
| `engagement` | Reviews, complaints and coupons when included in the MVP |
| `notifications` | Notification records, delivery requests and FCM |
| `administration` | Platform-level administrative use cases |
| `audit` | Audit records for sensitive operations |

### 4.2 Module Ownership

Each module owns the rules and application operations that change its domain state.

Examples:

- `publishing` owns transitions to `Published`.
- `bookings` owns Booking state transitions.
- `scheduling` owns schedule availability rules and capacity policy.
- `tickets` owns ticket issuance, QR token validation, Ticket validity and Ticket lifecycle rules.
- `attendance` owns the Check-in application use case, participant attendance transitions, group check-in orchestration and attendance finalization.
- `audit` owns the creation and persistence of audit records.
- `identity` owns platform role assignment policies.
- `providers` owns provider membership and provider relationships.

Other modules must use an exposed application interface rather than modifying another module's private data directly.

### 4.3 Cross-Module Communication

Modules communicate through explicit application-level interfaces.

Allowed communication patterns:

1. Direct invocation of an exported application service.
2. A domain or application port implemented by another module.
3. Persisted events or an outbox mechanism when asynchronous processing is required.

Avoid:

- Importing another module's internal repository implementation.
- Writing directly to another module's collections.
- Circular module dependencies.
- Using Firestore triggers as an implicit substitute for synchronous business transactions.

A module may read data owned by another module through an explicitly defined query interface or read model.

### 4.4 Example: Booking Creation

Creating a Booking may require:

1. `identity` to provide the authenticated user context.
2. `providers` or `publishing` to establish provider and activity eligibility through defined policies or query interfaces.
3. `scheduling` to validate schedule status and capacity rules.
4. `bookings` to execute the Booking use case.
5. `notifications` to deliver the resulting notification after the business operation succeeds.
6. `audit` to record the relevant sensitive action.

The `bookings` module remains responsible for the Booking lifecycle and its capacity reservation transaction.

### 4.5 Example: Participant Check-in

Checking in a participant may require:

1. `identity` to establish the authenticated staff identity.
2. `providers` to verify current provider membership and permissions.
3. `attendance` to own and coordinate the Check-in application use case and its transaction.
4. `tickets` to provide Ticket validation and Ticket transition rules through an explicit module interface.
5. `audit` to create the audit record within the same transaction.

The attendance state of one participant must not automatically modify the attendance state of other participants in the same Booking.

---

## 5. Flutter-to-Backend Communication

### 5.1 Access Strategy

Flutter applications use two access patterns.

**Direct Firebase SDK access** is allowed for reads and limited client-owned operations explicitly permitted by Security Rules.

**Cloud Functions access** is required for trusted business operations and protected state transitions.

### 5.2 Direct Firestore Reads

Examples of permitted direct reads, subject to Security Rules:

- Published public activities.
- Public categories.
- Public business and organizer profiles.
- Public activity schedules and availability projections.
- The authenticated customer's own bookings.
- The authenticated customer's own tickets.
- Provider-owned activities and schedules when the caller has the required membership permissions.
- Authorized dashboard data.

A direct read is permitted only when the corresponding data visibility and ownership rules are explicitly defined.

A document being stored in Firestore does not make it publicly readable.

### 5.3 Cloud Functions Operations

Sensitive operations must execute through trusted backend use cases.

Examples:

| Operation | Execution Type | Backend responsibility |
|---|---|---|
| `createRequestBooking` | Client command | Validate request, reserve temporary capacity and create Pending Booking |
| `createInstantBooking` | Client command | Validate availability, create Confirmed Booking and reserve confirmed capacity |
| `approveBooking` | Client command | Validate provider authority and convert an active hold |
| `rejectBooking` | Client command | Reject Booking and release its active hold, or expire it if the hold has already expired |
| `cancelBooking` | Client command | Validate cancellation policy and release applicable capacity |
| `approveProvider` | Administrative command | Apply provider approval transition |
| `approveActivity` | Administrative command | Apply activity approval transition |
| `publishActivity` | Administrative command | Validate publishing eligibility and publish |
| `suspendActivity` | Administrative command | Suspend according to administrative policy |
| `issueTickets` | Internal application operation | Create tickets after confirmation when required |
| `validateTicket` | Client command | Validate ticket and attendance eligibility |
| `checkInTicket` | Client command | Validate the ticket and record the associated participant check-in exactly once |
| `recordParticipantAttendance` | Authorized application operation | Record an explicitly permitted participant attendance outcome |
| `finalizeBookingAttendance` | Internal scheduled/background operation | Finalize eligible participant attendance and derive the final Booking outcome after the attendance window closes |
| `assignPlatformRole` | Administrative command | Perform authorized platform role assignment |

Client commands must pass through the authenticated backend access layer and must independently enforce authentication, authorization, validation, idempotency, and business rules.

Internal application operations must not be exposed as public or client-callable operations unless an explicit authorization and API contract is defined.

`finalizeBookingAttendance` is owned by the attendance module and invoked by trusted backend processing. Flutter clients must never directly finalize Booking attendance or modify finalization claim fields.

These names describe application operations, not finalized API contracts.

### 5.4 Callable Functions

Callable Functions are the default interface for authenticated Flutter application commands.

They provide Firebase-aware request context, but they do not replace:

- Input validation.
- Authorization.
- Business rule enforcement.
- Idempotency.
- Transactional integrity.

Every callable operation must independently enforce its authorization requirements.

### 5.5 HTTPS Functions

HTTPS Functions are used where a conventional HTTP interface is more appropriate, including:

- External provider webhooks.
- Third-party integrations.
- Public endpoints with explicitly designed HTTP contracts.
- Future REST API compatibility endpoints.

External requests must use an appropriate authentication or signature verification mechanism.

Do not expose internal application operations as unauthenticated HTTP endpoints.

### 5.6 Stable API Contracts

Application use cases must not depend on Firebase Callable request or response types.

The access layer maps external payloads into application commands and maps application results into API response DTOs.

API contracts must define:

- Operation name.
- Authentication requirement.
- Authorization requirement.
- Input fields.
- Output fields.
- Validation failures.
- Business errors.
- Idempotency behavior.
- Retry behavior.

Detailed contracts belong in `API_CONTRACTS.md`.

---

## 6. Identity and Authorization Architecture

### 6.1 Authentication

Firebase Authentication provides the authenticated identity.

The backend obtains the caller's verified UID from the trusted request context.

A client-provided `userId` must never be treated as proof of identity.

### 6.2 Authorization

Authentication answers:

"Who is making this request?"

Authorization answers:

"Is this user allowed to perform this operation on this resource?"

Authorization must be checked server-side for every sensitive operation.

### 6.3 Role and Membership Model

Fusha has multiple actor types:

- Guest.
- Customer.
- Business Owner.
- Organizer.
- Staff.
- Admin.
- Super Admin.

Platform roles and provider memberships are different authorization concepts.

A user's membership in a Business or Organizer does not automatically grant platform-level administrative privileges.

Provider access must consider:

- Authenticated UID.
- Membership status.
- Membership role.
- Resource ownership.
- Specific permissions.
- Provider approval and suspension status.
- The target resource's state.

### 6.4 Custom Claims

Firebase Auth custom claims may be used for coarse-grained platform roles when appropriate.

They must not become the only source of truth for mutable provider memberships or detailed permissions.

The backend must resolve current membership and resource permissions from authoritative backend data when required.

Custom claims must be assigned only by trusted administrative backend operations.

Firebase Authentication custom claims are included in ID tokens and may remain stale until the token is refreshed.

For high-privilege operations, especially administrative and moderation operations, the backend must verify the current authoritative platform role and account status rather than relying exclusively on potentially stale token claims.

Custom claims may be used as an optimization or preliminary authorization signal, but they must not override the authoritative authorization state.

### 6.5 Security Boundaries

The following must never be writable directly by an untrusted client:

- Platform role assignments.
- Provider approval status.
- Activity approval and publication status.
- Booking status.
- Capacity counters.
- Capacity reservation state.
- Ticket validity state.
- Check-in records.
- Participant attendance records.
- Audit logs.
- Administrative moderation state.

Cloud Functions using the Firebase Admin SDK bypass Firestore Security Rules. Therefore, server-side code must explicitly enforce authorization and validation rather than relying on Rules to protect Admin SDK writes.

---

## 7. Firestore Data Architecture

### 7.1 Source of Truth

`docs/backend/DATA_MODEL.md` defines the approved domain model and proposed Firestore structure.

The backend implementation must follow its entity ownership, relationships, and collection paths.

Do not introduce a second competing naming convention.

### 7.2 Firestore Responsibilities

Firestore stores:

- User and provider data.
- Provider memberships.
- Activities and activity versions.
- Schedules and capacity accounting.
- Bookings and participants.
- Capacity reservations.
- Tickets and check-ins.
- Participant attendance.
- Reviews and favorites.
- Notifications.
- Audit records.
- Other approved marketplace data.

### 7.3 Repository Abstraction

Application and domain code depend on repository interfaces rather than Firestore SDK objects.

Example conceptual interface:

```typescript
interface BookingRepository {
  findById(bookingId: string): Promise<Booking | null>;

  create(
    booking: Booking,
    transaction: BookingTransaction,
  ): Promise<void>;

  update(
    booking: Booking,
    transaction: BookingTransaction,
  ): Promise<void>;
}
```

The actual transaction abstraction must be designed so application code can coordinate atomic operations without importing Firestore types.

### 7.4 Firestore Adapter

The Firestore adapter implements repository interfaces and translates between:

- Domain entities.
- Persistence DTOs.
- Firestore documents.
- Firestore transaction operations.

Firestore `Timestamp`, `DocumentReference`, `DocumentSnapshot`, and SDK-specific errors must not leak into the domain layer.

### 7.5 Denormalization

Firestore denormalization is allowed when it improves read performance or avoids excessive reads.

Denormalized data must have:

- A clearly identified authoritative source.
- A defined update owner.
- A consistency strategy.
- A repair or reconciliation strategy where appropriate.

A denormalized field must not become an independent source of truth accidentally.

---

## 8. Booking and Capacity Architecture

Booking and capacity management are core backend capabilities, not ordinary CRUD operations.

The architecture must preserve the approved Booking and CapacityReservation model.

### 8.1 Capacity Ownership

Capacity belongs to an `ActivitySchedule`.

For a finite-capacity schedule:

```text
availableCapacity =
    capacity
    - confirmedQuantity
    - heldQuantity
```

Where:

- `capacity` is the total capacity of the Schedule.
- `confirmedQuantity` is the quantity allocated to confirmed Bookings.
- `heldQuantity` is the quantity reserved by active, unexpired Request Booking holds.

`availableCapacity` is derived and must not be independently writable.

For an unlimited-capacity schedule, the backend must apply the approved unlimited-capacity policy rather than imposing an artificial finite counter.

**Capacity accounting rules**

- Creating a Request Booking increases `heldQuantity`.
- Approving a valid Request Booking decreases `heldQuantity` and increases `confirmedQuantity` by the same quantity.
- Expiring or releasing an active Request Booking hold decreases `heldQuantity` exactly once.
- Creating an Instant Booking increases `confirmedQuantity` directly.
- An eligible cancellation of a Confirmed Booking decreases `confirmedQuantity` exactly once.
- Completing a Booking or finalizing it as `NoShow` does not automatically release its allocated capacity.
- Participant check-in, partial attendance, and participant NoShow recording do not release capacity.
- Finalizing attendance does not change the quantity originally allocated to the Booking.
- A capacity release must always correspond to a valid Booking transition and, when applicable, a valid CapacityReservation transition.

Capacity is not released merely because an activity has started, ended, or reached attendance finalization.

Any cancellation or administrative capacity adjustment after confirmation must follow an explicitly authorized operation and the applicable cancellation or accounting policy.

All capacity changes must be performed by trusted backend operations using atomic transactions or an equivalent concurrency-safe mechanism.

The backend must maintain consistency between Schedule counters, Booking state, and CapacityReservation state. A counter must never be changed independently of its corresponding valid state transition.

### 8.2 Booking Flow Types

Fusha supports two booking flows:

1. Request Booking.
2. Instant Booking.

Both use the same schedule-level capacity accounting but have different state transitions.

### 8.3 Request Booking

When a customer submits a Request Booking, the backend must:

1. Authenticate the customer.
2. Validate the input and idempotency key.
3. Verify that the Activity is eligible for booking.
4. Verify that the Schedule is bookable.
5. Validate the requested quantity and booking policy.
6. Reconcile relevant expired reservations before relying on schedule counters.
7. Verify sufficient available capacity.
8. Create the Booking with `Pending` status.
9. Create a CapacityReservation directly with `Active` state.
10. Set the reservation's `expiresAt`.
11. Increase `heldQuantity`.
12. Persist the related changes atomically.
13. Persist any required notification or outbox record as part of the transaction.
14. Trigger notification delivery only after the transaction succeeds.

The default hold duration is 30 minutes, configurable within platform-defined limits.

The Booking remains Pending while awaiting provider approval and while its hold is valid.

The hold expiration is determined by the backend's trusted clock, not the customer's device clock.

### 8.4 Request Booking Approval

When the provider approves a Pending Booking:

1. Authenticate the provider actor.
2. Verify provider membership and approval permissions.
3. Verify that the Booking belongs to the provider's authorized scope.
4. Read the Booking and CapacityReservation.
5. Verify that the Booking is still Pending.
6. Verify that the reservation is Active.
7. Verify that `expiresAt` is later than the trusted server time.
8. Convert the reserved quantity from held to confirmed.
9. Decrease `heldQuantity`.
10. Increase `confirmedQuantity`.
11. Set the reservation state to `Converted`.
12. Set the Booking state to `Confirmed`.
13. Finalize the eligible BookingParticipant set and initialize `eligibleParticipantCount` to its exact size and `checkedInParticipantCount` to zero; set both counters to null when participant-level attendance does not apply.
14. Record `confirmedAt`.
15. Persist any required notification or outbox record.
16. Commit the Booking, participant-set finalization, attendance counters, reservation and Schedule changes atomically.

If the reservation has already expired, the backend must not approve the Booking.

Instead, it must transition the Booking and reservation to `Expired` and release the held quantity exactly once, using the same atomic capacity accounting rules.

An expired reservation must never be converted into a confirmed Booking.

### 8.5 Request Booking Rejection

When a provider rejects a Pending Booking, the backend must evaluate the current Booking and CapacityReservation state using the trusted server clock.

The operation must:

1. Authenticate the provider actor.
2. Verify provider membership and rejection permissions.
3. Verify that the Booking belongs to the provider's authorized scope.
4. Read the current Booking, CapacityReservation, and relevant Schedule state.
5. Verify that the Booking is still Pending.
6. Evaluate the reservation state and `expiresAt` using trusted server time.
7. Apply exactly one of the following outcomes.

**Active and unexpired reservation**

If the reservation is `Active` and `expiresAt` is later than the trusted server time:

- Change the Booking status to `Rejected`.
- Change the CapacityReservation state to `Released`.
- Decrease `heldQuantity` by the reservation quantity exactly once.
- Record the rejection timestamp.
- Record the relevant audit information.

**Expired reservation**

If the reservation is `Active` but `expiresAt` is equal to or earlier than the trusted server time:

- Change the Booking status to `Expired`.
- Change the CapacityReservation state to `Expired`.
- Decrease `heldQuantity` by the reservation quantity exactly once.
- Record the expiration timestamp.
- Do not mark the Booking as `Rejected`.

**Already transitioned reservation**

If the reservation is already `Released` or `Expired`:

- Do not release capacity again.
- Resolve the operation according to the current Booking state and idempotency rules.
- Do not perform a conflicting Booking state transition.

If the reservation is `Converted`, the Booking and reservation states are inconsistent with a Pending rejection operation. The backend must not release capacity as though an active hold still existed. It must return a controlled state-conflict result and record the inconsistency for investigation.

The Booking transition, CapacityReservation transition, Schedule counter update, and required idempotency or audit records must be committed atomically.

A rejection must never cause a second capacity release.

No external side effects may execute inside the transaction callback.

### 8.6 Instant Booking

Instant Booking does not create a separate temporary CapacityReservation.

The backend must perform the following in one atomic server-side transaction:

1. Authenticate the customer.
2. Validate the idempotency key.
3. Verify Activity and Schedule eligibility.
4. Validate quantity and booking policy.
5. Reconcile relevant expired reservations.
6. Verify sufficient available capacity.
7. Create the Booking with `Confirmed` status.
8. Create or finalize the eligible BookingParticipant records according to the Activity policy.
9. Initialize `eligibleParticipantCount` to the exact eligible participant count and `checkedInParticipantCount` to zero; set both counters to null when participant-level attendance does not apply.
10. Increase `confirmedQuantity`.
11. Record `confirmedAt`.
12. Persist any required notification or outbox record.
13. Persist the Booking, participant set, attendance counters and capacity changes together.

If the transaction fails, neither the Booking nor the capacity update may be partially committed.

Provider approval and temporary hold expiration do not apply to Instant Booking.

### 8.7 Hold Expiration

Hold expiration must be enforced by trusted backend logic.

It must not depend on:

- Flutter timers.
- Customer device time.
- Provider dashboard timers.
- Firestore TTL.

Firestore TTL may be used for eventual document cleanup, but it must not be responsible for capacity release.

The architecture uses two complementary mechanisms:

**Scheduled expiration processing**

A scheduled backend job identifies expired active reservations and releases them through trusted transactional operations.

**Synchronous expiration reconciliation**

Capacity-sensitive operations must account for expired reservations before relying on `heldQuantity`.

This is required because scheduled processing may be delayed.

An expired active reservation must not be treated as a valid hold merely because its status has not yet been updated by the scheduled worker.

### 8.8 Expiration Reconciliation Strategy

The backend must not assume that every expired reservation can be processed safely in one unbounded transaction.

The implementation must use bounded reconciliation.

**Reconciliation query and backlog detection**

1. Query expired Active reservations for the affected schedule, ordered by `expiresAt`.
2. Fetch up to `batchSize + 1` records rather than fetching only `batchSize`.
3. Use the additional record to detect whether the expired reservation backlog exceeds the safe processing batch.
4. Read the relevant reservation records, associated Booking records, and Schedule state before performing any transaction writes.
5. Recheck each reservation's current state and expiration using the trusted server clock.
6. Release only reservations that are still Active and expired.
7. Decrease `heldQuantity` by the released quantities exactly once.
8. Set the corresponding reservation state to `Expired`.
9. Set the corresponding Pending Booking state to `Expired`.
10. Commit the Schedule, reservation, and Booking updates atomically.

**Backlog handling**

If the query returns at most `batchSize` expired Active reservations, reconciliation may complete and the capacity-sensitive operation may continue.

If the query returns `batchSize + 1` records, the backend has detected that the backlog exceeds the safe batch limit.

In that case:

- The backend may process the first `batchSize` records to drain the backlog.
- It must not allocate new capacity during that operation.
- It must return a retryable capacity-processing error.
- The expiration worker must continue draining the backlog.
- The client may retry the capacity-sensitive operation after reconciliation has progressed.

The backend must not allocate capacity using stale counters while the reconciliation backlog remains above the configured safe limit.

**Transaction write limits**

Each expired reservation may require updating:

- The CapacityReservation document.
- Its associated Booking document.

The Schedule document must also be updated.

Therefore, the batch size must account for the total transaction writes, including any additional records required by the implementation.

The configured batch size must remain safely below the applicable Firestore transaction limits.

The implementation must also consider transaction duration, read volume, document contention, and function execution limits.

**Capacity allocation after reconciliation**

After reconciliation completes successfully, the capacity allocation transaction must read the current Schedule state and revalidate available capacity before writing.

It must never rely on:

- Schedule counters read before reconciliation.
- Cached capacity values from the client.
- Capacity values returned by an earlier query.
- A previously calculated availability projection.

If another operation changes the Schedule between reconciliation and allocation, the allocation transaction must use the latest committed state and retry or fail safely when necessary.

If a reservation expires after reconciliation but before allocation, its held quantity may remain conservatively counted until the next reconciliation. This may temporarily reduce apparent availability, but it must never permit overbooking.

The exact batch size and transaction limits must be validated against the selected Firestore SDK, platform transaction limits, and load tests before production.

### 8.9 Concurrency and Transaction Boundaries

All capacity-changing operations must use trusted server-side transactions or an equivalent concurrency-safe mechanism.

The transaction must protect:

- Schedule capacity counters.
- Booking state.
- CapacityReservation state when applicable.
- Idempotency records where applicable.
- Any required notification or outbox records.

For Firestore transactions, all required reads must be completed before the first write.

The implementation must read and validate the relevant Schedule, Booking, CapacityReservation, and Idempotency records before applying transaction writes.

When reconciliation requires reading a query result and associated Booking documents, the implementation must complete the required reads before writing any document in that transaction.

The exact transaction abstraction must preserve Firestore's read-before-write requirements without leaking Firestore SDK types into the domain or application layers.

The backend must prevent:

- Overbooking.
- Negative capacity counters.
- Duplicate reservation creation.
- Double confirmation.
- Double release.
- Conversion after expiration.
- Simultaneous approval and rejection.
- Simultaneous cancellation and approval.
- Conflicting expiration worker executions.

Every capacity transition must verify the current persisted state inside the transaction.

If concurrent operations conflict, the transaction must retry safely or return a retryable error. It must never continue using stale state.

Firestore transaction callbacks may be retried. Therefore, transaction code must not perform external side effects.

Do not:

- Send FCM notifications.
- Call external payment services.
- Send emails.
- Execute non-transactional HTTP requests.
- Perform other external side effects.

inside a transaction callback.

Persist the required event or outbox record transactionally, then perform external delivery after the transaction succeeds.

**Reservation and capacity transition consistency**

The backend must enforce the following capacity transitions:

| Operation | Booking transition | CapacityReservation transition | Schedule counter |
|---|---|---|---|
| Request Booking creation | Create as `Pending` | Create as `Active` | `heldQuantity` increases |
| Request Booking approval | `Pending` → `Confirmed` | `Active` → `Converted` | `heldQuantity` decreases and `confirmedQuantity` increases |
| Request Booking rejection before expiration | `Pending` → `Rejected` | `Active` → `Released` | `heldQuantity` decreases |
| Request Booking rejection after expiration | `Pending` → `Expired` | `Active` → `Expired` | `heldQuantity` decreases |
| Pending Booking cancellation before expiration | `Pending` → `Cancelled` | `Active` → `Released` | `heldQuantity` decreases |
| Pending Booking cancellation after expiration | `Pending` → `Expired` | `Active` → `Expired` | `heldQuantity` decreases |
| Confirmed Request Booking cancellation when permitted | `Confirmed` → `Cancelled` | `Converted` → `Released` | `confirmedQuantity` decreases |
| Confirmed Instant Booking cancellation when permitted | `Confirmed` → `Cancelled` | No reservation exists | `confirmedQuantity` decreases |
| Hold expiration | `Pending` → `Expired` | `Active` → `Expired` | `heldQuantity` decreases |
| Instant Booking creation | Create as `Confirmed` | No CapacityReservation created | `confirmedQuantity` increases |
| Booking attendance finalization | `Confirmed` → `Completed` or `NoShow` | No reservation transition | No counter change |

Every transition must verify the current persisted state inside the transaction.

The Schedule counter, Booking state, and CapacityReservation state must remain consistent after every committed operation.

A counter must never be changed independently of its corresponding valid state transition.

**Inconsistent Booking and CapacityReservation states**

The backend must validate that Booking and CapacityReservation states are compatible before executing a state transition.

Examples of inconsistent states include:

- A `Pending` Booking associated with a `Converted` reservation.
- A `Pending` Booking associated with a `Released` reservation.
- A `Pending` Booking associated with an `Expired` reservation when the Booking has not been expired.
- A `Confirmed` Request Booking associated with an `Active` reservation.
- A `Confirmed` Request Booking associated with a `Released` or `Expired` reservation.
- A terminal Booking associated with a reservation state that would require a second capacity release.

When an inconsistent state is detected:

- Do not guess which state is correct.
- Do not release or allocate capacity blindly.
- Do not silently rewrite the Booking or reservation state.
- Return a controlled state-conflict or reconciliation-required result.
- Record the inconsistency for investigation.
- Use an explicitly authorized reconciliation process to repair it.
- Record the detected discrepancy and corrective action.

The backend must distinguish between an expected repeated request and an inconsistent persisted state. Idempotency must not hide data-integrity problems.

**Attendance-related transaction coordination**

Participant check-in and Booking attendance finalization must coordinate through the same parent Booking document.

The attendance module must use the following transaction coordination rules:

1. A participant check-in transaction must read the parent Booking and verify that:
    - The Booking is `Confirmed`.
    - The applicable attendance window is still open according to trusted server time.
    - `attendanceFinalizationStatus` is `NotStarted`.
2. The check-in transaction must update the relevant BookingParticipant and create the corresponding CheckIn and audit records as one atomic operation.
3. Attendance finalization must acquire its processing claim through a transaction that reads and updates the same parent Booking document.
4. Claim acquisition changes `attendanceFinalizationStatus` from `NotStarted` to `InProgress` and assigns a unique claim ID.
5. Because check-in and claim acquisition both read the parent Booking document transactionally, a concurrent modification must cause Firestore transaction conflict detection and retry or failure.
6. A retried check-in must revalidate the current Booking state. It must not commit using a previously read `NotStarted` state after finalization has acquired its claim.
7. Once finalization is `InProgress`, new participant check-in operations must be rejected with a controlled attendance-finalization-in-progress result.
8. An expired finalization lease permits a trusted worker to acquire a new claim. It does not reset the finalization status to `NotStarted` or reopen the attendance window.
9. Only the worker holding the current claim ID and a valid lease may commit finalization progress.
10. Every finalization batch must verify claim ownership and lease validity transactionally before changing participant attendance records.
11. The final Booking outcome and finalization completion marker must be committed only after the complete eligible participant set has been reconciled.
12. A stale worker must stop processing when its claim is no longer current or its lease has expired.

The Booking document acts as the coordination point between participant check-in and attendance finalization. This coordination must not depend on client-side locks, Flutter state, or scheduled job timing.

### 8.10 Idempotency

Every client-submitted booking command must include an idempotency key.

The backend must persist and validate the key within the correct user and operation scope.

A repeated request with the same key and same effective payload must return the original logical result rather than create another Booking.

Reusing the same key with a different payload must be rejected.

Provider approval, rejection, cancellation, expiration, attendance finalization, and capacity release must also be safe under retries.

Idempotency records must be committed atomically with the corresponding business operation whenever they protect creation or capacity-changing behavior.

Idempotency keys must have a defined retention policy that does not permit accidental duplicate bookings after the key record expires.

The implementation must define how long keys remain valid and how older keys are handled so that a retry cannot accidentally create a second Booking after cleanup.

### 8.11 Cancellation and Capacity Release

Cancellation rules depend on the current Booking state and the approved cancellation policy.

All cancellation operations must use authoritative persisted Booking and CapacityReservation states and must execute through trusted backend transactions.

The backend must evaluate reservation expiration using the trusted server clock.

#### 8.11.1 Pending Booking Cancellation

When a customer requests cancellation of a Pending Booking:

**Active and unexpired reservation**

If the reservation is `Active` and has not expired:

- Validate that cancellation is permitted by the applicable policy.
- Change the Booking status to `Cancelled`.
- Change the CapacityReservation state to `Released`.
- Decrease `heldQuantity` by the reservation quantity exactly once.
- Record the cancellation timestamp.

**Expired reservation**

If the reservation is `Active` but its `expiresAt` is equal to or earlier than the trusted server time:

- Change the Booking status to `Expired`.
- Change the CapacityReservation state to `Expired`.
- Decrease `heldQuantity` by the reservation quantity exactly once.
- Record the expiration timestamp.
- Do not change the Booking status to `Cancelled` solely because the cancellation request arrived after expiration.

**Already transitioned reservation**

If the reservation is already `Released` or `Expired`:

- Do not decrease `heldQuantity` again.
- Resolve the request according to the current Booking state and idempotency rules.
- If the Booking and reservation states are incompatible, return a controlled state-conflict result and record the inconsistency.

A Pending Booking must never release the same held capacity more than once.

#### 8.11.2 Confirmed Booking Cancellation

A Confirmed Booking may be cancelled only when the applicable cancellation policy permits it.

The backend must distinguish between Request Booking and Instant Booking.

**Confirmed Request Booking cancellation**

For a Request Booking, the backend must:

1. Authenticate the customer or other authorized actor.
2. Read the current Booking, CapacityReservation, and Schedule.
3. Verify that the Booking is still `Confirmed`.
4. Verify that the reservation is `Converted`.
5. Validate the cancellation policy, including any applicable time restrictions.
6. Verify that cancellation is permitted for the current Schedule and Booking state.
7. Change the Booking status to `Cancelled`.
8. Change the CapacityReservation state from `Converted` to `Released`.
9. Decrease `confirmedQuantity` by the reservation quantity exactly once.
10. Record the cancellation timestamp and relevant audit information.

**Confirmed Instant Booking cancellation**

For an Instant Booking, no CapacityReservation exists.

The backend must:

1. Authenticate the customer or other authorized actor.
2. Read the current Booking and Schedule.
3. Verify that the Booking is still `Confirmed`.
4. Verify that the Booking was created through the Instant Booking flow.
5. Validate the cancellation policy, including any applicable time restrictions.
6. Verify that cancellation is permitted for the current Schedule and Booking state.
7. Change the Booking status to `Cancelled`.
8. Decrease `confirmedQuantity` by the Booking quantity exactly once.
9. Record the cancellation timestamp and relevant audit information.

The absence of a CapacityReservation is expected for Instant Booking and must not be treated as an inconsistency.

**Atomicity and protection**

For both flows, the Booking transition and Schedule counter update must be committed atomically.

For Request Booking, the CapacityReservation transition must be included in the same transaction.

For Instant Booking, the transaction must not attempt to create, release, or update a CapacityReservation.

If cancellation is not permitted by the applicable policy, the backend must reject the cancellation without modifying the Booking, reservation, or capacity counters.

A Confirmed Booking must not release capacity through the Pending Booking hold-release path.

#### 8.11.3 Completed and NoShow Bookings

A Booking that has reached `Completed` or `NoShow` must not automatically release its allocated capacity.

For the MVP:

- `Completed` means that the attendance window has closed and at least one eligible participant was checked in.
- `NoShow` means that the attendance window has closed and all eligible participants were recorded as `NoShow`.
- Participant-level attendance records remain authoritative for individual attendance.
- Neither Booking transition releases `confirmedQuantity`.
- A Request Booking reservation in `Converted` state remains associated with the allocated Booking capacity.
- An Instant Booking has no CapacityReservation, and its allocated capacity remains counted in `confirmedQuantity`.
- A Completed or NoShow Booking must not be processed as an ordinary cancellation.

The capacity allocated to a Completed or NoShow Booking is considered consumed for that Schedule.

Any exceptional administrative correction must use a separate, explicitly authorized operation with audit logging and a defined accounting policy. It must not be implemented as an ordinary customer cancellation.

### 8.12 Capacity Hotspots

A single Schedule document can become a contention point for high-demand activities.

For the MVP, Schedule-level counters provide a straightforward and auditable capacity model.

The implementation must monitor:

- Transaction retry rates.
- Transaction failures.
- Booking latency.
- Capacity reconciliation backlog.
- Contention on popular schedules.
- Function execution duration.

Do not introduce distributed counters for reservation capacity without redesigning the atomic allocation and overbooking guarantees.

If load testing demonstrates that a Schedule counter is a bottleneck, evaluate a deliberate capacity allocation redesign before changing the Data Model.

---

## 9. Booking Entities, Provider Approval and Activity Publishing

### 9.1 Booking

Represents a customer's reservation.

A Booking may cover one or more participants, seats, units, or another bookable quantity depending on the Activity policy.

A Booking is the aggregate representing the customer's reservation and its lifecycle. It does not own individual participant attendance.

Proposed fields:

| Field | Type | Description |
|---|---|---|
| id | String | Document ID |
| reference | String | Public booking reference |
| customerId | String | Customer User ID |
| activityId | String | Activity ID |
| scheduleId | String? | Selected schedule |
| providerType | String | Business or Organizer |
| providerId | String | Provider ID |
| quantity | Number | Requested quantity |
| totalAmount | Number | Total amount in minor currency units |
| currency | String | ISO 4217 currency code |
| bookingType | String | Instant or Request |
| status | String | Booking lifecycle status |
| paymentMethod | String? | Selected payment method |
| paymentStatus | String | Payment status |
| activitySnapshot | Map | Activity details at booking time |
| scheduleSnapshot | Map? | Schedule details at booking time |
| locationSnapshot | Map? | Location details at booking time |
| bookingPolicySnapshot | Map? | Applicable booking, cancellation, and attendance policy snapshot |
| eligibleParticipantCount | Number? | Number of participants eligible for attendance; null when participant-level attendance does not apply |
| checkedInParticipantCount | Number? | Number of eligible participants successfully checked in; null when participant-level attendance does not apply |
| idempotencyRecordId | String? | Associated IdempotencyRecord for the Booking creation request, when applicable |
| attendanceWindowEndsAt | Timestamp? | Snapshot of the applicable attendance window closing time, when participant attendance tracking applies |
| attendanceFinalizationStatus | String | Backend-managed finalization state: NotRequired, NotStarted, InProgress, or Completed |
| attendanceFinalizationClaimId | String? | Unique claim identifier for the active attendance finalization worker |
| attendanceFinalizationClaimedAt | Timestamp? | Server timestamp when the active finalization claim was acquired |
| attendanceFinalizationLeaseExpiresAt | Timestamp? | Server timestamp when the active worker claim expires and may be reclaimed |
| attendanceFinalizedAt | Timestamp? | Server timestamp when all eligible participant attendance and the Booking outcome were successfully finalized |
| confirmedAt | Timestamp? | Confirmation date |
| cancelledAt | Timestamp? | Cancellation date |
| expiredAt | Timestamp? | Expiration date |
| createdAt | Timestamp | Creation date |
| updatedAt | Timestamp | Last update |

Proposed booking statuses:

- Pending
- Confirmed
- Rejected
- Cancelled
- Expired
- Completed
- NoShow

Status meanings:

| Status | Meaning |
|---|---|
| Pending | Request Booking awaiting provider approval with an active capacity hold |
| Confirmed | Booking has been confirmed |
| Rejected | Provider rejected the request |
| Cancelled | Booking was cancelled |
| Expired | Request or temporary hold expired |
| Completed | The booked service or activity has been completed; for participant-based attendance, at least one eligible participant attended |
| NoShow | All eligible participants in a participant-based Booking were recorded as NoShow after the attendance window closed; for bookings without participant records, the applicable booking-level attendance policy determines the outcome |

Booking attendance finalization rules:

- Booking attendance is derived from its complete eligible BookingParticipant set when participant-level attendance is used.
- All eligible participants `CheckedIn` results in Booking status `Completed`.
- Partial attendance, where at least one eligible participant is `CheckedIn` and the remaining eligible participants are `NoShow`, results in Booking status `Completed`.
- Booking status `NoShow` is permitted only when every eligible participant is recorded as `NoShow`.
- When the applicable attendance window closes, trusted backend processing must convert eligible participants remaining in `NotCheckedIn` to `NoShow`.
- Existing `CheckedIn` and `NoShow` participant records must be preserved during finalization.
- Attendance finalization must not occur before the applicable attendance window closes.
- A Booking with no eligible participant records must never be interpreted as an all-NoShow Booking.
- Bookings without participant records must follow an explicitly defined booking-level attendance policy.
- Participant-based finalization must validate the complete and stable eligible participant set before deriving the Booking outcome.
- Attendance finalization must be idempotent, retry-safe, and protected against concurrent check-in operations.
- Finalization must use a backend-managed claim and lease mechanism so that overlapping or stale workers cannot commit conflicting results.
- `attendanceFinalizationStatus` is independent of `Booking.status`.
- `attendanceFinalizedAt` must only be populated after all eligible participant records and the Booking outcome have been successfully reconciled.
- Active claim fields must be cleared when finalization completes. Execution details must remain available through the appropriate audit records.
- Attendance finalization must never release or reduce confirmed capacity.

For bookings without participant records, such as some restaurant or table reservations, attendance must follow an explicitly defined booking-level policy rather than participant-level aggregation.

Payment statuses:

- Unpaid
- Paid
- Refunded
- Partially Refunded

Booking status and payment status are independent.

Attendance status, Ticket status, Booking status, and Payment status are separate concepts and must not be treated as interchangeable.

The exact payment and cancellation transitions must be defined in the booking workflow specification.
### 9.2 BookingParticipant

Represents an individual participant within a group Booking.

A Booking may contain one or more BookingParticipants when the Activity policy requires participant-level records.

Each participant has an independent attendance lifecycle. Attendance must never be represented only by a single status on the entire Booking when participant records exist.

Participant details may be optional depending on the Activity policy.

Proposed fields:

| Field | Type | Description |
|---|---|---|
| id | String | Participant document ID |
| bookingId | String | Associated Booking ID |
| displayName | String? | Participant display name, when required |
| contactDetails | Map? | Participant contact details, when required |
| participantReference | String? | Participant reference within the Booking |
| ticketId | String? | Associated individual Ticket, only when individual ticketing is required |
| attendanceStatus | String | Independent attendance status |
| checkedInAt | Timestamp? | Participant check-in timestamp |
| checkedInByUserId | String? | User ID of the staff member who checked in the participant |
| createdAt | Timestamp | Creation date |
| updatedAt | Timestamp | Last update |

Attendance statuses:

- NotCheckedIn
- CheckedIn
- NoShow

Attendance status meanings:

| Status | Meaning |
|---|---|
| NotCheckedIn | Participant has not yet been checked in and the attendance window is still open |
| CheckedIn | Participant was successfully checked in by an authorized operation |
| NoShow | Participant did not attend and was finalized as NoShow after the applicable attendance window closed |

Participant attendance rules:

- Each BookingParticipant has its own independent `attendanceStatus`.
- A participant check-in must update only the relevant participant's attendance state.
- A participant must not be marked `NoShow` while their applicable attendance window is still open.
- After the attendance window closes, trusted backend finalization processing may transition eligible `NotCheckedIn` participants to `NoShow`.
- A participant already marked `CheckedIn` must never be overwritten as `NoShow`.
- An existing `NoShow` record must remain unchanged during ordinary finalization retries.
- Attendance updates must be authorized, transactional, and idempotent.
- `checkedInAt` and `checkedInByUserId` must be populated when a participant is successfully checked in.
- A `NoShow` participant must not have a successful check-in timestamp or check-in actor unless an explicit correction and audit workflow records a historical check-in separately.
- Participant attendance changes must not modify the Booking's originally allocated quantity or release confirmed capacity.
- Ordinary client operations must not add, remove, replace, or modify the eligibility of participants after the Booking is confirmed.
- Any permitted participant-set modification must be performed by an explicitly authorized backend operation.
- Once attendance finalization enters `InProgress`, the eligible participant set must remain stable until finalization completes or an authorized recovery operation is performed.
- Participant attendance finalization must operate on the complete eligible participant set and must never interpret an empty participant set as an all-NoShow outcome.

A Booking does not always require participant records.

For example, a restaurant table reservation may be represented by a booking quantity and table details instead.

Individual Ticket association is optional and depends on the Activity ticketing policy. A participant can have attendance tracking without requiring an individual Ticket.

### 9.3 Activity Approval

Activity review is independent of provider approval.

The backend must verify:

- The provider is approved and eligible.
- The Activity belongs to the provider's authorized scope.
- Required information is present.
- The Activity revision is valid.
- The acting administrator is authorized.

### 9.4 Publishing

Only the publishing workflow may transition an Activity to Published.

Publishing must verify provider eligibility and Activity approval.

Clients and provider dashboards must never write `Published` directly.

Material changes to a published Activity must follow the approved revision review policy.

The currently published version must remain consistent while a new revision is being reviewed, unless safety or operational requirements require suspension.

Existing Bookings must retain their immutable snapshots.

### 9.5 Auditability

Provider approval, Activity approval, publishing, rejection, suspension, and administrative overrides must produce audit records.

---

## 10. Tickets and Check-in Architecture

### 10.1 Ticket

Tickets represent authorization to attend an Activity or schedule.

A Booking may have:

- One booking-level QR reference.
- Individual participant Tickets.
- Both, depending on Activity policy.

A restaurant reservation may only need a booking-level reference.

An event with individual participants may require individual Tickets.

A Ticket is an access credential. It is not the source of truth for participant attendance.

Proposed fields:

| Field | Type | Description |
|---|---|---|
| id | String | Ticket document ID |
| bookingId | String | Associated Booking |
| participantId | String? | Associated participant; null for a booking-level Ticket |
| activityId | String | Associated Activity |
| scheduleId | String? | Associated schedule |
| tokenHash | String | Secure token hash or reference |
| ticketType | String | Booking or Participant |
| status | String | Ticket lifecycle status |
| issuedAt | Timestamp | Issuance date |
| usedAt | Timestamp? | Date the Ticket's permitted check-in scope was fully consumed |


Ticket statuses:

- `Valid`
- `PartiallyUsed`
- `Used`
- `Cancelled`
- `Expired`

Ticket status is independent of participant attendance status.

For individual participant Tickets:

- A successful check-in consumes the participant's Ticket.
- The associated BookingParticipant attendanceStatus becomes `CheckedIn`.
- The Ticket status becomes `Used`.
- An unused participant Ticket becomes `Expired` when the applicable attendance window closes.
- `PartiallyUsed` does not apply to individual participant Tickets.

For booking-level Tickets:

- Scanning the QR must not automatically check in all participants.
- An authorized staff member must explicitly select the participant or participants to check in.
- `Valid` means that no eligible participant has been checked in.
- After one or more participants are checked in, the Ticket becomes `PartiallyUsed` while other eligible participants remain unchecked.
- The Ticket becomes `Used` only after all eligible participants have been successfully checked in.
- If the attendance window closes before all eligible participants have checked in, the Ticket becomes `Expired`, whether no participant or only some participants were checked in.
- An expired Ticket must not authorize further check-ins.
- A booking-level reservation without participant records may use its Ticket for the applicable booking-level check-in operation. The Ticket becomes `Used` after that operation is successfully completed.
- Cancelling the Booking must invalidate its Ticket according to the cancellation policy.

Ticket lifecycle transitions:

- `Valid` → `PartiallyUsed`: at least one participant is checked in while other eligible participants remain.
- `Valid` → `Used`: all eligible participants are checked in through the applicable check-in workflow.
- `Valid` → `Expired`: the attendance window closes before any check-in.
- `PartiallyUsed` → `Used`: all remaining eligible participants are checked in.
- `PartiallyUsed` → `Expired`: the attendance window closes before all eligible participants are checked in.
- `Valid` or `PartiallyUsed` → `Cancelled`: the Booking is cancelled according to the applicable policy.

`Used`, `Expired`, and `Cancelled` must not be treated as interchangeable states.

Ticket expiration is independent of attendance finalization. The backend must expire an unused or partially used Ticket when its attendance window closes, without waiting for participant attendance finalization.

Ticket expiration must not modify BookingParticipant attendance records.

Ticket statuses must not be used to infer whether every participant attended.

QR codes must contain an opaque, unpredictable token or secure reference.

They must not contain personal information or sensitive Booking details.

The backend must validate the token, Ticket state, Booking eligibility, Activity and schedule association, and staff authorization before accepting a check-in.


### 10.2 CheckIn

A CheckIn records one successful attendance action. It is an immutable audit-friendly record of a successful check-in; it does not represent a failed scan or an unfinished group operation.

BookingParticipant remains the source of truth for an individual participant's current attendance status. Booking-level counters are transactional projections used to determine the booking-level Ticket state without reading the complete participant collection for every check-in.

Proposed fields:

| Field | Type | Description |
|---|---|---|
| id | String | CheckIn document ID |
| ticketId | String? | Ticket used, when applicable |
| bookingId | String | Associated Booking |
| participantId | String? | Participant checked in; null for booking-level check-in without participant records |
| activityId | String | Associated Activity |
| scheduleId | String? | Associated schedule |
| checkedInByUserId | String | Authorized staff user who performed the operation |
| checkedInAt | Timestamp | Server timestamp of successful check-in |

**Check-in application ownership**

The `attendance` module owns the `CheckInParticipant` and `CheckInParticipants` application use cases and coordinates the cross-module transaction. It must use explicit interfaces to obtain Ticket validation and Ticket transition decisions from `tickets`. It must not import the Ticket module's private repositories or duplicate Ticket lifecycle rules. The same transaction context must be used for all state changes that must commit atomically. The `audit` module supplies the audit-writing port used by this operation.

**Backend validation**

Before committing a participant check-in, the backend must validate within the trusted server-side operation:

- Staff identity, current provider membership and permission for the requested check-in scope.
- Ticket token, Ticket type, Ticket status, Booking association, Activity and Schedule association, when a Ticket is used.
- Booking status is `Confirmed`.
- The attendance window is open according to trusted backend time.
- `attendanceFinalizationStatus` is `NotStarted`.
- The selected participant belongs to the Booking and is eligible for attendance.
- The participant has not already been checked in.
- The request's idempotency scope and payload hash.

A booking-level QR identifies the Booking; it does not check in every participant. Every participant check-in must explicitly identify the participant. A group operation must identify the exact selected participant set and must be authorized for group check-in.

**Atomic participant check-in**

A successful participant check-in must execute as one trusted server-side Firestore transaction. All required reads must complete before the first write. The transaction must coordinate through the parent Booking document, which is also the coordination point used by attendance finalization.

For the first successful transition of a participant from `NotCheckedIn` to `CheckedIn`, the transaction must:

1. Update the BookingParticipant attendance status, `checkedInAt`, and `checkedInByUserId`.
2. Increment `Booking.checkedInParticipantCount` exactly once.
3. Update the associated Ticket according to its type and the resulting Booking counters.
4. Create exactly one CheckIn record.
5. Create the corresponding audit record.
6. Complete the applicable IdempotencyRecord or participant progress record, when the operation uses one.

A repeated request or a participant already in `CheckedIn` must not increment the counter or create another successful CheckIn. It must return a stable already-checked-in result or the previously stored idempotent result. No external side effect, such as sending a notification, may run inside the transaction callback; use an outbox or post-commit delivery mechanism where required.

For an individual participant Ticket, successful check-in changes that Ticket to `Used`.

For a booking-level Ticket, calculate the new state using the Booking counters after the successful participant transition:

- `Valid` when `checkedInParticipantCount == 0`.
- `PartiallyUsed` when `0 < checkedInParticipantCount < eligibleParticipantCount`.
- `Used` when `eligibleParticipantCount > 0` and `checkedInParticipantCount == eligibleParticipantCount`.

A booking-level Booking without participant records follows its explicit booking-level attendance policy and must not use participant counters. Its successful booking-level operation creates a CheckIn with `participantId = null` and updates the Ticket to `Used` only after the operation succeeds.

**Booking participant counters**

For a Booking that uses participant-level attendance, `eligibleParticipantCount` and `checkedInParticipantCount` must be initialized transactionally when the eligible participant set is finalized at Booking confirmation. The first counter equals the number of eligible BookingParticipant records and the second starts at zero. For a Booking without participant-level attendance, both fields are null.

The eligible participant set is immutable after confirmation during ordinary operations. Any exceptional eligibility correction must be authorized, audited, and update the participant records and both counters consistently in a trusted transaction. The backend must maintain `0 <= checkedInParticipantCount <= eligibleParticipantCount`. If the counters disagree with the authoritative participant records, the backend must block a Ticket transition that depends on the inconsistent values and invoke reconciliation; it must not guess.

BookingParticipant records remain authoritative. The counters are projections for transactional Ticket-state decisions and consistency checks; they must not replace participant reads when attendance finalization derives the final Booking outcome.

**Group check-in processing**

Every explicit check-in request selecting two or more participants must have one persisted `GroupCheckInOperation`, including requests small enough to fit in one transaction. A single-participant request uses the individual Check-in use case. The Data Model defines its parent record and participant progress subcollection. A group request must contain at least one unique participant ID. A participant may use a booking-level Ticket recorded on the operation or an individual participant Ticket recorded on that participant progress record.

The workflow must:

1. Validate staff authorization, Booking and Ticket eligibility, and the exact selected participant IDs. Reject duplicate IDs and participants that do not belong to the Booking.
2. Create the operation in `Preparing` and create one deterministic participant progress record per selected participant. Initialization is idempotent; replaying the same request with the same idempotency key and request hash resumes missing initialization records. The operation must not begin processing until every selected participant has a progress record and the operation transitions to `Pending`.
3. If the complete operation fits within the current Firestore transaction, request-size and execution limits, process the operation atomically, including the parent operation, all participant progress records, Booking counters, Ticket, CheckIn and audit records. The implementation must account for every read and write, including audit and progress writes, and must not use a fixed participant-count threshold without measuring the actual transaction workload.
4. Otherwise, process each selected participant through its own atomic transaction. Each transaction must read the Booking, operation, participant progress, participant, and applicable Ticket before writing; it must revalidate the current Booking, attendance window, finalization state, Ticket state, participant eligibility and progress state.
5. In the same participant transaction, update attendance, Booking counters, Ticket, CheckIn, audit record, participant progress and the operation's completed/failed counters. A progress record may transition from `Pending` to a terminal result only once. Concurrent or repeated processing must not double-count it.
6. Treat `Succeeded` and `AlreadyCheckedIn` as completed participant outcomes. `AlreadyCheckedIn` must not create another CheckIn or increment the Booking counter.
7. Keep transiently failed participants retryable and move the operation to `NeedsRetry`. Retry only failed participants classified as retryable; do not reprocess successful participants. A permanent participant or operation failure moves the operation to `Failed`; already committed successful check-ins remain valid and are never rolled back.
8. Mark the operation `Completed` only when every selected participant has a `Succeeded` or `AlreadyCheckedIn` result and no failures remain. Replaying the original idempotent command must return the same operation rather than create a second one; trusted recovery processing resumes an operation left in `Preparing`, `Pending`, `InProgress` or `NeedsRetry`.

The operation's progress counters and participant progress state must be changed in the same transaction. Processing may be resumed by trusted backend workers. Concurrent workers must rely on transactionally guarded progress transitions, not in-memory locks. Limit parallel processing to avoid unnecessary contention on the parent operation and Booking documents.

Firestore transaction callbacks may be retried. They must not perform external side effects or mutate process-local state. All operations must remain safe under retries, worker restarts and concurrent scans.

**Ticket expiration**

Ticket expiration is independent of attendance finalization. When the attendance window closes, an unused or partially used Ticket becomes `Expired`, whether none or only some participants checked in. Expiration must not modify participant attendance or Booking counters. A Ticket in `Expired` or `Cancelled` state must not authorize further check-ins.

Attendance finalization must preserve successful CheckIn records and must never overwrite a participant already in `CheckedIn` as `NoShow`.

### 10.3 Ticket Status and Attendance Status

Ticket status describes the Ticket's validity and lifecycle. Participant attendance status describes whether an individual participant attended. They are independent state dimensions.

`BookingParticipant.attendanceStatus` is authoritative for participant attendance. Ticket status must not be used to infer attendance, and a valid Ticket does not prove that check-in occurred. The Ticket states and transitions are defined in Section 10.1 and `DATA_MODEL.md`.

### 10.4 Check-in

All check-in commands must execute through the `attendance` module's trusted application use cases. The use case coordinates the transaction and delegates Ticket validation and lifecycle decisions to the `tickets` module through explicit interfaces. Direct client writes to BookingParticipant, Ticket, CheckIn, Booking attendance counters, group-operation progress or audit records are prohibited.

### 10.5 Booking-Level and Participant-Level QR Behavior

A booking-level QR resolves the Booking and its eligible participants but never checks in participants automatically. Staff must explicitly select each participant or invoke an explicitly authorized group check-in operation. An individual participant Ticket may update only its associated participant.

### 10.6 Ticket and Attendance Consistency

Participant attendance, Booking counters, Ticket state, CheckIn records, group-operation progress and audit records must be updated consistently within the transaction boundaries defined in Section 10.2. Participant records remain the source of truth; counters are projections and Ticket state is not an attendance record.

---

### 10.7 Check-in and Finalization Concurrency

Participant check-in and Booking attendance finalization are mutually coordinated operations.

The parent Booking document is the shared transaction coordination point.

The backend must enforce the following rules:

1. A check-in transaction must read the parent Booking before performing any writes.
2. The check-in operation must verify that the Booking is `Confirmed`, the attendance window is open, and `attendanceFinalizationStatus` is `NotStarted`.
3. The check-in transaction must update the relevant BookingParticipant and create its CheckIn and audit records atomically.
4. Attendance finalization must acquire its claim through a transaction that reads and updates the same parent Booking document.
5. Claim acquisition changes `attendanceFinalizationStatus` to `InProgress` and assigns a new unique `attendanceFinalizationClaimId`.
6. Both operations must participate in Firestore transaction conflict detection through the shared Booking document.
7. If a check-in transaction is retried after a finalization claim has been acquired, it must re-read the Booking and reject the check-in.
8. Once finalization is `InProgress`, new check-in operations must not commit.
9. An expired worker lease allows a trusted replacement worker to acquire a new claim ID. It does not reopen check-in or reset finalization to `NotStarted`.
10. A worker may commit finalization progress only while its claim ID remains current and its lease remains valid.
11. Claim ownership and lease validity must be checked inside every transaction that commits a participant attendance batch.
12. A worker that loses its claim or lease must stop immediately and must not commit additional participant updates.
13. A replacement worker must resume safely from persisted participant attendance states without overwriting already committed `CheckedIn` or `NoShow` records.
14. Final Booking status and `attendanceFinalizedAt` must be committed only after the entire eligible participant set has been reconciled successfully.
15. Completion of finalization must set `attendanceFinalizationStatus` to `Completed` and clear the active claim fields.

The implementation must not depend on Flutter locks, client timestamps, client-side timers, or assumptions about scheduled worker execution order.

This mechanism must remain safe when check-in requests, scheduled workers, retries, and replacement workers overlap.

## 11. Participant-Level Attendance Architecture

Attendance is tracked independently for every `BookingParticipant`.

A Booking may contain multiple participants, and those participants may have different attendance outcomes.

The Booking status, participant attendance status, and ticket status are separate concepts with separate responsibilities.

### 11.1 Attendance Ownership

The `attendance` module owns participant-level attendance operations and Booking attendance finalization.

The `tickets` module owns ticket validity, token verification, and ticket lifecycle.

The `bookings` module owns the commercial Booking lifecycle.

Attendance must not be represented solely by a Booking-level status.

### 11.2 Participant Attendance Status

For the MVP, each eligible BookingParticipant uses the following attendance statuses:

| Status | Meaning |
|---|---|
| `NotCheckedIn` | The participant has not been checked in and has not been finalized as NoShow |
| `CheckedIn` | The participant's attendance has been recorded |
| `NoShow` | The participant did not attend after the applicable attendance window and eligibility rules were evaluated |

Participant attendance records may include:

- `attendanceStatus`
- `checkedInAt`
- `checkedInByUserId`

Additional timestamps or audit metadata may be introduced when justified by the implementation.

The initial attendance status for an eligible participant is `NotCheckedIn`.

### 11.3 Attendance Transitions

Valid participant attendance transitions include:

| Current status | Operation | New status |
|---|---|---|
| `NotCheckedIn` | Successful authorized check-in | `CheckedIn` |
| `NotCheckedIn` | Trusted attendance finalization after the attendance window closes | `NoShow` |
| `CheckedIn` | Repeated check-in | No state change |
| `CheckedIn` | Ordinary attendance finalization | No state change |
| `NoShow` | Ordinary check-in | Not permitted |
| `NoShow` | Ordinary attendance finalization | No state change |

A correction to an attendance record after finalization must use a separately authorized operation with audit logging.

A participant must not be marked as `NoShow` before the applicable attendance window has closed.

A participant who has been checked in must never be marked as `NoShow` through ordinary attendance finalization.

An existing `NoShow` record must not be overwritten by ordinary finalization retries.

Only trusted backend attendance operations may change participant attendance status. Clients must not directly write participant attendance fields.

The attendance finalization worker may transition eligible `NotCheckedIn` participants to `NoShow` only after it has acquired a valid finalization claim and verified that the applicable attendance window has closed.

### 11.4 Partial Attendance

A group Booking may contain participants with different attendance statuses.

Example:

| Participant | Attendance Status |
|---|---|
| Participant 1 | `CheckedIn` |
| Participant 2 | `CheckedIn` |
| Participant 3 | `NoShow` |
| Participant 4 | `NoShow` |

In this example:

- The Booking has partial attendance.
- Two participants attended.
- Two participants did not attend.
- The Booking must not be classified as `NoShow`.
- Each participant's attendance status remains independently recorded.

Partial attendance does not introduce a new Booking status.

### 11.5 Booking Attendance Finalization

Booking attendance finalization occurs after the applicable attendance window closes.

The attendance window must be defined by the Activity or Schedule attendance policy and snapshotted on the Booking when participant-level attendance applies.

The backend must not finalize attendance merely because the scheduled start time has passed or because the activity's nominal end time has been reached if check-in is still permitted.

For participant-based attendance, the finalization process must:

1. Identify a candidate Booking whose attendance window has closed.
2. Verify that the Booking is still `Confirmed`.
3. Verify that participant-level attendance finalization is required.
4. Acquire a valid finalization claim through a trusted backend transaction.
5. Load the complete eligible BookingParticipant set using a deterministic and bounded processing strategy.
6. Validate the participant set and its current attendance records.
7. Process eligible participants in bounded batches.
8. Transition each eligible `NotCheckedIn` participant to `NoShow`.
9. Preserve participants already recorded as `CheckedIn` or `NoShow`.
10. Verify that every eligible participant has a finalized attendance status.
11. Derive the Booking-level attendance outcome from the complete eligible participant set.
12. Persist the final Booking status, finalization completion state, timestamp, and audit information.
13. Clear active claim fields after successful completion.

The Booking-level outcome is derived as follows:

| Eligible participant attendance after finalization | Final Booking status |
|---|---|
| All eligible participants are `CheckedIn` | `Completed` |
| At least one participant is `CheckedIn` and the remaining participants are `NoShow` | `Completed` |
| All eligible participants are `NoShow` | `NoShow` |

The Booking must not become `Completed` or `NoShow` while its attendance window remains open.

A participant whose status is `NotCheckedIn` must be transitioned to `NoShow` only after the attendance window closes and only through the trusted finalization process.

The finalization process must never overwrite an existing `CheckedIn` or `NoShow` participant record during ordinary processing.

**Eligible participant set validation**

- The backend must operate on the complete eligible participant set, not a partial or client-provided list.
- The eligible participant set must remain stable from claim acquisition until finalization completes.
- Ordinary client operations must not add, remove, replace, or change the eligibility of participants after the Booking is confirmed.
- Once finalization enters `InProgress`, no ordinary operation may modify the eligible participant set.
- If the participant set is unexpectedly modified or its integrity cannot be established, the worker must stop and record a reconciliation issue.
- An empty eligible participant set must never be interpreted as an all-NoShow Booking.
- If no participant records exist because the Booking uses booking-level attendance, participant-based finalization must not run. The explicitly defined booking-level attendance policy must be used instead.
- If participant-level finalization is required but the expected participant records are missing or inconsistent, the worker must not finalize the Booking.

**Completion conditions**

The finalization operation is complete only when:

- Every eligible participant has either `CheckedIn` or `NoShow` status.
- No eligible participant remains `NotCheckedIn`.
- The complete eligible participant set has been processed successfully.
- The Booking outcome has been derived from the reconciled participant records.
- The final Booking status and finalization metadata have been persisted successfully.
- `attendanceFinalizationStatus` is `Completed`.
- Active claim fields have been cleared.

The finalization process must not release or reduce `confirmedQuantity`.

### 11.6 Attendance Finalization Reliability

Attendance finalization may be initiated by a scheduled worker or another trusted backend operation.

It must be:

- Idempotent.
- Safe under retries.
- Safe when multiple workers overlap.
- Protected against concurrent check-in.
- Based on authoritative participant records.
- Based on trusted server time.
- Auditable.
- Recoverable after partial processing or worker failure.
- Bounded in transaction size and execution time.

**Finalization state**

The Booking maintains a backend-managed `attendanceFinalizationStatus` independent of its commercial lifecycle status.

Supported values:

| Status | Meaning |
|---|---|
| `NotRequired` | Participant-level attendance finalization does not apply to this Booking |
| `NotStarted` | Participant-level finalization is required but no worker currently owns a claim |
| `InProgress` | A trusted worker currently owns the finalization claim |
| `Completed` | All eligible participants and the Booking attendance outcome have been successfully finalized |

For a Booking requiring participant-level attendance, the initial finalization state is `NotStarted`.

A Booking that does not require participant-level attendance uses `NotRequired` and must follow its explicit booking-level attendance policy.

An empty participant query must not be used by itself to decide that finalization is `NotRequired`.

**Claim acquisition**

Before processing participant attendance, a trusted worker must acquire a claim through a Firestore transaction.

The claim acquisition transaction must:

1. Read the current Booking.
2. Verify that the Booking is still `Confirmed`.
3. Verify that the applicable attendance window has closed according to trusted server time.
4. Verify that participant-level finalization is required according to the Booking's attendance policy.
5. Verify that the finalization status is either `NotStarted` or `InProgress` with an expired lease.
6. Generate a new unique `attendanceFinalizationClaimId`.
7. Set `attendanceFinalizationStatus` to `InProgress`.
8. Set `attendanceFinalizationClaimedAt` using trusted server time.
9. Set `attendanceFinalizationLeaseExpiresAt` using the configured lease duration.
10. Commit the claim fields atomically.

The claim acquisition transaction must not load or validate the complete participant set. Participant-set validation must happen after successful claim acquisition through bounded, deterministic pagination.
A worker must not acquire a claim when the status is already `Completed`.
If another worker holds an unexpired lease, the new worker must not take ownership.
If an existing `InProgress` claim has expired, a replacement worker may acquire a new claim with a new unique claim ID.
Every successful claim acquisition or reclamation must generate a new claim ID. A previous worker must never be allowed to continue committing work using an older claim ID.

**Lease and worker ownership**

The claim ID acts as a fencing token.

A worker may commit finalization progress only when:

- The Booking remains `Confirmed`.
- `attendanceFinalizationStatus` is `InProgress`.
- The stored claim ID matches the worker's claim ID.
- The lease has not expired according to trusted server time.

Claim ownership and lease validity must be verified inside every transaction that commits participant attendance changes.

A worker must not rely on a claim ID or lease expiration value read outside the transaction.

If the claim ID changes or the lease expires, the worker must stop and must not commit additional participant updates.

An expired lease permits a replacement worker to acquire a new claim. It does not reopen check-in, reset finalization to `NotStarted`, or permit a check-in operation to proceed.


**Lease renewal**

The attendance finalization worker must renew its lease before expiration when additional processing time is required.

Lease duration and renewal intervals must be configurable backend settings. No fixed numeric duration is prescribed by this architecture.

Lease renewal must execute through a Firestore transaction that:

1. Reads the authoritative parent Booking.
2. Verifies that `attendanceFinalizationStatus` is `InProgress`.
3. Verifies that `attendanceFinalizationClaimId` matches the worker's current claim ID.
4. Verifies that `attendanceFinalizationLeaseExpiresAt` is later than trusted server time.
5. Extends `attendanceFinalizationLeaseExpiresAt` using trusted server time and the configured lease duration.
6. Commits the renewed lease only if all ownership and validity checks succeed.

If any verification fails, renewal must be rejected and the worker must stop processing.

A worker must never renew an already expired lease, even if no replacement worker has acquired the claim yet.

The claim ID is a fencing token. Once ownership changes, an older worker must not be able to renew its lease or commit additional participant updates.

Every participant batch and the final Booking completion transaction must independently verify the current claim ID and unexpired lease within the same transaction that commits their changes.

A successful lease renewal does not authorize a worker to bypass any participant-set consistency, attendance, or finalization validation.

**Bounded participant processing**

The worker must process participants in bounded batches rather than requiring all eligible participants to fit into one Firestore transaction.

For each batch:

1. Select the next eligible participants using deterministic ordering and pagination.
2. Start a Firestore transaction.
3. Read the parent Booking.
4. Verify the current finalization status, claim ID, and lease validity.
5. Read all participant documents required for that batch before performing writes.
6. Validate that each participant belongs to the Booking and is eligible.
7. Change only eligible `NotCheckedIn` participants to `NoShow`.
8. Preserve participants already `CheckedIn` or `NoShow`.
9. Commit participant changes atomically with the transaction's ownership validation.

The batch size must account for Firestore transaction limits, read and write volume, transaction duration, and function execution limits.

A transaction must never commit participant updates based on a stale claim or expired lease.

**Retry and recovery behavior**

If a worker fails after processing some batches:

- Successfully committed participant updates remain authoritative.
- Unprocessed participants remain eligible for processing.
- A replacement worker may resume after the existing lease expires and a new claim is acquired.
- The replacement worker must re-read authoritative participant records.
- Existing `CheckedIn` and `NoShow` records must remain unchanged.
- Remaining eligible `NotCheckedIn` records must be processed safely.
- Reprocessing an already completed participant batch must not create duplicate attendance changes or audit outcomes.

The worker must not assume that a previous execution completed merely because some participants already have finalized statuses.

**Final Booking completion**

After all eligible participant batches have been processed, the worker must perform a separate final verification pass before attempting to complete the Booking.

The final verification pass must:

1. Use deterministic pagination to inspect the complete eligible BookingParticipant set.
2. Verify that every eligible participant has a finalized attendance status of `CheckedIn` or `NoShow`.
3. Verify that no eligible participant remains `NotCheckedIn`.
4. Verify that the eligible participant set is complete and consistent with the authoritative participant records.
5. Derive the final Booking outcome from the verified participant attendance records.
6. Abort finalization if the eligible participant set is empty, incomplete, or inconsistent.

The derived Booking outcome must follow the approved attendance policy:

- At least one eligible participant is `CheckedIn`: Booking status becomes `Completed`.
- Every eligible participant is `NoShow`: Booking status becomes `NoShow`.

The worker must not load the complete participant set inside the final Booking transaction.

After successful verification, the worker must execute a final transaction that:

1. Reads the parent Booking.
2. Verifies that the Booking is still `Confirmed`.
3. Verifies that `attendanceFinalizationStatus` remains `InProgress`.
4. Verifies that the stored claim ID matches the worker's current claim ID.
5. Verifies that the lease remains valid according to trusted server time.
6. Sets the Booking status to the outcome derived by the successful final verification pass.
7. Sets `attendanceFinalizationStatus` to `Completed`.
8. Sets `attendanceFinalizedAt` using trusted server time.
9. Clears `attendanceFinalizationClaimId`, `attendanceFinalizationClaimedAt`, and `attendanceFinalizationLeaseExpiresAt`.
10. Persists the finalization audit information as required.

The final transaction must not read or process all participant documents. Its responsibility is to validate the current Booking and claim ownership, then atomically commit the Booking lifecycle transition and finalization completion metadata.

The eligible participant set must remain stable throughout finalization. No ordinary operation may modify participant eligibility or attendance while the finalization claim is active, except the current trusted worker's authorized processing.

If the final transaction fails, the claim is no longer valid, or the lease has expired, the worker must not report successful completion. A replacement worker must resume through the claim and recovery process and perform its own final verification pass.
**Concurrency with check-in**

Participant check-in and finalization claim acquisition must coordinate through the same parent Booking document.

A check-in transaction must verify that the Booking is `Confirmed`, the attendance window is open, and `attendanceFinalizationStatus` is `NotStarted`.

Finalization claim acquisition must transactionally update that same Booking document to `InProgress`.

Firestore transaction conflict detection and retry must ensure that a check-in cannot commit based on a stale `NotStarted` state after a finalization claim has been acquired.

Once finalization is `InProgress`, new check-in operations must be rejected.

**Auditability**

The backend must retain sufficient audit information to identify:

- The finalization operation.
- The Booking.
- The worker or trusted execution identity.
- The claim identifier used for the execution.
- Claim acquisition and reclamation timestamps.
- Processing outcome.
- Completion timestamp.
- Any failure or reconciliation result.

The active claim fields are cleared after successful completion. The audit record preserves the historical execution details.

Attendance finalization must never release or reduce confirmed capacity.

### 11.7 Attendance and Capacity

Attendance must not retroactively modify reserved capacity.

For example, if a Booking reserved four seats and only two participants attended:

- The Booking retains its original allocated quantity.
- The two absent participants do not automatically release their seats.
- `confirmedQuantity` does not decrease because of partial attendance.
- The Schedule's historical capacity accounting remains consistent with the original confirmed allocation.

Participant check-in and NoShow recording are attendance operations, not capacity-release operations.

A separate administrative correction may be introduced only through an explicitly authorized, audited capacity adjustment policy.

---

## 12. Notifications Architecture

### 12.1 Responsibilities

The `notifications` module owns notification creation and delivery orchestration.

Examples:

- Booking submitted.
- Request Booking approved.
- Request Booking rejected.
- Booking cancelled.
- Booking expired.
- Ticket issued.
- Participant checked in when notification is required.
- Activity updated or cancelled.
- Provider application approved or rejected.

### 12.2 Delivery Flow

Business operations must commit successfully before notification delivery begins.

Notifications must not be sent from inside Firestore transaction callbacks.

For reliable delivery, use a persisted notification or outbox record written as part of the relevant business transaction when required.

A separate delivery process can then:

1. Read pending notification records.
2. Resolve recipient devices.
3. Send FCM messages.
4. Record delivery attempts and outcomes.
5. Retry transient failures according to a bounded retry policy.

The delivery process must be idempotent and must account for duplicate scheduled executions or retries.

FCM delivery is not the source of truth for Booking or Activity state.

A notification failure must not roll back a successfully committed Booking.

### 12.3 Client Responsibility

Flutter applications may display notifications and update local presentation state.

They must retrieve authoritative business state from the backend rather than trusting notification payloads as proof of a state transition.

---

## 13. Storage Architecture

Cloud Storage for Firebase is responsible for uploaded files such as:

- Provider verification documents.
- Business and Organizer images.
- Activity images.
- Other approved marketplace media.

### 13.1 Storage Security

Storage paths and rules must enforce:

- Authentication where required.
- Ownership or membership authorization.
- File size limits.
- Allowed content types.
- Restricted access to verification documents.
- Separation between public marketplace media and private documents.

Private provider verification documents must not be publicly readable.

Sensitive files must not become public simply because their download URLs are shared.

### 13.2 File Validation

Where required, backend processing must verify file metadata and content before treating an upload as approved.

The backend must not trust file extensions or client-provided content types alone.

Detailed path conventions and Storage Rules belong in `SECURITY_RULES.md`.

---

## 14. Scheduled Jobs and Background Processing

Scheduled Cloud Functions handle work that must happen independently of user requests.

Initial responsibilities include:

- Expiring Request Booking holds.
- Reconciling capacity reservations.
- Finalizing Booking attendance after attendance windows close.
- Processing pending notification delivery.
- Cleaning obsolete temporary records where safe.
- Other explicitly approved periodic maintenance tasks.

### 14.1 Reliability Requirements

Scheduled jobs must be:

- Idempotent.
- Safe to retry.
- Bounded in execution and batch size.
- Observable.
- Safe when multiple executions overlap.
- Designed to recover from partial failures.

A scheduled job must not assume it executes exactly once or at the exact scheduled time.

### 14.2 Expiration Worker

The expiration worker processes expired Request Booking reservations in bounded batches.

For each candidate reservation, the backend must:

1. Query reservations that are still `Active` and whose `expiresAt` is equal to or earlier than trusted server time.
2. Read the current CapacityReservation.
3. Read its associated Booking.
4. Read the relevant Schedule.
5. Complete all required transaction reads before performing any writes.
6. Recheck the reservation state and expiration using trusted server time.
7. Verify that the associated Booking is still `Pending`.
8. Verify that the reservation is still `Active`.
9. Decrease `heldQuantity` exactly once.
10. Set the reservation state to `Expired`.
11. Set the associated Booking state to `Expired`.
12. Commit the Schedule, reservation, and Booking updates atomically.

If the reservation has already transitioned to `Converted`, `Released`, or `Expired`, the worker must not release capacity again.

The worker must never change a Confirmed, Completed, NoShow, Rejected, or Cancelled Booking into `Expired`.

If a reservation and its associated Booking have inconsistent states, the worker must not guess which state is correct or modify counters blindly. It must record the inconsistency for controlled reconciliation.

Multiple workers processing the same reservation must not cause duplicate capacity release. Transactional state checks are mandatory even if a scheduling or locking mechanism is used to reduce overlapping work.

The worker must use bounded batches and must not assume that processing one batch means no remaining expired reservations exist.

### 14.3 Attendance Finalization Worker

The attendance finalization worker identifies confirmed Bookings whose applicable attendance windows have closed.

The worker is owned by the `attendance` module and must follow the claim, lease, transaction coordination, and recovery rules defined in Section 11.6.

**Candidate selection**

The worker must identify Bookings that:

- Are still `Confirmed`.
- Require participant-level attendance finalization.
- Have an `attendanceWindowEndsAt` that is equal to or earlier than trusted server time.
- Have `attendanceFinalizationStatus` set to `NotStarted`, or have `InProgress` with an expired lease.

Candidate selection is only a discovery mechanism. It does not grant permission to process a Booking.

The worker must revalidate all conditions inside the claim acquisition transaction.

**Processing workflow**

For each candidate Booking, the worker must:

1. Read the current Booking.
2. Verify the applicable attendance policy and attendance window using trusted server time.
3. Acquire a finalization claim through a transaction.
4. Assign a new unique claim ID and lease.
5. Load and validate the complete eligible participant set using bounded deterministic pagination.
6. Reject or flag an empty or inconsistent participant set when participant-level finalization is required.
7. Process eligible participants in bounded batches.
8. Verify the current claim ID and lease validity inside every batch transaction.
9. Transition eligible `NotCheckedIn` participants to `NoShow`.
10. Preserve participants already recorded as `CheckedIn` or `NoShow`.
11. Stop processing immediately if claim ownership is lost or the lease expires.
12. After all eligible participants are reconciled, execute the final completion transaction.
13. Derive the Booking outcome from the complete eligible participant set.
14. Set the Booking status to `Completed` or `NoShow`.
15. Set `attendanceFinalizationStatus` to `Completed`.
16. Set `attendanceFinalizedAt` using trusted server time.
17. Clear the active claim fields.
18. Record the finalization audit information.

The worker must not:

- Finalize attendance before the applicable attendance window closes.
- Mark an eligible participant `NoShow` while check-in is still permitted.
- Overwrite a participant already recorded as `CheckedIn`.
- Overwrite an existing `NoShow` record during ordinary retries.
- Mark a Booking as `NoShow` when at least one eligible participant is `CheckedIn`.
- Finalize an empty eligible participant set as `NoShow`.
- Process participant-based finalization when the Booking follows a booking-level attendance policy.
- Continue writing after its claim ID is no longer current or its lease has expired.
- Release or decrease `confirmedQuantity` as a result of attendance finalization.
- Change a Booking that has already reached another terminal state.

**Failure and recovery**

If processing is interrupted:

- Already committed participant updates remain authoritative.
- The worker must not attempt to reverse successfully committed attendance updates.
- A replacement worker may acquire a new claim after the existing lease expires.
- The replacement worker must use a new claim ID and resume from the persisted participant states.
- Repeated execution must not create duplicate attendance outcomes or overwrite valid attendance records.
- An inconsistent or incomplete participant set must result in a controlled reconciliation issue rather than a guessed Booking outcome.

The worker must use bounded execution and batch sizes. It must not assume that processing one batch means all eligible participants have been finalized.

The worker must not report the Booking as finalized until the final completion transaction succeeds.

Attendance finalization must not modify Schedule capacity counters or release confirmed capacity.

The detailed transaction and claim protocol is defined in Section 11.6.

### 14.4 Other Background Processing

Notification delivery and cleanup jobs must follow the same reliability principles.

Each job must have:

- A defined owner.
- A bounded processing strategy.
- Idempotent behavior.
- A retry policy.
- Structured logging.
- A failure recovery strategy.

---

## 15. Security Architecture

Security is enforced through multiple independent layers.

### 15.1 Firebase Authentication

Verifies user identity.

### 15.2 Firebase App Check

Helps reduce unauthorized or abusive requests from unverified application instances.

App Check is not a replacement for Authentication or Authorization.

### 15.3 Firestore Security Rules

Restrict direct client reads and permitted writes.

Rules must default to deny unless a specific access path is explicitly allowed.

Clients must not write protected business state.

### 15.4 Cloud Storage Security Rules

Restrict file access according to ownership, provider membership, file classification, and upload policy.

### 15.5 Server Authorization

Every sensitive Cloud Function must verify:

- Caller identity.
- Required platform role or provider membership.
- Permission for the requested operation.
- Ownership or access to the target resource.
- Resource state and applicable business policy.

Authorization must be based on current authoritative data for high-impact operations.

### 15.6 Administrative Operations

Admin and Super Admin operations must use trusted backend authorization.

A client must never grant itself administrative privileges by modifying a Firestore user document or submitting a role field.

For sensitive administrative actions, the backend must verify current platform role, account status, and relevant permissions rather than trusting stale client-provided data or claims alone.

### 15.7 Audit Logs

Sensitive operations must record:

- Actor.
- Action.
- Target resource.
- Relevant previous and new states where appropriate.
- Timestamp.
- Request or correlation identifier.
- Operation result.

Attendance corrections and administrative capacity adjustments must be auditable.

Audit records must not be directly writable or editable by ordinary clients.

Detailed security policies belong in `SECURITY_RULES.md`.

---

## 16. Error Handling and API Responses

The backend must return stable, predictable error contracts.

Errors should distinguish between:

- Authentication failure.
- Authorization failure.
- Invalid input.
- Resource not found.
- Invalid state transition.
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

Do not expose:

- Stack traces.
- Internal Firestore paths unnecessarily.
- Secrets.
- Sensitive personal data.
- Internal implementation details.

Application errors must be independent of Firebase-specific error codes.

The access layer maps application errors into the appropriate Callable or HTTP response format.

Detailed error codes and response schemas belong in `API_CONTRACTS.md`.

---

## 17. Reliability and Observability

### 17.1 Logging

Use structured logs with relevant fields:

- Function or operation name.
- Module.
- Correlation identifier.
- Authenticated actor identifier where appropriate.
- Resource identifier where safe.
- Execution outcome.
- Duration.
- Retry or failure classification.

Avoid logging passwords, authentication tokens, QR secrets, private documents, or unnecessary personal information.

### 17.2 Monitoring

Monitor:

- Cloud Function failures.
- Function latency.
- Firestore transaction failures and retries.
- Booking creation success and failure rates.
- Capacity reconciliation backlog.
- Expired reservation processing.
- Attendance finalization backlog.
- Participant check-in failures.
- Notification delivery failures.
- Ticket validation and check-in failures.
- Resource usage and operational cost.

### 17.3 Alerts

Operational alerts should be considered for:

- Repeated capacity reconciliation failures.
- Unusual transaction contention.
- Sustained Function error rates.
- Growing expired reservation backlog.
- Attendance finalization backlog.
- Notification delivery failures.
- Unexpected administrative activity.

### 17.4 Recovery

Critical operations must be recoverable through idempotent retries and controlled reconciliation.

Capacity counters and reservation states require a controlled reconciliation process that compares authoritative reservation and Booking records with Schedule-level counters.

Attendance finalization requires a controlled process that compares:

- Booking lifecycle status.
- `attendanceFinalizationStatus`.
- Active claim and lease fields.
- The complete eligible BookingParticipant set.
- Participant attendance records.
- The finalization audit history.

**Attendance finalization recovery**

If an attendance finalization worker fails or stops unexpectedly:

- Committed participant attendance changes must remain intact.
- An `InProgress` claim must not be reset to `NotStarted` merely because a worker stopped.
- A replacement worker may acquire a new claim only after the previous lease expires.
- The replacement worker must use a new unique claim ID.
- The replacement worker must re-read the Booking and participant records before continuing.
- Already finalized participant attendance records must not be overwritten.
- The Booking must remain `Confirmed` until finalization successfully completes.
- The Booking must not be marked `Completed` or `NoShow` based on a partially processed participant set.
- Finalization completion metadata must only be written after the complete eligible participant set has been reconciled.

If claim fields, Booking status, or participant attendance records are inconsistent, the worker must stop and create a controlled reconciliation issue.

A repair operation must not silently overwrite inconsistent data.

Any repair or recovery operation must be authorized, logged, idempotent where possible, and safe to repeat.

The recovery process must record the detected discrepancy, the corrective action, and the result.

## 18. Testing Strategy

Testing must cover both business correctness and Firebase integration behavior.

### 18.1 Unit Tests

Domain and application logic must be testable without Firebase.

Test:

- Booking state transitions.
- Provider authorization policies.
- Activity publishing policies.
- Capacity calculations.
- Hold expiration rules.
- Cancellation eligibility.
- Request Booking cancellation.
- Instant Booking cancellation.
- Ticket validation rules.
- Participant attendance transitions.
- Booking attendance finalization.
- Idempotency behavior.

### 18.2 Integration Tests

Use Firebase Emulator Suite where supported to test:

- Authentication integration.
- Firestore repository implementations.
- Security Rules.
- Cloud Function handlers.
- Booking transactions.
- Capacity reservation and release.
- Provider approval.
- Activity publishing.
- Ticket check-in.
- Participant attendance persistence.
- Booking attendance finalization.
- Notification persistence and delivery orchestration.

### 18.3 Concurrency Tests

Booking, capacity, ticketing, and attendance logic require explicit concurrency testing.

Scenarios include:

- Multiple customers competing for the last available seats.
- Repeated submission with the same idempotency key.
- Different requests attempting to reserve the same remaining capacity.
- Approval racing with expiration.
- Rejection racing with expiration.
- Cancellation racing with approval.
- Multiple expiration workers processing the same reservation.
- Reconciliation racing with a new booking request.
- A backlog larger than the configured reconciliation batch.
- Repeated check-in attempts for one ticket.
- Two staff members checking in the same participant concurrently.
- Participant check-in racing with attendance finalization claim acquisition.
- Multiple attendance finalization workers attempting to acquire a claim for the same Booking.
- A worker attempting to reclaim a Booking while another worker still holds an unexpired lease.
- A replacement worker acquiring a new claim after the previous lease expires.
- An old worker attempting to commit a participant batch after its claim has been replaced.
- A worker attempting to commit a participant batch after its lease expires.
- Claim acquisition racing with a check-in transaction.
- A check-in transaction retrying after finalization has entered `InProgress`.
- Multiple workers processing different batches of the same Booking.
- A worker failing after some participant batches have committed.
- A replacement worker resuming after partial participant processing.
- A final completion transaction racing with claim expiration.
- An unexpected participant-set modification during finalization.
- An attendance finalization attempt with an empty or incomplete eligible participant set.

Tests must verify that capacity is never overbooked and counters remain consistent.

**Additional cancellation and capacity lifecycle scenarios**

- Provider rejection while the Request Booking hold is active.
- Provider rejection after the Request Booking hold has expired.
- Customer cancellation while a Pending Booking hold is active.
- Customer cancellation after a Pending Booking hold has expired.
- Confirmed Request Booking cancellation when permitted by policy.
- Confirmed Request Booking cancellation when prohibited by policy.
- Confirmed Instant Booking cancellation when permitted by policy.
- Confirmed Instant Booking cancellation when prohibited by policy.
- Confirmed Booking cancellation racing with provider or administrative operations.
- Completed Booking retaining its allocated capacity.
- NoShow Booking retaining its allocated capacity.
- Repeated cancellation after capacity has already been released.
- Repeated rejection after a Booking has reached a terminal state.
- An inconsistent Booking and CapacityReservation state being detected without an additional capacity release.
- Instant Booking cancellation succeeding without a CapacityReservation.
- Request Booking cancellation requiring a valid Converted reservation.

Tests must verify that `heldQuantity` and `confirmedQuantity` are updated exactly once and remain consistent with the corresponding Booking and CapacityReservation transitions.

**Additional participant-level attendance scenarios**

- All participants checked in before the attendance window closes.
- All participants marked NoShow after the attendance window closes.
- Partial attendance with some participants checked in and others marked NoShow.
- A Booking with at least one `CheckedIn` participant must finalize as `Completed`, not `NoShow`.
- A Booking with all eligible participants marked `NoShow` must finalize as `NoShow`.
- A Booking must not be finalized while the attendance window remains open.
- A participant must not be marked `NoShow` before the attendance window closes.
- A participant already `CheckedIn` must not be overwritten as `NoShow`.
- An existing `NoShow` record must not be overwritten during ordinary finalization retries.
- Repeated check-in must not create duplicate attendance records.
- Repeated attendance finalization must not change an already finalized Booking.
- An empty eligible participant set must not be treated as NoShow automatically.
- Partial attendance must not reduce `confirmedQuantity`.
- Participant NoShow must not release capacity.
- A Booking-level QR scan must not check in all participants automatically.
- An individual ticket must only update its associated participant.
- An unauthorized staff member must not change participant attendance.
- Attendance correction must use an authorized audited operation.

**Additional attendance claim and recovery scenarios**

- A Booking requiring participant-level attendance starts with `attendanceFinalizationStatus` set to `NotStarted`.
- A Booking not requiring participant-level attendance uses `NotRequired`.
- A worker cannot acquire a claim before the attendance window closes.
- A worker cannot acquire a claim for a Booking that is no longer `Confirmed`.
- Only one worker can acquire the active claim for a Booking.
- A worker cannot replace another worker's unexpired claim.
- Claim reclamation after lease expiration generates a new unique claim ID.
- An old worker cannot commit after a replacement worker acquires a new claim.
- An old worker cannot commit after its lease expires.
- A check-in cannot commit after finalization claim acquisition.
- A check-in transaction retried after claim acquisition must revalidate and reject the operation.
- A failed worker leaves committed participant updates intact.
- A replacement worker resumes safely after partial batch processing.
- Reprocessing a committed participant batch does not overwrite `CheckedIn` or `NoShow`.
- A worker cannot complete finalization while any eligible participant remains `NotCheckedIn`.
- A worker cannot finalize an empty or inconsistent eligible participant set.
- A worker cannot complete finalization without the current claim ID and a valid lease.
- Successful finalization sets `attendanceFinalizationStatus` to `Completed`.
- Successful finalization sets `attendanceFinalizedAt`.
- Successful finalization clears active claim fields.
- Finalization audit records retain the execution and claim history.
- Finalization completion does not modify confirmed capacity.

Tests must verify that Booking status, participant attendance, ticket state, claim ownership, lease validity, and capacity accounting remain consistent without conflating their responsibilities.

### 18.4 Failure and Retry Tests

Test:

- Transaction retries.
- Function timeout.
- Interrupted notification delivery.
- Duplicate scheduled execution.
- Partial batch processing.
- Expiration backlog exceeding the configured batch limit.
- Repeated client requests after network interruption.
- A reservation expiring between reconciliation and capacity allocation.
- A provider action arriving after a reservation has expired.
- Attendance finalization interrupted before claim acquisition completes.
- Attendance finalization interrupted after claim acquisition but before participant processing.
- Attendance finalization interrupted after some participant batches have committed.
- Attendance finalization retried after a partial failure.
- A replacement worker resuming after the previous claim lease expires.
- A previous worker attempting to continue after its claim has been replaced.
- A worker attempting to commit after its lease expires.
- A worker failing during the final Booking completion transaction.
- A finalization retry encountering participants already marked `NoShow`.
- A finalization retry encountering participants already marked `CheckedIn`.
- A check-in request retried after a network interruption.
- A check-in transaction retried after finalization claim acquisition.
- Attendance reconciliation encountering inconsistent participant records.
- Attendance reconciliation encountering an empty eligible participant set.
- Attendance finalization encountering an unexpectedly modified participant set.
- Attendance finalization encountering an incomplete participant batch or interrupted pagination.

Tests must verify that:

- Committed participant attendance updates remain authoritative after worker failure.
- Unprocessed eligible participants can be safely processed by a replacement worker.
- A stale worker cannot commit after losing claim ownership.
- A worker cannot commit after its lease expires.
- Repeated processing does not overwrite `CheckedIn` or `NoShow`.
- A Booking is not marked `Completed` or `NoShow` before the complete eligible participant set has been reconciled.
- Active claim fields are cleared only after successful finalization.
- Finalization audit information is preserved.
- Attendance recovery does not release or reduce confirmed capacity.

### 18.5 Load Testing

Before production, test popular schedules under realistic concurrent booking traffic.

Also test attendance finalization for large numbers of participants and simultaneous activity sessions.

Use the results to validate transaction contention, execution time, batch size, and reconciliation behavior.

---

## 19. Backend Project Structure

The backend lives in a dedicated directory in the Fusha monorepo.

```text
backend/
├── functions/
│   ├── src/
│   │   ├── modules/
│   │   │   ├── identity/
│   │   │   ├── providers/
│   │   │   ├── catalog/
│   │   │   ├── publishing/
│   │   │   ├── scheduling/
│   │   │   ├── bookings/
│   │   │   ├── tickets/
│   │   │   ├── attendance/
│   │   │   ├── discovery/
│   │   │   ├── engagement/
│   │   │   ├── notifications/
│   │   │   ├── administration/
│   │   │   └── audit/
│   │   │
│   │   ├── shared/
│   │   │   ├── domain/
│   │   │   ├── application/
│   │   │   └── infrastructure/
│   │   │
│   │   ├── config/
│   │   └── index.ts
│   │
│   ├── test/
│   ├── package.json
│   └── tsconfig.json
│
├── firestore.rules
├── firestore.indexes.json
├── storage.rules
└── firebase.json
```

### 19.1 Module Internal Structure

A module may use the following structure when its complexity justifies it:

```text
bookings/
├── domain/
│   ├── entities/
│   ├── value_objects/
│   ├── policies/
│   └── repositories/
│
├── application/
│   ├── commands/
│   ├── queries/
│   ├── use_cases/
│   └── services/
│
├── infrastructure/
│   ├── persistence/
│   └── repositories/
│
└── presentation/
    └── functions/
```

The `attendance` module may use the same structure when its complexity justifies it.

Do not create empty directories or unnecessary abstractions in advance.

The structure should grow with real responsibilities.

### 19.2 Function Entry Point

`index.ts` is the deployment entry point.

It exports function handlers and scheduled jobs.

It must not become a location for domain business logic.

---

## 20. Environment and Deployment Strategy

Use separate Firebase projects for development, staging, and production.

Each environment must have its own:

- Firebase project configuration.
- Authentication configuration.
- Firestore database.
- Storage configuration.
- Cloud Functions deployment.
- FCM configuration.
- Secrets and external integration credentials.

Never use production credentials in local development.

### 20.1 Local Development

Use Firebase Emulator Suite for local development and integration testing.

The local environment should support the Firebase services needed by the implemented backend modules.

### 20.2 Deployment

Backend deployment must be repeatable and controlled.

Recommended deployment sequence:

1. Validate TypeScript.
2. Run formatting and lint checks.
3. Run unit tests.
4. Run emulator integration tests.
5. Build the Functions project.
6. Review Firestore Rules and index changes.
7. Deploy to the development or staging environment.
8. Run smoke tests.
9. Deploy to production only through an approved release process.

Production deployment must not be triggered automatically by an unreviewed local change.

---

## 21. Future Migration Strategy

Firebase-first must not mean Firebase-dependent business logic.

The architecture preserves migration options through:

- Pure TypeScript domain entities and policies.
- Application use cases independent of Firebase SDKs.
- Repository interfaces.
- Infrastructure adapters.
- Stable application commands and results.
- Explicit API contracts.
- No Firestore types in domain entities.
- No Firebase Callable types in application use cases.

If Fusha later requires a standalone REST backend, a new delivery and infrastructure layer can expose the same application use cases.

Potential future platforms include NestJS or another TypeScript server framework.

A migration may require replacing:

- Firestore repositories.
- Authentication adapters.
- Storage adapters.
- Notification adapters.
- Transaction implementations.
- Function entry points.

It should not require rewriting the marketplace's core business rules merely because the infrastructure changes.

Migration is a future option, not an MVP requirement.

---

## 22. Implementation Phases

The backend should be implemented incrementally.

### Phase 1 — Foundation

- Initialize the TypeScript Functions project.
- Configure Node.js runtime and package management.
- Configure TypeScript, linting, and formatting.
- Establish domain, application, and infrastructure boundaries.
- Initialize Firebase Admin SDK through a controlled infrastructure entry point.
- Configure Firebase Emulator Suite.
- Establish shared error and result conventions.

### Phase 2 — Identity and Providers

- Authentication integration.
- User identity access.
- Platform role authorization.
- Business and Organizer memberships.
- Provider applications.
- Provider approval operations.

### Phase 3 — Catalog and Publishing

- Activity and category persistence.
- Activity versions.
- Activity review.
- Provider and Activity publication policies.
- Publishing and suspension operations.

### Phase 4 — Scheduling and Bookings

- Schedule persistence.
- Capacity policies.
- Booking creation.
- Request Booking temporary holds.
- Instant Booking.
- Approval and rejection.
- Cancellation for both booking flows.
- Expiration processing.
- Bounded expiration reconciliation.
- Idempotency and concurrency tests.

### Phase 5 — Tickets and Attendance

- Ticket issuance.
- Secure QR token generation.
- Ticket validation.
- Participant-level check-in.
- Participant attendance tracking.
- Attendance finalization.
- Check-in authorization and audit records.
- Attendance concurrency and lifecycle tests.

### Phase 6 — Marketplace Engagement

- Discovery queries.
- Favorites.
- Reviews.
- Complaints and other approved MVP engagement features.

### Phase 7 — Notifications and Operations

- Notification persistence.
- FCM delivery.
- Scheduled processing.
- Observability.
- Operational monitoring.
- Deployment automation.

Implementation order may be adjusted when dependencies require it, but booking, capacity, and attendance integrity must not be postponed until after their respective features are exposed to users.

---

## 23. Architectural Guardrails

The following rules are mandatory:

1. Business logic must not live inside Flutter applications.
2. Domain logic must not depend on Firebase SDKs.
3. Cloud Function handlers must remain thin.
4. Sensitive state transitions must execute on trusted backend infrastructure.
5. Firestore Security Rules must default to deny.
6. Admin SDK operations must enforce authorization explicitly.
7. Booking and capacity updates must be atomic.
8. Request Booking holds must expire according to trusted server time.
9. Expired holds must not be treated as valid capacity reservations.
10. Instant Booking must not create a separate temporary hold or CapacityReservation.
11. Idempotency is mandatory for retryable booking operations.
12. Capacity counters must never be modified directly by clients.
13. Provider approval and Activity approval must remain separate.
14. Only the publishing workflow may publish an Activity.
15. QR codes must not expose sensitive personal or Booking data.
16. Check-in must be authorized, atomic, and idempotent.
17. External side effects must not run inside Firestore transaction callbacks.
18. Notifications must not be the source of truth for business state.
19. Audit records must be protected from ordinary client modification.
20. Firestore collection paths must remain consistent with `DATA_MODEL.md`.
21. New abstractions must solve an actual architectural requirement.
22. Microservices and distributed counters must not be introduced without a justified architectural review.
23. Capacity allocation must never proceed when expired reservation reconciliation has exceeded its configured safe batch limit.
24. Every capacity-sensitive transaction must validate current persisted state before writing.
25. Administrative authorization must not rely exclusively on potentially stale custom claims.
26. Scheduled expiration processing must be idempotent and safe under overlapping executions.
27. Pending Booking cancellation must distinguish between an active unexpired hold and an expired hold.
28. Provider rejection after hold expiration must transition the Booking to `Expired`, not `Rejected`.
29. Eligible Confirmed Request Booking cancellation must transition its CapacityReservation from `Converted` to `Released` and decrease `confirmedQuantity` exactly once.
30. Eligible Confirmed Instant Booking cancellation must decrease `confirmedQuantity` exactly once without requiring a CapacityReservation.
31. Completed and NoShow Bookings must not release allocated capacity through ordinary cancellation or attendance finalization.
32. Every CapacityReservation transition must have a corresponding valid Booking transition and Schedule counter adjustment where applicable.
33. Inconsistent Booking and CapacityReservation states must be detected and handled through controlled reconciliation rather than blind capacity updates.
34. Attendance must be tracked independently for each eligible BookingParticipant.
35. A Booking must not be finalized as `NoShow` if at least one eligible participant has been checked in.
36. A Booking with partial attendance must be finalized as `Completed` after the attendance window closes.
37. A Booking may be finalized as `NoShow` only when all eligible participants are recorded as `NoShow` after the attendance window closes.
38. Attendance finalization must use trusted server time and be safe under retries and overlapping executions.
39. Ticket status and participant attendance status must remain separate concepts.
40. A Booking-level QR scan must not automatically check in every participant.
41. Participant attendance changes must not retroactively modify reserved capacity.
42. Attendance corrections and administrative capacity adjustments must use explicitly authorized, audited operations.
43. Participant-based attendance finalization must transition eligible `NotCheckedIn` participants to `NoShow` only after the applicable attendance window closes.
44. Attendance finalization must preserve existing `CheckedIn` and `NoShow` participant records during ordinary processing.
45. A Booking with an empty or incomplete eligible participant set must not be automatically finalized as `NoShow`.
46. The eligible participant set must remain stable from attendance finalization claim acquisition until successful completion or authorized recovery.
47. Participant check-in and attendance finalization must coordinate through the same parent Booking document using trusted transactions.
48. Once attendance finalization enters `InProgress`, ordinary participant check-in operations must not commit.
49. Attendance finalization must use a unique claim ID and a server-managed lease.
50. Every successful claim acquisition or reclamation must generate a new unique claim ID.
51. A worker may commit participant attendance changes only while its claim ID is current and its lease remains valid.
52. Claim ownership and lease validity must be verified inside every transaction that commits participant attendance changes.
53. A worker that loses its claim or lease must stop processing and must not commit additional participant updates.
54. Attendance finalization must process large participant sets in bounded, retry-safe batches.
55. A replacement worker must resume from authoritative persisted participant records without overwriting previously committed attendance.
56. A Booking must not transition to `Completed` or `NoShow` until the complete eligible participant set has been reconciled.
57. Successful participant-based finalization must set `attendanceFinalizationStatus` to `Completed` and populate `attendanceFinalizedAt`.
58. Active attendance finalization claim fields must be cleared only after successful completion, with execution history retained in audit records.
59. `attendanceFinalizationStatus` must remain independent of the commercial Booking lifecycle status.
60. A Booking that does not require participant-level attendance must follow its explicit booking-level attendance policy and must not be processed as an empty participant-based Booking.
61. Attendance finalization workers must be internal trusted backend operations and must not be directly executable by untrusted clients.

---

## 24. Related Documents

| Document | Responsibility |
|---|---|
| `docs/product/PRD.md` | Product scope, roles, requirements and workflows |
| `docs/backend/DATA_MODEL.md` | Domain entities, relationships, fields and Firestore structure |
| `docs/backend/BACKEND_ARCHITECTURE.md` | Backend architecture, layers, modules and infrastructure |
| `docs/backend/SECURITY_RULES.md` | Firestore and Storage access policies and authorization matrix |
| `docs/backend/API_CONTRACTS.md` | Function operations, payloads, response schemas and error contracts |

---

## 25. Document Status

This document defines the proposed backend architecture for Fusha's MVP.

The architectural direction is:

**Firebase-first Modular Monolith using TypeScript, Cloud Functions Gen 2, and Cloud Firestore.**

The architecture preserves separation between business logic and Firebase infrastructure while providing a reliable foundation for provider management, activity publishing, booking, capacity management, ticketing, participant-level attendance, and marketplace operations.

Booking, capacity, and attendance architecture are first-class parts of this design.

Detailed implementation limits, transaction behavior, expiration reconciliation, attendance finalization, and concurrency guarantees must be validated through integration tests and load testing before production release.

The participant-level attendance policy must remain consistent with `docs/backend/DATA_MODEL.md` before implementation.
