# Fusha — Data Model

> **Document status:** Updated Draft — Approved Domain Decisions Incorporated
> **Product:** Fusha | فُسحة
> **Product type:** Multi-Vendor Experiences & Activities Marketplace
> **Target market:** Palestine
> **Primary data platform:** Cloud Firestore
> **Backend operations:** Trusted Backend / Cloud Functions

---

## 1. Purpose

This document defines the domain entities, relationships, and proposed Firestore data structure for Fusha.

Its purpose is to establish a consistent data foundation for:

- Customer Mobile Application.
- Business and Organizer Management.
- Platform Administration.
- Activity discovery and publishing.
- Scheduling and availability.
- Booking and reservation workflows.
- Tickets and attendance management.
- Provider approval and Activity moderation.

This document distinguishes between:

1. **Domain Model:** Business concepts and their relationships.
2. **Firestore Structure:** How those concepts are stored and queried.
3. **Data Integrity Rules:** Constraints enforced by trusted backend operations.

The proposed Firestore structure is an implementation design, not a requirement to create one collection for every domain entity.

The final storage structure must be validated against actual application queries, security requirements, and transactional workflows before implementation.

---

## 2. Data Modeling Principles

### 2.1 Domain Separation

Each entity must represent a clear business concept.

Examples:

- A User represents an authenticated platform identity.
- A Business represents a business operating on Fusha.
- An Organizer represents an event or activity organizer.
- An Activity represents a discoverable experience or service.
- An ActivitySchedule represents a bookable date or session.
- A Booking represents a customer's reservation.

These entities must not be conflated.

### 2.2 Firestore-Oriented Design

The model must account for:

- Document-based storage.
- Collection and subcollection access patterns.
- Query limitations and composite indexes.
- Denormalization for frequently displayed information.
- Transactional consistency for booking and capacity operations.
- Firestore document size and write limitations.

### 2.3 Data Ownership

Each entity must have a clearly defined owner and authorization boundary.

Clients must not be allowed to modify protected fields directly.

### 2.4 Immutable Booking Snapshots

A submitted or confirmed Booking must retain the relevant Activity, schedule, location, pricing, and applicable booking-policy information as it was presented when the Booking was created.

Changes to an Activity must not silently rewrite existing Booking details.

### 2.5 Server-Enforced Integrity

Critical business rules must be enforced by trusted backend operations, not only by Flutter validation or Firestore Security Rules.

### 2.6 Explicit State Transitions

Entities with lifecycle states must have documented and authorized transitions.

Clients must not be allowed to assign arbitrary status values.

### 2.7 Shared Model Boundaries

Only models and contracts genuinely shared across multiple applications belong in `packages/shared_models`.

Application-specific feature models, Firestore DTOs, and presentation models must remain in their owning applications or features.

---

## 3. Domain Overview

The domain is organized into the following areas:

| Domain | Main entities |
|---|---|
| Identity & Access | User, PlatformRole, Permission |
| Providers | Business, Organizer, BusinessMembership, OrganizerMembership |
| Business Locations | Branch, Location |
| Marketplace | Activity, ActivityCategory, ActivityVersion |
| Scheduling | ActivitySchedule |
| Booking | Booking, BookingParticipant |
| Capacity | CapacityReservation |
| Tickets | Ticket, CheckIn |
| Moderation | ProviderApplication, ActivityReview |
| Platform Operations | AuditLog |

Supporting domains include:

- Favorites.
- Reviews.
- Notifications.
- Analytics.

Their detailed models and MVP inclusion must be defined separately.

### 3.1 Main Relationships

- A User may have multiple provider memberships.
- A Business may have multiple Branches.
- A Business may have multiple Activities.
- An Organizer may operate independently or be associated with a Business.
- An Organizer may manage multiple Activities.
- An Activity belongs to one provider.
- An Activity may be associated with a Business Branch or an independent location.
- An Activity may have multiple ActivityVersions.
- An Activity may have multiple ActivitySchedules.
- An ActivitySchedule owns its capacity accounting.
- A Booking belongs to one Customer and one Activity.
- A Booking may reference one selected ActivitySchedule.
- A Booking may contain multiple BookingParticipants.
- A Request Booking may have one temporary CapacityReservation.
- A confirmed Booking consumes confirmed capacity.
- A Booking may have one booking-level Ticket and/or multiple participant Tickets.
- Each BookingParticipant has an independent attendance state when participant-level attendance applies.
- Booking lifecycle status is derived from the applicable booking and attendance workflow, not from a single participant's state.

---

## 4. Identity & Access

### 4.1 User

Represents an authenticated platform user.

Proposed fields:

| Field | Type | Description |
|---|---|---|
| id | String | Document ID, associated with authentication identity |
| displayName | String | User's display name |
| email | String? | Email address |
| phoneNumber | String? | Phone number |
| photoUrl | String? | Profile image |
| accountStatus | String | Account status |
| createdAt | Timestamp | Creation date |
| updatedAt | Timestamp | Last update |

Proposed account statuses:

- Active
- Suspended
- Disabled

Authentication credentials must be managed by the authentication provider, not stored in User documents.

The User entity represents identity and account information. Provider profiles and provider memberships must remain separate.

### 4.2 Platform Roles

Platform-level roles determine access to administrative capabilities.

Initial role concepts:

- Customer
- Admin
- Super Admin

Provider-specific permissions must not be represented only through global user roles.

A user may manage one Business while remaining an ordinary Customer in the marketplace.

Platform-level authorization must be enforced through trusted claims, protected role records, or another secure authorization mechanism.

### 4.3 BusinessMembership

Connects a User to a Business and defines their permissions.

Proposed fields:

| Field | Type | Description |
|---|---|---|
| id | String | Document ID |
| businessId | String | Associated Business |
| userId | String | Associated User |
| role | String | Owner, Manager, Staff |
| permissions | List<String> | Explicit permissions |
| status | String | Membership status |
| createdAt | Timestamp | Creation date |
| updatedAt | Timestamp | Last update |

Membership statuses:

- Pending
- Active
- Suspended
- Revoked

A Business must support multiple users with different permissions.

### 4.4 OrganizerMembership

Connects a User to an Organizer.

Proposed fields:

- id
- organizerId
- userId
- role
- permissions
- status
- createdAt
- updatedAt

An Organizer may have multiple associated users.

BusinessMembership and OrganizerMembership must not be conflated because they represent different provider relationships.

### 4.5 Organizer-Business Relationship

An Organizer may be:

- Independent.
- Associated with a Business.
- Authorized to operate activities in collaboration with a Business.

This relationship must be represented explicitly.

An Organizer does not require a Business to exist or operate on Fusha.

The association must not automatically grant every Business member access to the Organizer or vice versa.

---

## 5. Provider Domain

### 5.1 Business

Represents a business registered on Fusha.

Proposed fields:

| Field | Type | Description |
|---|---|---|
| id | String | Document ID |
| name | String | Business name |
| description | String | Business description |
| logoUrl | String? | Logo |
| coverImageUrl | String? | Cover image |
| contactPhone | String? | Contact phone |
| contactEmail | String? | Contact email |
| categories | List<String> | Business categories |
| approvalStatus | String | Provider approval status |
| ownerUserId | String | Initial owner |
| createdAt | Timestamp | Creation date |
| updatedAt | Timestamp | Last update |

Provider approval statuses:

- Draft
- Pending Review
- Approved
- Rejected
- Suspended

A Business must be approved before it can submit Activities for marketplace publication.

A Business may have multiple Branches and multiple authorized members.

Suspending a Business must prevent unauthorized new marketplace publication and booking operations according to platform policy.

### 5.2 Organizer

Represents an independent event or activity organizer.

Proposed fields:

| Field | Type | Description |
|---|---|---|
| id | String | Document ID |
| name | String | Organizer name |
| description | String | Organizer description |
| logoUrl | String? | Logo |
| contactPhone | String? | Contact phone |
| contactEmail | String? | Contact email |
| approvalStatus | String | Provider approval status |
| createdAt | Timestamp | Creation date |
| updatedAt | Timestamp | Last update |

Provider approval statuses:

- Draft
- Pending Review
- Approved
- Rejected
- Suspended

An Organizer may operate independently or have an explicit association with a Business.

Organizer approval is separate from Business approval.

An independent Organizer must not be forced to create or associate a Business.

### 5.3 ProviderApplication

Represents a provider onboarding or verification request.

Provider onboarding approval is separate from Activity publication approval.

Proposed fields:

| Field | Type | Description |
|---|---|---|
| id | String | Document ID |
| applicantUserId | String | Applicant |
| providerType | String | Business or Organizer |
| providerId | String? | Associated provider, if created |
| applicationData | Map | Submitted application information |
| documentReferences | List<String> | Restricted document references |
| status | String | Application status |
| submittedAt | Timestamp? | Submission date |
| reviewedBy | String? | Admin reviewer |
| reviewedAt | Timestamp? | Review date |
| reviewNotes | String? | Review feedback |
| createdAt | Timestamp | Creation date |
| updatedAt | Timestamp | Last update |

Application statuses:

- Draft
- Pending Review
- Approved
- Rejected
- Changes Requested

Sensitive documents must use restricted storage and access policies.

Provider approval does not automatically approve or publish Activities.

---

## 6. Business Locations

### 6.1 Branch

A Business may have multiple Branches.

Proposed fields:

| Field | Type | Description |
|---|---|---|
| id | String | Document ID |
| businessId | String | Parent Business |
| name | String | Branch name |
| phoneNumber | String? | Branch phone |
| location | Map | Address and coordinates |
| openingHours | Map? | Operating hours |
| status | String | Branch status |
| createdAt | Timestamp | Creation date |
| updatedAt | Timestamp | Last update |

Branch statuses:

- Active
- Inactive
- Suspended

A Branch belongs to exactly one Business.

### 6.2 Location

Location is a reusable value object.

It may contain:

- Country.
- City.
- Area.
- Street or address description.
- Latitude.
- Longitude.
- Optional map reference.

A Location must not automatically imply that it is a Business Branch.

Activities may take place:

- At a Business Branch.
- At an external venue.
- At a temporary event location.
- At another explicitly defined location.

An ActivitySchedule may override the Activity's default location when the actual session location differs.

Location data should support both human-readable addresses and map-based discovery.

---

## 7. Marketplace Domain

### 7.1 Activity

Represents a discoverable experience, event, activity, or bookable service.

Proposed fields:

| Field | Type | Description |
|---|---|---|
| id | String | Document ID |
| title | String | Activity title |
| description | String | Full description |
| categoryId | String | Primary category |
| providerType | String | Business or Organizer |
| providerId | String | Provider document ID |
| branchId | String? | Associated Business Branch |
| defaultLocation | Map? | Default activity location |
| imageUrls | List<String> | Activity images |
| bookingType | String | Instant or Request |
| publicationStatus | String | Activity publication status |
| publishedVersionId | String? | Current published version |
| createdAt | Timestamp | Creation date |
| updatedAt | Timestamp | Last update |

An Activity belongs to one provider.

The provider may be a Business or an Organizer.

An Activity must have an approved provider before it can be submitted for publication.

An Activity may be associated with a Business Branch or an independent/external location.

### 7.2 Activity Categories

Categories organize Activities for discovery and filtering.

Examples:

- Events
- Experiences
- Family Activities
- Restaurants & Food Experiences
- Sports
- Workshops
- Venues

A category may include:

- Name.
- Description.
- Icon reference.
- Image reference.
- Display order.
- Active status.

Categories are managed by authorized platform administrators.

Workshops and educational activities are marketplace categories, not the central product domain.

### 7.3 ActivityVersion

Material Activity changes must be reviewed without silently changing the currently published version.

An ActivityVersion represents a particular revision of an Activity.

Proposed fields:

| Field | Type | Description |
|---|---|---|
| id | String | Version document ID |
| activityId | String | Parent Activity |
| versionNumber | Number | Sequential version number |
| contentSnapshot | Map | Complete revision content |
| submittedBy | String | Submitting User |
| reviewStatus | String | Review status |
| reviewedBy | String? | Admin reviewer |
| reviewNotes | String? | Review feedback |
| createdAt | Timestamp | Creation date |
| submittedAt | Timestamp? | Submission date |
| reviewedAt | Timestamp? | Review date |

Review statuses:

- Draft
- Pending Review
- Approved
- Rejected
- Changes Requested

The Activity references its currently published version through `publishedVersionId`.

A pending revision must not replace the published version before approval.

Material changes include:

- Activity identity.
- Category.
- Location.
- Safety information.
- Essential booking conditions.

Minor changes may follow a less restrictive update policy.

A published Activity may remain visible while a new material revision is under review, unless a safety, compliance, or operational issue requires suspension.

Existing Bookings retain their original snapshots regardless of later Activity revisions.

### 7.4 Activity Publication Status

Proposed statuses:

- Draft
- Pending Review
- Approved
- Published
- Rejected
- Changes Requested
- Suspended
- Archived

Provider approval and Activity approval are separate processes.

An approved provider may create Activity drafts and submit them for review.

Every Activity requires Admin approval before public marketplace visibility and booking.

Publishing must be performed through trusted backend operations.

---

## 8. Scheduling Domain

### 8.1 ActivitySchedule

Represents a bookable date or session associated with an Activity.

Each schedule owns its own capacity accounting.

Proposed fields:

| Field | Type | Description |
|---|---|---|
| id | String | Document ID |
| activityId | String | Parent Activity |
| startsAt | Timestamp | Start date and time |
| endsAt | Timestamp | End date and time |
| timeZone | String | IANA timezone |
| location | Map? | Actual session location |
| capacity | Number? | Total capacity; null may mean unlimited |
| confirmedQuantity | Number | Quantity assigned to confirmed bookings |
| heldQuantity | Number | Quantity reserved by active temporary holds |
| bookingCutoffAt | Timestamp? | Last booking time |
| status | String | Schedule status |
| createdAt | Timestamp | Creation date |
| updatedAt | Timestamp | Last update |

Schedule statuses:

- Scheduled
- Cancelled
- Completed
- Suspended

The schedule must support:

- One-time events.
- Repeated sessions.
- Different capacities.
- Different locations.
- Schedule cancellation.

A schedule may override the Activity's default location.

### 8.2 Capacity Accounting

Capacity is managed independently for each bookable ActivitySchedule.

The following fields represent the capacity state:

- `capacity`: Total available capacity.
- `confirmedQuantity`: Quantity assigned to confirmed bookings.
- `heldQuantity`: Quantity reserved by active temporary holds.

Available capacity is calculated as:

`availableCapacity = capacity - confirmedQuantity - heldQuantity`

For unlimited-capacity schedules, finite capacity counters must not impose an artificial booking limit.

`availableCapacity` is a derived value, not an independently writable source of truth.

The backend must maintain capacity counters consistently.

Clients must never update capacity fields directly.

### 8.3 Capacity Integrity

The backend must guarantee:

- No overbooking.
- No double counting.
- No double release.
- No negative capacity counters.
- Atomic capacity reservation and confirmation.
- Consistency between Booking, CapacityReservation, and ActivitySchedule.

Concurrent requests for the same schedule must be handled through transactional or equivalent concurrency-safe operations.

Expired holds must not be accepted as valid reservations.

Before processing a capacity operation, the backend must account for expired reservations associated with the affected schedule so stale holds do not continue consuming availability.

A trusted expiration process must also reconcile expired reservations and update schedule counters.

---

## 9. Booking Domain

### 9.1 Booking

Represents a customer's reservation.

A Booking may cover one or more participants, seats, units, or another bookable quantity depending on the Activity policy.

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
| status | String | Booking status |
| paymentMethod | String? | Selected payment method |
| paymentStatus | String | Payment status |
| activitySnapshot | Map | Activity details at booking time |
| scheduleSnapshot | Map? | Schedule details at booking time |
| locationSnapshot | Map? | Location details at booking time |
| bookingPolicySnapshot | Map? | Applicable booking, cancellation, and attendance policy snapshot |
| eligibleParticipantCount | Number? | Number of participants eligible for attendance; null when participant-level attendance does not apply |
| checkedInParticipantCount | Number? | Number of eligible participants successfully checked in; null when participant-level attendance does not apply |
| idempotencyRecordId | String? | Associated IdempotencyRecord for the Booking creation request, when applicable |
| attendanceWindowEndsAt | Timestamp? | Trusted final time at which attendance may be recorded |
| attendanceFinalizationStatus | String | Participant attendance finalization state: NotRequired, NotStarted, InProgress, or Completed |
| attendanceFinalizationClaimId | String? | Unique fencing token identifying the current finalization worker claim |
| attendanceFinalizationClaimedAt | Timestamp? | Server timestamp when the current finalization claim was acquired |
| attendanceFinalizationLeaseExpiresAt | Timestamp? | Server timestamp when the current worker claim expires and may be reclaimed |
| attendanceFinalizedAt | Timestamp? | Server timestamp when participant attendance finalization successfully completed |
| confirmedAt | Timestamp? | Confirmation date |
| cancelledAt | Timestamp? | Cancellation date |
| expiredAt | Timestamp? | Expiration date |
| createdAt | Timestamp | Creation date |
| updatedAt | Timestamp | Last update |

**Participant set and attendance counters**

For Bookings that use participant-level attendance, the eligible participant set must be finalized when the Booking becomes `Confirmed`. At that point, the backend initializes `eligibleParticipantCount` to the number of eligible BookingParticipant records and initializes `checkedInParticipantCount` to zero. For Bookings without participant-level attendance, both fields are null.

The eligible participant set is immutable after confirmation during ordinary operations. An exceptional eligibility correction requires an authorized and audited backend operation that updates the affected participant records and both counters consistently in a trusted transaction. The backend must maintain `0 <= checkedInParticipantCount <= eligibleParticipantCount`.

A successful first transition of a participant from `NotCheckedIn` to `CheckedIn` increments `checkedInParticipantCount` exactly once in the same transaction that updates the participant, Ticket, CheckIn and audit record. Repeated requests and participants already checked in must not increment it again.

`BookingParticipant` records remain the source of truth. The counters are transactional projections used for booking-level Ticket-state decisions and consistency checks; they do not replace participant records when attendance finalization derives the Booking outcome. If a counter disagrees with the authoritative participant records, the backend must block dependent Ticket transitions and run an explicit reconciliation rather than infer a result.

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
| Confirmed | Booking has been confirmed and is awaiting its applicable service or attendance outcome |
| Rejected | Provider rejected the request |
| Cancelled | Booking was cancelled under the applicable cancellation policy |
| Expired | Request or temporary hold expired before confirmation |
| Completed | The booking's applicable attendance or service workflow was completed |
| NoShow | All eligible participants failed to attend, or the applicable booking-level attendance policy determined a no-show |

Payment statuses:

- Unpaid
- Paid
- Refunded
- Partially Refunded

Booking status and payment status are independent.

A Booking must not become `Completed` or `NoShow` merely because one participant's attendance state changes.

For activities using participant-level attendance, Booking finalization is determined from all eligible BookingParticipants after the applicable attendance window closes.

For activities that do not create BookingParticipant records, attendance must follow an explicitly defined booking-level check-in or service-completion policy. The absence of participant records must never be interpreted automatically as a no-show.

`attendanceWindowEndsAt` represents the trusted final attendance time applicable to this Booking. It must be derived from the applicable ActivitySchedule and attendance policy, with the relevant policy preserved in the Booking snapshot when required.

`attendanceFinalizedAt` is written by the trusted backend when finalization succeeds. It must not be writable by customers or ordinary provider clients.

Participant Attendance Finalization State:

- `NotRequired`: The Booking does not use participant-level attendance finalization.
- `NotStarted`: Participant-level attendance finalization is required but has not been claimed.
- `InProgress`: A trusted backend worker has claimed the Booking and is processing attendance finalization.
- `Completed`: All eligible participant records have been reconciled and Booking attendance finalization has completed successfully.

`attendanceFinalizationStatus` represents the processing state of participant attendance finalization. It is independent of `Booking.status`.

A finalization process may successfully complete with either Booking status `Completed` or `NoShow`, depending on the eligible participants' attendance outcomes.

`attendanceFinalizationStatus = Completed` means the finalization operation has completed successfully; it does not mean that the Booking itself must have status `Completed`.

Integrity rules:

1. Participant-level attendance Bookings must initialize `attendanceFinalizationStatus` to `NotStarted`.
2. Bookings that do not use participant-level attendance must use `NotRequired` and follow their explicitly defined booking-level attendance or service-completion policy.
3. `attendanceFinalizationClaimId`, `attendanceFinalizationClaimedAt`, and `attendanceFinalizationLeaseExpiresAt` must be populated when a claim is acquired.
4. A new worker may reclaim an expired `InProgress` claim using a new unique claim ID.
5. Only the worker holding the current claim ID may commit finalization progress.
6. An expired claim does not reopen check-in. Check-in remains blocked while the status is `InProgress`.
7. `attendanceFinalizedAt` must be set only when the status transitions successfully to `Completed`.
8. Finalization claim fields must be managed exclusively by trusted backend operations.
9. `attendanceFinalizationClaimId`, `attendanceFinalizationClaimedAt`, and `attendanceFinalizationLeaseExpiresAt` must be populated only while `attendanceFinalizationStatus` is `InProgress`.
10. When finalization successfully reaches `Completed`, the active claim fields must be cleared. The finalization audit record must preserve the relevant execution details.
11. For `NotRequired` and `NotStarted`, all active claim fields and `attendanceFinalizedAt` must remain null.
12. A completed participant attendance finalization must never return to `NotStarted` or `InProgress` through ordinary operations.

### 9.2 BookingParticipant

Represents an individual participant within a group Booking.

Participant details may be optional depending on the Activity policy.

Proposed fields:

| Field | Type | Description |
|---|---|---|
| id | String | Participant document ID |
| bookingId | String | Parent Booking ID |
| displayName | String? | Participant display name |
| contactDetails | Map? | Contact information when required |
| participantReference | String? | Participant reference within the Booking |
| ticketId | String? | Individual Ticket ID, only when individual tickets are required |
| attendanceStatus | String | Individual attendance state |
| checkedInAt | Timestamp? | Participant check-in timestamp |
| checkedInByUserId | String? | Authorized user who recorded check-in |
| createdAt | Timestamp | Creation date |
| updatedAt | Timestamp | Last update |

Attendance statuses:

- `NotCheckedIn`
- `CheckedIn`
- `NoShow`

Attendance rules:

1. Every participant has an independent attendance state.
2. A participant starts with `NotCheckedIn`.
3. A successful individual check-in changes that participant to `CheckedIn`.
4. A participant may be marked `NoShow` only through an authorized backend operation after the applicable attendance window closes.
5. A participant who has been checked in must not subsequently be marked `NoShow` through ordinary finalization.
6. Attendance changes must be recorded with the responsible user and timestamp.
7. Attendance state must not be inferred from another participant's state.
8. A participant does not require an individual Ticket unless the Activity's ticketing policy requires one.

A Booking does not always require participant records.

For example, a restaurant table reservation may be represented by a booking quantity and table details instead.

When participant records exist, the backend must use the eligible participant set defined for the Booking's attendance policy. It must not silently ignore a participant or treat a missing participant record as an attended or absent participant.

The participant count and Booking quantity must follow the applicable Activity booking-unit policy.

### 9.3 Booking Integrity

The backend must:

1. Validate Activity and schedule availability.
2. Validate provider and Activity eligibility.
3. Validate booking policies.
4. Validate requested capacity.
5. Prevent overbooking using atomic transactions or an equivalent concurrency-safe mechanism.
6. Protect against duplicate submissions using idempotency keys.
7. Preserve Booking snapshots.
8. Record status transitions.
9. Prevent unauthorized status modifications.
10. Ensure capacity is released or converted exactly once.
11. Keep Booking lifecycle state separate from participant attendance state.
12. Prevent attendance finalization before the applicable attendance window closes.
13. Ensure a participant's committed `CheckedIn` state cannot be overwritten by a later no-show operation.
14. Finalize Booking attendance only once, using an idempotent trusted backend operation.

### 9.4 Booking Capacity Management

Fusha supports two booking flows:

- Request Booking.
- Instant Booking.

Both flows use the same schedule-level capacity accounting, but their reservation and confirmation processes are different.

#### 9.4.1 Request Booking — Temporary Capacity Hold

When a customer submits a Request Booking:

1. The backend validates Activity eligibility.
2. The backend validates schedule availability.
3. The backend validates requested quantity.
4. The backend reserves the requested capacity through a temporary hold.
5. The backend creates the Booking with `Pending` status.
6. The backend creates an active CapacityReservation.
7. The backend sets the CapacityReservation `expiresAt` timestamp.
8. The provider is notified to review the request.

All capacity validation and reservation operations must be performed atomically.

The default hold duration is 30 minutes.

The duration must be configurable according to platform and Activity policies, subject to platform-defined limits.

While the hold is active, its quantity contributes to `heldQuantity`.

#### 9.4.2 Request Booking — Provider Approval

When the provider approves a Pending Booking before hold expiration:

1. Validate provider authorization.
2. Verify that the CapacityReservation is active.
3. Verify that the hold has not expired.
4. Convert the held quantity into confirmed quantity.
5. Decrease `heldQuantity`.
6. Increase `confirmedQuantity`.
7. Update the CapacityReservation state to `Converted`.
8. Change Booking status to `Confirmed`.
9. Finalize the eligible BookingParticipant set and initialize `eligibleParticipantCount` to its exact size and `checkedInParticipantCount` to zero; set both counters to null when participant-level attendance does not apply.
10. Record `confirmedAt`.

Booking confirmation, participant-set finalization, attendance counter initialization, CapacityReservation conversion and Schedule counter updates must be performed atomically.

A provider must not confirm a Booking after its hold has expired.

#### 9.4.3 Request Booking — Rejection and Cancellation

When the provider rejects a Booking:

- Verify that the Booking is still Pending.
- Verify that its CapacityReservation is active and unexpired.
- Release the associated active hold.
- Decrease `heldQuantity` exactly once.
- Update the CapacityReservation state to `Released`.
- Change Booking status to `Rejected`.

If the hold has already expired, the operation must follow expiration reconciliation and must not release the same quantity twice. The Booking must not be rejected through a stale active-hold path after expiration has already been applied.

When a customer cancels a Booking:

- Validate the applicable cancellation policy.
- If the Booking has an active Request Booking hold, release held capacity and mark the reservation `Released`.
- If the Booking is confirmed and its capacity has been converted or directly assigned, release confirmed capacity only when the cancellation policy allows cancellation and the activity's capacity policy permits that release.
- For a confirmed Request Booking, the associated `Converted` reservation must be transitioned to `Released` exactly once when the cancellation is valid.
- For an Instant Booking, release confirmed capacity directly through the cancellation transaction; there is no CapacityReservation.
- Update Booking status to `Cancelled`.
- Record `cancelledAt`.

Capacity release must be idempotent.

Repeated cancellation or release operations must not decrement capacity more than once.

A cancellation after the activity has started or completed must follow an explicit operational policy. Attendance recording, `Completed`, and `NoShow` finalization must not be treated as ordinary cancellation or automatically release consumed capacity.

#### 9.4.4 Request Booking — Hold Expiration

Temporary hold expiration must be enforced by trusted backend processes.

The default expiration period is 30 minutes.

The backend must:

- Check the CapacityReservation `expiresAt` before accepting provider approval.
- Exclude expired reservations from valid capacity.
- Release expired capacity through trusted backend processing.
- Update Booking status to `Expired` when the Booking is still Pending and the hold expires.
- Update CapacityReservation state to `Expired`.
- Decrease `heldQuantity` exactly once.
- Prevent an expired reservation from being converted into a confirmed Booking.

Expiration must not depend on a Flutter Timer.

Firestore TTL may assist with eventual cleanup of obsolete documents, but must not be responsible for releasing capacity.

A scheduled backend process may periodically process expired reservations.

Relevant booking and capacity operations must also enforce expiration checks so a delayed cleanup process does not make expired holds valid.

#### 9.4.5 Instant Booking — Direct Confirmation

Instant Booking does not require a separate Temporary Capacity Hold.

The backend must perform the entire booking and capacity operation within a single server-side atomic transaction.

The transaction must:

1. Validate Activity eligibility.
2. Validate schedule availability.
3. Validate requested quantity.
4. Verify sufficient available capacity.
5. Create the Booking with `Confirmed` status.
6. Create or finalize the eligible BookingParticipant records according to the Activity policy.
7. Initialize `eligibleParticipantCount` to the exact eligible participant count and `checkedInParticipantCount` to zero; set both counters to null when participant-level attendance does not apply.
8. Increase `confirmedQuantity`.
9. Record `confirmedAt`.
10. Persist the Booking, participant set, attendance counters and capacity changes together.

If any operation fails, the entire transaction must be rolled back.

No partial Booking or incomplete capacity update may remain.

Provider approval and hold expiration do not apply to Instant Booking.

#### 9.4.6 Unified Capacity Calculation

For a finite-capacity schedule:

`availableCapacity = capacity - confirmedQuantity - heldQuantity`

Where:

- `capacity` is the total capacity.
- `confirmedQuantity` is the quantity assigned to confirmed Bookings.
- `heldQuantity` is the quantity reserved by active, unexpired Request Booking holds.

The backend must ensure that expired holds are reconciled before calculating capacity for a new reservation.

An expired hold must not continue consuming availability merely because its cleanup process has not yet run.

#### 9.4.7 Idempotency and Concurrency

Booking submission, provider approval, rejection, cancellation, and capacity release operations must be idempotent.

The backend must prevent:

- Duplicate Bookings caused by retries.
- Duplicate capacity reservations.
- Double confirmation.
- Double capacity release.
- Confirmation of expired holds.
- Overbooking under concurrent requests.

A CapacityReservation must be converted or released at most once.

All related state transitions must be enforced server-side.

### 9.5 CapacityReservation

Represents the reservation of capacity associated with a Booking.

A CapacityReservation is required for Request Booking temporary holds.

Instant Booking does not create a separate temporary hold.

Proposed fields:

| Field | Type | Description |
|---|---|---|
| id | String | Document ID |
| bookingId | String | Associated Booking |
| activityId | String | Associated Activity |
| scheduleId | String | Associated ActivitySchedule |
| quantity | Number | Reserved quantity |
| status | String | Reservation state |
| expiresAt | Timestamp | Hold expiration timestamp |
| convertedAt | Timestamp? | Conversion timestamp |
| releasedAt | Timestamp? | Release timestamp |
| createdAt | Timestamp | Creation date |
| updatedAt | Timestamp | Last update |

Reservation statuses:

- Active
- Converted
- Released
- Expired

Lifecycle:

- `Active`: Temporary capacity is reserved.
- `Converted`: Temporary hold became confirmed capacity.
- `Released`: Capacity was released after rejection or valid cancellation.
- `Expired`: Hold expired and its held capacity was released.

A reservation must not be converted or released more than once.

The reservation record, Booking state, and ActivitySchedule capacity counters must remain consistent.

---

## 10. Tickets & Check-in

### 10.1 Ticket

Tickets represent authorization to attend an Activity or schedule.

A Booking may have:

- One booking-level QR reference.
- Individual participant Tickets.
- Both, depending on Activity policy.

A restaurant reservation may only need a booking-level reference.

An event with individual participants may require individual Tickets.

Proposed fields:

| Field | Type | Description |
|---|---|---|
| id | String | Ticket document ID |
| bookingId | String | Associated Booking |
| participantId | String? | Associated participant; required for participant Tickets |
| activityId | String | Associated Activity |
| scheduleId | String? | Associated schedule |
| tokenHash | String | Secure token hash or reference |
| ticketType | String | Booking or Participant |
| status | String | Ticket status |
| issuedAt | Timestamp | Issuance date |
| usedAt | Timestamp? | Date when the ticket's applicable check-in scope was consumed |

Ticket types:

- `Booking`
- `Participant`


Ticket statuses:

- `Valid`
- `PartiallyUsed`
- `Used`
- `Cancelled`
- `Expired`

Ticket rules:

1. A booking-level Ticket represents the Booking as a whole, but scanning it must not automatically mark all participants as checked in.
2. A participant Ticket is associated with exactly one BookingParticipant.
3. An individual participant Ticket is created only when the Activity ticketing policy requires it.
4. Ticket status is independent of participant attendance status.
5. A Ticket becoming `Used` does not, by itself, prove that every participant in the Booking attended.
6. A booking-level Ticket may authorize multiple independent participant check-ins while its status is `Valid` or `PartiallyUsed`.
7. A booking-level Ticket becomes `PartiallyUsed` after at least one eligible participant is checked in while other eligible participants remain unchecked.
8. A booking-level Ticket becomes `Used` only after all eligible participants have successfully checked in.
9. A booking-level Ticket becomes `Expired` when the attendance window closes before all eligible participants have checked in, whether no participant or only some participants were checked in.
10. An unused participant Ticket becomes `Expired` when its applicable attendance window closes.
11. `PartiallyUsed` applies only to booking-level Tickets.
12. A booking-level reservation without participant records may mark its Ticket `Used` after the applicable booking-level check-in operation is successfully completed.
13. A Booking cancellation must invalidate its associated Tickets according to the cancellation policy.
14. An expired or cancelled Ticket must not authorize additional check-ins.
15. Ticket expiration is independent of attendance finalization and must not modify participant attendance records.
16. A Ticket must not become `Used` merely because one participant was checked in when other eligible participants remain.
17. Cancelled or expired Bookings must not produce valid check-in authorization.

Ticket lifecycle transitions:

- `Valid` → `PartiallyUsed`: at least one participant is checked in while other eligible participants remain.
- `Valid` → `Used`: all eligible participants are checked in.
- `Valid` → `Expired`: the attendance window closes before any check-in.
- `PartiallyUsed` → `Used`: all remaining eligible participants are checked in.
- `PartiallyUsed` → `Expired`: the attendance window closes before all eligible participants are checked in.
- `Valid` or `PartiallyUsed` → `Cancelled`: the Booking is cancelled according to policy.

Ticket states `Used`, `Expired`, and `Cancelled` must not be treated as interchangeable.

QR codes must contain an opaque, unpredictable token or secure reference.

They must not contain personal information or sensitive Booking details.

The backend must validate the token and ticket state before accepting a check-in.

### 10.2 CheckIn

A CheckIn records one successful attendance action. It is an auditable record of a successful check-in; failed scans and unfinished group operations are not CheckIn records.

BookingParticipant remains the source of truth for an individual participant's current attendance status.

Proposed fields:

| Field | Type | Description |
|---|---|---|
| id | String | CheckIn document ID |
| ticketId | String? | Associated Ticket, when applicable |
| bookingId | String | Associated Booking |
| participantId | String? | Participant whose attendance was recorded; null for booking-level check-in without participant records |
| activityId | String | Associated Activity |
| scheduleId | String? | Associated schedule |
| checkedInByUserId | String | Authorized staff User |
| checkedInAt | Timestamp | Server timestamp of successful check-in |

**Participant-level attendance**

- Every successful participant check-in updates the corresponding BookingParticipant to `CheckedIn`.
- `checkedInAt` and `checkedInByUserId` are recorded on the participant.
- Exactly one successful CheckIn record and its audit record are created for the first successful transition.
- A participant must not be checked in more than once through concurrent or repeated requests.
- A `NoShow` outcome must not create a successful CheckIn record.

**Transaction coordination and validation**

Every participant check-in is executed by a trusted backend transaction coordinated by the `attendance` application use case. The transaction must read the parent Booking, the participant, the applicable Ticket, and the idempotency/progress records before performing any write.

The backend must validate:

- Authenticated staff identity, current provider membership and required permission.
- Booking status is `Confirmed`.
- The attendance window is open according to trusted backend time.
- `attendanceFinalizationStatus` is `NotStarted`.
- The participant belongs to the Booking and is eligible.
- The participant is not already `CheckedIn`.
- Ticket token, Ticket state, Booking, Activity and Schedule association when a Ticket is used.
- Request idempotency and request-payload hash.

The parent Booking document is the shared transaction coordination point for check-in and attendance-finalization claim acquisition. The check-in transaction must reject a Booking whose finalization is `InProgress` or `Completed`.

**Atomic check-in and Ticket updates**

For the first successful participant transition from `NotCheckedIn` to `CheckedIn`, one transaction must:

1. Update the BookingParticipant attendance state, `checkedInAt`, and `checkedInByUserId`.
2. Increment `Booking.checkedInParticipantCount` exactly once.
3. Update the applicable Ticket.
4. Create the CheckIn record.
5. Create the audit record.
6. Complete the IdempotencyRecord or GroupCheckInOperation participant progress update when applicable.

For a participant Ticket, the Ticket becomes `Used` after its associated participant is successfully checked in.

For a booking-level Ticket, derive the state from the Booking counters after the successful transition:

- `Valid` when `checkedInParticipantCount == 0`.
- `PartiallyUsed` when `0 < checkedInParticipantCount < eligibleParticipantCount`.
- `Used` when `eligibleParticipantCount > 0` and `checkedInParticipantCount == eligibleParticipantCount`.

A booking-level Booking without participant records follows its explicitly defined booking-level check-in policy and does not use participant counters. Its successful booking-level operation creates a CheckIn with `participantId = null`, changes the Ticket to `Used` only after success, and creates the corresponding audit record in the same transaction.

A repeated request or a participant already in `CheckedIn` must not increment the counter or create another CheckIn. It must return the previously stored idempotent result or a stable already-checked-in result.

All required reads must occur before the first write. If any required write fails, the transaction must not partially commit attendance, Booking counters, Ticket, CheckIn, audit, idempotency or participant progress state. External side effects must occur after commit or through an outbox.

**Booking-level QR and group check-in**

- Scanning a booking-level QR must not automatically check in every participant.
- A staff member may check in one participant or perform an explicitly authorized group check-in action.
- Every group action identifies the exact selected participant IDs and rejects duplicate IDs or participants outside the Booking.
- Every participant is processed independently and is recorded separately.
- Unselected participants must never be marked as checked in.

For a booking-level check-in without BookingParticipant records, the backend must apply the explicit booking-level attendance policy in one trusted transaction, create a CheckIn with `participantId = null`, update the Ticket to `Used` only after that operation succeeds, and create the audit record. This path must not read or update participant counters.

Ticket expiration is independent of attendance finalization. When the attendance window closes before all eligible participants have checked in, a booking-level Ticket becomes `Expired`, whether no participant or only some participants checked in. Ticket expiration must not modify participant attendance or Booking counters.

### 10.3 GroupCheckInOperation

A GroupCheckInOperation is a durable record of an explicitly authorized request to check in two or more selected participants against one Booking. A single-participant request uses the individual CheckIn use case. It allows the backend to track, retry and resume large group operations without treating a partially processed group as complete.

Proposed fields:

| Field | Type | Description |
|---|---|---|
| id | String | Group check-in operation document ID |
| bookingId | String | Associated Booking |
| ticketId | String? | Booking-level Ticket used, when applicable |
| requestedByUserId | String | Authorized user who initiated the operation |
| idempotencyRecordId | String | IdempotencyRecord for the group request |
| status | String | Overall operation state |
| selectedParticipantCount | Number | Number of unique selected participants |
| initializedParticipantCount | Number | Number of participant progress records created |
| completedParticipantCount | Number | Participants with `Succeeded` or `AlreadyCheckedIn` results |
| failedParticipantCount | Number | Participants currently in a failed progress state |
| createdAt | Timestamp | Creation timestamp |
| startedAt | Timestamp? | First processing start timestamp |
| completedAt | Timestamp? | Completion timestamp |
| updatedAt | Timestamp | Last update timestamp |

Operation statuses:

- `Preparing`: The operation exists and its participant progress records are being initialized. Processing is not allowed yet.
- `Pending`: Every selected participant has a progress record and processing may begin.
- `InProgress`: At least one participant is being processed or has been processed, and work remains.
- `NeedsRetry`: One or more participants encountered retryable failures; successful participants remain committed and must not be reprocessed.
- `Completed`: Every selected participant has a `Succeeded` or `AlreadyCheckedIn` result.
- `Failed`: A non-retryable operation or participant failure prevents completion. Previously committed successful check-ins remain valid and are not rolled back.

Participant progress is stored in a subcollection:

`groupCheckInOperations/{operationId}/participants/{participantId}`

Proposed participant progress fields:

| Field | Type | Description |
|---|---|---|
| participantId | String | Selected BookingParticipant ID; also used as the deterministic progress document ID |
| ticketId | String? | Participant Ticket used for this participant, when applicable |
| status | String | Participant processing state |
| checkInId | String? | Successful CheckIn record, when created |
| failureType | String? | `Retryable` or `Permanent`, when status is `Failed` |
| errorCode | String? | Stable backend error code; no sensitive details |
| processedAt | Timestamp? | Time the participant reached a recorded result |
| updatedAt | Timestamp | Last update timestamp |

Participant progress statuses:

- `Pending`
- `Succeeded`
- `AlreadyCheckedIn`
- `Failed`

**Group operation rules**

1. The operation is created idempotently using the request's IdempotencyRecord. The selected participant list must contain at least two unique IDs and be normalized deterministically before its request hash is calculated; the same key with a different selection must be rejected.
2. The backend creates one progress document per selected participant, using the participant ID as the deterministic document ID. Initialization may use bounded batches. Replaying the same request returns the existing operation and allows trusted recovery processing to resume missing progress-document initialization without creating duplicates.
3. `initializedParticipantCount` is updated safely and the operation may transition from `Preparing` to `Pending` only when every selected participant has a progress document.
4. A progress document may transition from `Pending` to one recorded result only once. Participant attendance, Booking counters, Ticket, CheckIn, audit, progress record and operation counters must be updated in the same participant transaction.
5. `Succeeded` means this operation successfully checked in that participant. `AlreadyCheckedIn` means the participant was already `CheckedIn`; it is an accepted completed result and must not create another CheckIn or increment `checkedInParticipantCount`.
6. A retryable failure may be retried by moving that participant's progress from `Failed` back to `Pending` in a trusted transaction and adjusting the operation counters atomically. Successful participants must never be reset or processed again.
7. A permanent failure makes the operation `Failed`. A transient failure makes it `NeedsRetry`. If a worker stops unexpectedly while progress records remain `Pending`, a trusted recovery process may resume the operation; participant-level transactions make duplicate attempts safe.
8. The operation becomes `Completed` only when `completedParticipantCount == selectedParticipantCount` and `failedParticipantCount == 0`.
9. A partially processed operation must never be reported as `Completed`. Successful participant check-ins are not rolled back if another participant fails.
10. Concurrent workers must use transactionally guarded progress transitions and counter updates, not in-memory locks. Limit parallel processing to avoid unnecessary contention on the parent Booking and operation documents.

### 10.4 IdempotencyRecord

An IdempotencyRecord provides durable duplicate-request protection for state-changing backend operations.

Proposed fields:

| Field | Type | Description |
|---|---|---|
| id | String | Deterministic server-generated document ID derived from the actor, operation name and client idempotency key |
| actorUserId | String | Authenticated user ID or stable trusted system actor identifier |
| operationName | String | Stable backend operation identifier |
| requestHash | String | Hash of the normalized request payload |
| status | String | Idempotency processing state |
| claimId | String? | Unique claim/fencing token for the active processing attempt |
| claimedAt | Timestamp? | Server timestamp when the current claim was acquired |
| leaseExpiresAt | Timestamp? | Server timestamp when the current claim may be reclaimed |
| resourceType | String? | Type of the resulting resource, when applicable |
| resourceId | String? | ID of the resulting resource, such as Booking or GroupCheckInOperation |
| resultCode | String? | Stable result or terminal error code |
| resultSnapshot | Map? | Minimal non-sensitive response data required for idempotent replay |
| createdAt | Timestamp | Creation timestamp |
| updatedAt | Timestamp | Last update timestamp |
| expiresAt | Timestamp? | Retention and cleanup timestamp; null while the operation is InProgress or while a linked GroupCheckInOperation remains unfinished |

Idempotency statuses:

- `InProgress`
- `Completed`
- `Failed`

**Idempotency rules**

1. The document ID is derived server-side from `actorUserId + operationName + idempotencyKey`; the raw client key does not need to be stored in the document.
2. Reusing the same scoped key with a different `requestHash` must be rejected as an idempotency conflict.
3. A `Completed` record returns the previously committed result and must not execute the business operation again.
4. A `Failed` record returns the same stored terminal result and must not execute the operation again.
5. An `InProgress` record with a valid lease returns the current processing state. After lease expiry, a retry may acquire a new unique `claimId` through a transaction and safely resume the operation.
6. The transaction that commits the business result must verify the current `claimId` and update the IdempotencyRecord to `Completed` in the same transaction.
7. Only terminal business failures are stored as `Failed`. Transient infrastructure failures must remain retryable and must not be persisted as permanent business failures.
8. For a GroupCheckInOperation, the idempotent command result is the created operation reference. The IdempotencyRecord becomes `Completed` once the operation has been durably created; the GroupCheckInOperation's own status continues to represent the long-running processing state. Replaying the command returns that same operation reference and must not create a second operation.
9. `resultSnapshot` must contain only the minimum non-sensitive data needed to replay the result. It must not duplicate personal data, QR tokens, credentials or other secrets.
10. `expiresAt` is used for retention/cleanup only. It must remain null while the record is `InProgress` and while a linked GroupCheckInOperation is unfinished. After the operation reaches a terminal state, retention must exceed the maximum supported client retry window. Expiration of an IdempotencyRecord must not undo a committed business operation; domain-level uniqueness and state validation must continue to protect the resource after the idempotency record is cleaned up.

### 10.5 Attendance and Ticket State Separation

Attendance and Ticket lifecycle are separate concepts.

- `BookingParticipant.attendanceStatus` is authoritative for participant attendance.
- Ticket status describes Ticket validity and lifecycle, not attendance outcome.
- A participant may be `CheckedIn` while a booking-level Ticket remains `PartiallyUsed` for other eligible participants.
- A participant Ticket becomes `Used` after that participant is successfully checked in.
- A participant's `NoShow` state does not automatically change an unrelated booking-level Ticket.
- A Ticket's `Used` status must not be used as a substitute for calculating Booking attendance.

Ticket and participant attendance state must be updated consistently within the trusted check-in transaction defined in Section 10.2.

---

## 11. Approval & Moderation

Provider onboarding and Activity review are independent approval processes.

### 11.1 Provider Review

Every Business and every Independent Organizer requires Admin approval.

An approved provider may:

- Manage its provider profile.
- Create Activity drafts.
- Manage authorized members.
- Submit Activities for review.

A provider must not independently publish an Activity without the required Admin approval.

### 11.2 Activity Review

Every Activity requires Admin approval before public marketplace visibility and booking.

Proposed Activity statuses:

- Draft
- Pending Review
- Approved
- Published
- Rejected
- Changes Requested
- Suspended
- Archived

Provider approval does not automatically approve Activities.

Publishing must be enforced by trusted backend operations.

### 11.3 Activity Revision Review

Material changes to a published Activity must go through review.

The currently published version may remain visible while the new revision is under review.

Safety, compliance, or operational issues may require immediate suspension.

Existing Bookings must retain their original snapshots.

### 11.4 AuditLog

Important administrative and provider actions must be auditable.

Examples:

- Provider approval or rejection.
- Activity approval or rejection.
- Activity publication.
- Activity suspension.
- Provider suspension.
- Booking status changes.
- Capacity release.
- Ticket issuance.
- Check-in operations.
- Participant attendance changes.
- Booking attendance finalization.
- Permission changes.

Proposed fields:

| Field | Type | Description |
|---|---|---|
| id | String | Audit document ID |
| actorUserId | String | User who performed the action |
| action | String | Action identifier |
| targetType | String | Target entity type |
| targetId | String | Target entity ID |
| previousState | Map? | Previous state when applicable |
| newState | Map? | New state when applicable |
| metadata | Map? | Additional non-sensitive context |
| createdAt | Timestamp | Audit creation date |

Audit records must not be editable by ordinary clients.

Sensitive information must not be copied into audit metadata unnecessarily.

---

## 12. Proposed Firestore Structure

The following is the proposed collection layout.

```text
users/{userId}

businesses/{businessId}
  branches/{branchId}

organizers/{organizerId}

businessMemberships/{membershipId}
organizerMemberships/{membershipId}
organizerBusinessLinks/{linkId}

providerApplications/{applicationId}

activityCategories/{categoryId}

activities/{activityId}
  versions/{versionId}
  schedules/{scheduleId}

bookings/{bookingId}
  participants/{participantId}

capacityReservations/{reservationId}

tickets/{ticketId}

checkIns/{checkInId}

groupCheckInOperations/{operationId}
  participants/{participantId}

idempotencyRecords/{recordId}

activityReviews/{reviewId}

auditLogs/{auditLogId}
```

Additional collections may be introduced according to MVP requirements and actual query patterns.

Examples:

- `favorites`
- `reviews`
- `notifications`


### 12.1 Firestore Structure Notes

- Business Branches may be stored as a subcollection because they belong to one Business.
- Activity Versions and Schedules may be stored as subcollections because they belong to one Activity.
- Booking Participants may be stored as a subcollection because they belong to one Booking.
- CapacityReservations are proposed as a top-level collection to support expiration processing and reservation lookup.
- Tickets and CheckIns are proposed as top-level collections to support provider and administrative lookup patterns.
- AuditLogs are proposed as a top-level collection to support administrative queries and audit retention.
- GroupCheckInOperations are top-level documents with a participant progress subcollection so large group operations can be resumed and queried independently.
- IdempotencyRecords are top-level documents so operation-scoped duplicate-request protection can be enforced across resources.

The final decision between top-level collections and subcollections must consider collection-group queries, access patterns, and lifecycle operations.

### 12.2 Capacity Reservation Consistency

A CapacityReservation must reference:

- Its Booking.
- Its ActivitySchedule.
- Its Activity.

The ActivitySchedule counters are aggregate values maintained by trusted backend operations.

The reservation record is the source for an individual hold's lifecycle.

The schedule counters must be reconciled with reservation states through transactional operations and trusted expiration processing.

### 12.3 Booking Participant Counter Consistency

For Bookings using participant-level attendance, `eligibleParticipantCount` and `checkedInParticipantCount` are maintained by trusted backend transactions.

- The eligible participant set is finalized at Booking confirmation, and both counters are initialized in the confirmation transaction.
- `eligibleParticipantCount` equals the number of eligible BookingParticipant records; `checkedInParticipantCount` starts at zero.
- A first successful `NotCheckedIn` to `CheckedIn` transition increments `checkedInParticipantCount` exactly once in the same transaction as the participant, Ticket, CheckIn and audit updates.
- Repeated requests and already checked-in participants do not increment the counter.
- The eligible participant set is immutable after confirmation except through an authorized, audited correction that updates the participant records and counters consistently.
- Both fields are null when participant-level attendance does not apply.
- The backend must maintain `0 <= checkedInParticipantCount <= eligibleParticipantCount` and reconcile any mismatch against authoritative participant records before changing Ticket state.

The counters are projections used for efficient transactional Ticket-state decisions. BookingParticipant records remain the source of truth and must be inspected when finalizing the Booking attendance outcome.

### 12.4 Group Check-in Operation Consistency

`GroupCheckInOperation` is stored as a top-level collection, with one participant progress document per selected participant in its `participants` subcollection.

- The operation is not processable until all selected participant progress records have been initialized. A group operation must contain at least two unique selected participant IDs; a single participant uses the individual CheckIn flow.
- The participant ID is the deterministic progress document ID, preventing duplicate progress records for the same selected participant.
- Each participant's attendance, Booking counters, Ticket, CheckIn, audit record, progress result and operation counters are updated in one transaction.
- A participant progress transition and its operation counter update must be atomic.
- Only `Succeeded` and `AlreadyCheckedIn` count toward `completedParticipantCount`.
- `Completed` requires every selected participant to have an accepted completed result and no failures.
- Retryable failures may be resumed without reprocessing successful participants. Permanent failures do not roll back successful check-ins.
- Concurrent processing must use transactionally guarded progress state and counters; process-local locks are not sufficient.

### 12.5 Idempotency Record Consistency

`IdempotencyRecord` is stored in the top-level `idempotencyRecords` collection.

- The server derives its document ID from the authenticated actor, operation name and client idempotency key.
- The normalized request hash prevents the same key from being reused with a different payload.
- The record's claim and lease fields are managed only by trusted backend operations. While status is `InProgress`, `claimId`, `claimedAt` and `leaseExpiresAt` must be populated. When status becomes `Completed` or `Failed`, those active claim fields must be cleared. Every transaction that commits a business result must verify the current claim ID and unexpired lease in the same transaction.
- A business operation and its final idempotency result must commit in the same transaction whenever the operation is transactional.
- For long-running group operations, the record identifies the durable GroupCheckInOperation; that operation independently tracks processing progress.
- Expiration is for retention and cleanup only and must never reverse a committed Booking, Ticket, attendance or check-in operation.

### 12.6 Participant Attendance Consistency

A BookingParticipant must reference its parent Booking.

The participant's attendance fields are the source of truth for participant-level attendance.

A successful check-in must update the participant attendance state and create the corresponding CheckIn/audit record through a trusted backend operation.

Booking attendance finalization must read the eligible participant records and update the Booking lifecycle state according to the approved policy.

The Booking's `attendanceFinalizedAt` is the marker that attendance finalization has completed.

The backend must prevent finalization from running more than once in a way that changes an already finalized Booking.

#### Participant Attendance Finalization Rules

When the applicable attendance window closes, the trusted backend must finalize participant attendance using the following rules:
1. Finalization is allowed only for a `Confirmed` Booking that has not already been finalized.
2. The backend must verify that the server time is later than `attendanceWindowEndsAt`.
3. The backend must load and validate the complete eligible participant set according to the Booking's attendance policy.
4. Every eligible participant currently in `NotCheckedIn` must be transitioned to `NoShow`.
5. Participants already in `CheckedIn` must remain `CheckedIn`.
6. Participants already in `NoShow` must remain `NoShow`.
7. If at least one eligible participant is `CheckedIn`, the Booking must transition to `Completed`, even if other participants are `NoShow`.
8. If every eligible participant is `NoShow`, the Booking must transition to `NoShow`.
9. The backend must not finalize attendance if the eligible participant set is incomplete, inconsistent, or cannot be reliably determined. Such cases must be handled through an explicit reconciliation workflow.
10. All participant attendance updates, the Booking lifecycle transition, `attendanceFinalizedAt`, and the corresponding audit event must be performed as one atomic transaction when supported by Firestore limits, or through a safely designed idempotent workflow.
11. Finalization must be retry-safe and must not overwrite a previously committed `CheckedIn` state.
12. Attendance finalization must not release or decrement confirmed capacity.
13. Once finalized, ordinary check-in and finalization operations must not change the outcome. Exceptional corrections require an authorized and audited correction workflow.

#### Check-in and Finalization Concurrency

Participant check-in and Booking attendance finalization must coordinate through a trusted Booking-level concurrency mechanism.

1. A check-in operation must verify that the attendance window is still open and that finalization has not been claimed or completed.
2. Finalization must atomically claim the Booking for finalization before processing participant records.
3. Once finalization has been claimed, new check-in operations must be rejected.
4. Check-in and finalization claim acquisition must coordinate through the same Booking document inside Firestore transactions.

   Every participant check-in transaction must read the parent Booking and verify that:
    - Booking status is `Confirmed`.
    - The attendance window is still open according to trusted server time.
    - `attendanceFinalizationStatus` is `NotStarted`.

   The transaction must then update the participant attendance state and create the corresponding CheckIn and audit records.

   Finalization claim acquisition must transactionally update the same Booking document to `InProgress`.

   Both operations must read the Booking document within their transactions. The finalization claim transaction writes the Booking document, while the check-in transaction must validate the version of the Booking document it read before committing its participant updates.

   Firestore transaction conflict detection must ensure that a check-in transaction based on a Booking state that changed during its execution cannot commit using stale state.

   If a check-in transaction conflicts with finalization claim acquisition, it must retry and revalidate the Booking state. It must not commit using previously read state.

5. Every claim acquisition or reclamation must use a new unique claim ID. A worker may commit progress only while its claim ID matches the current Booking claim. This fencing mechanism must prevent a worker holding an expired claim from writing after another worker has reclaimed the operation.
6. An expired lease permits another trusted worker to reclaim the finalization operation. It must never reset the Booking to `NotStarted` or permit new check-in operations.
7. Every participant update must be idempotent and must preserve previously committed attendance states. Reclaimed workers must continue from the persisted participant states rather than assuming that no previous progress was committed.
8. If finalization is interrupted, the backend must safely resume or retry it without duplicating updates or losing previously committed attendance.
9. `attendanceFinalizedAt` must be written only after all eligible participant records and the Booking lifecycle state have been successfully reconciled.
10. The finalization mechanism must support large participant groups without relying on a single transaction that exceeds Firestore limits.
11. When finalization requires multiple processing chunks, each chunk must verify the current Booking finalization status, claim ID, and lease expiration within a Firestore transaction before committing participant updates.
12. The claim ownership check, lease validity check, and participant updates within each chunk must be protected by the same transaction.

    A worker may commit a chunk only when:
    - `attendanceFinalizationStatus` is `InProgress`.
    - `attendanceFinalizationClaimId` matches the worker's current unique claim ID.
    - `attendanceFinalizationLeaseExpiresAt` is later than the trusted server time at which the transaction is validated.

    A worker must never commit participant changes based only on a claim ID or lease value read outside the transaction.

    If the claim ID no longer matches or the lease has expired, the worker must stop processing and must not commit the chunk.

13. Each chunk must be idempotent and must preserve already committed participant attendance states.
14. The final Booking lifecycle transition, `attendanceFinalizedAt`, and transition to `attendanceFinalizationStatus = Completed` must occur only after the complete eligible participant set has been reconciled successfully.
15. If a worker loses its claim or its lease expires, it must not commit further changes. A replacement worker must acquire a new claim ID and safely resume reconciliation from persisted participant states.

16. **Lease Renewal**

    The trusted finalization worker must renew its lease before expiration when additional processing time is required.

    Lease duration and renewal intervals must be configurable backend settings. No fixed numeric duration is prescribed.

    Renewal must execute within a Firestore transaction and verify:

    - `attendanceFinalizationStatus` is `InProgress`.
    - `attendanceFinalizationClaimId` matches the worker's current unique claim ID.
    - `attendanceFinalizationLeaseExpiresAt` is later than trusted server time.

    If all checks succeed, the transaction extends `attendanceFinalizationLeaseExpiresAt` using trusted server time and the configured lease duration.

    If any check fails, renewal must be rejected and the worker must stop processing.

    An expired lease must never be renewed, even if a replacement worker has not yet acquired a new claim.

    The claim ID acts as a fencing token. A worker whose claim has been replaced must not renew its lease or commit additional participant changes.

    Every participant batch and the final Booking completion transaction must independently validate the current claim ID and lease expiration inside the same transaction that commits their changes.

    A successful renewal does not bypass participant-set consistency or finalization validation.

The finalization operation must use trusted server time and must never rely on a client-provided timestamp.

#### Participant Set Consistency

The eligible participant set must remain consistent throughout attendance finalization.

1. Ordinary client operations must not add, remove, or replace BookingParticipants after the Booking is confirmed.
2. Any permitted participant modification after confirmation must use an authorized backend operation that validates the Booking policy and maintains quantity and related data consistency.
3. Once finalization is claimed and `attendanceFinalizationStatus` becomes `InProgress`, no operation may add, remove, replace, or modify the eligibility of a BookingParticipant until finalization either completes or is explicitly stopped through an authorized recovery workflow.
4. Finalization must operate on a complete and stable eligible participant set.
5. If the participant set changes unexpectedly or cannot be reconciled with the Booking's applicable booking-unit policy, finalization must stop and require explicit reconciliation.
6. An empty eligible participant set must never be interpreted as meaning that all participants are `NoShow`.

## 13. Firestore Data Integrity Rules

### 13.1 Authorization

- Customers can read and manage only their own private Booking information.
- Providers can manage only entities within their authorized provider scope.
- Business members must have the required BusinessMembership permissions.
- Organizer members must have the required OrganizerMembership permissions.
- Staff permissions must be limited to explicitly granted capabilities.
- Admin operations require platform-level authorization.
- Super Admin capabilities must be separately protected.

### 13.2 Protected Fields

The following fields must not be freely writable by client applications:

- Provider approval status.
- Activity approval and publication status.
- Booking status transitions.
- Payment status.
- Capacity counters.
- CapacityReservation status.
- Ticket validity and usage.
- CheckIn records.
- BookingParticipant attendance fields.
- Booking attendance finalization fields.
- Administrative audit logs.
- Platform roles and permissions.

### 13.3 Trusted Operations

Critical operations should be implemented through trusted backend endpoints or Cloud Functions.

Examples:

- Submit Provider Application.
- Approve or reject Provider.
- Submit Activity for review.
- Approve and publish Activity.
- Create ActivitySchedule.
- Reserve capacity.
- Confirm Request Booking.
- Create Instant Booking.
- Reject Booking.
- Cancel Booking and release capacity.
- Expire CapacityReservation.
- Generate Tickets.
- Validate QR and check in a participant.
- Perform authorized group check-in.
- Mark eligible participants as NoShow after the attendance window closes.
- Finalize Booking attendance.
- Record attendance and Booking lifecycle audit events.

Firestore Security Rules must prevent unauthorized direct modifications.

### 13.4 Denormalization

Firestore may store repeated display data when doing so improves query performance.

Examples:

- Provider name and logo on Activity documents.
- Activity title on Booking snapshots.
- Schedule details on Booking snapshots.
- Category display information where useful.

Denormalized values must have an explicit source of truth and update policy.

Historical Booking snapshots must remain immutable.

### 13.5 Transaction Boundaries

Operations that modify Booking state and capacity must maintain consistency.

Examples:

- Request Booking creation and hold reservation.
- Request Booking approval and hold conversion.
- Request Booking rejection and hold release.
- Instant Booking creation and confirmed capacity update.
- Booking cancellation and capacity release.

Attendance operations must also maintain consistent state:

- Participant check-in and CheckIn creation.
- Participant NoShow recording.
- Group check-in for explicitly selected participants.
- Booking attendance finalization.
- Attendance audit recording.

Where a workflow touches multiple documents, use a Firestore transaction or a safely designed idempotent workflow that prevents partial or duplicate state changes.

All transaction reads must be completed before writes when required by the Firestore transaction API.

### 13.6 Attendance Integrity

The backend must enforce the following rules:

1. Attendance belongs to each BookingParticipant independently.
2. A participant may be marked `CheckedIn` only through an authorized check-in operation.
3. A participant may be marked `NoShow` only after the applicable attendance window closes.
4. A committed `CheckedIn` state must never be overwritten by a no-show finalization process.
5. Partial attendance is valid and must be preserved.
6. A Booking must not become `NoShow` if at least one eligible participant has checked in.
7. A Booking becomes `NoShow` under participant-level attendance only when every eligible participant has been recorded as `NoShow`.
8. If at least one eligible participant checked in, the finalized Booking status is `Completed`, even when other participants are `NoShow`.
9. Attendance finalization must not release or decrement confirmed capacity.
10. Attendance operations must be idempotent and safe under concurrent check-in and finalization attempts.
11. A Booking with no participant records must follow its explicitly defined booking-level attendance policy; it must not be classified as `NoShow` merely because its participant list is empty.
12. Once attendance is finalized, ordinary check-in operations must not silently modify the finalized outcome. Any exceptional correction must use an authorized, audited correction workflow.

---

## 14. Data Types & Conventions

- Document IDs: String.
- Dates: Firestore Timestamp.
- Monetary values: Integer in minor currency units.
- Currency: ISO 4217 currency code.
- Coordinates: Numeric latitude and longitude.
- Statuses: Explicit documented values.
- Optional values: Nullable fields where appropriate.
- Timestamps: `createdAt` and `updatedAt` for mutable business documents.

Store timestamps in UTC and preserve the relevant IANA timezone for schedule interpretation.

Do not use floating-point values for monetary calculations.

Capacity quantities must use non-negative integer values unless an explicitly defined product policy requires another unit.

Use consistent field naming conventions across collections.

Attendance timestamps must be generated or validated using trusted server time.

A client-provided timestamp must not be accepted as the authoritative time for check-in, no-show, or attendance finalization.

---

## 15. Indexes & Query Planning

Composite indexes must be based on actual application queries.

Expected query patterns include:

### 15.1 Customer Marketplace

- Published Activities by category.
- Published Activities by city or location.
- Published Activities by provider.
- Activities ordered by publication or discovery criteria.
- Upcoming schedules for an Activity.

### 15.2 Customer Bookings

- Bookings by customer.
- Bookings by customer and status.
- Bookings by upcoming schedule.
- Tickets by Booking.
- Booking Participants by Booking.
- Participant attendance by Booking.

### 15.3 Provider Dashboard

- Activities by provider.
- Activities by publication status.
- Schedules by Activity and date.
- Bookings by provider and status.
- Pending Request Bookings awaiting provider action.
- Capacity reservations by schedule.
- Booking Participants and attendance by Booking.
- CheckIns by schedule and date.

### 15.4 Administration

- Provider Applications awaiting review.
- Activities awaiting review.
- Suspended providers and Activities.
- Audit records by target and date.
- Expired active CapacityReservations.
- Confirmed Bookings awaiting attendance finalization.
- Attendance records requiring reconciliation.

Required composite indexes must be added to the repository's Firestore index configuration once query specifications are finalized.

---

## 16. MVP Boundaries & Open Decisions

The following details must be finalized before implementing the corresponding domains:

1. Exact cancellation and refund policies.
2. Provider response and hold duration limits.
3. Whether all Activity categories require individual participant details.
4. Which Activity categories require individual Tickets.
5. Exact Business and Organizer membership roles and permissions.
6. Whether Admin and Super Admin use one dashboard or separate applications.
7. Which supporting domains are included in MVP: Reviews, Favorites, Notifications, and Analytics.
8. Supported currencies and payment methods for launch.
9. Whether unlimited-capacity Activities are supported in MVP.
10. Exact provider and Activity review requirements and document types.
11. Activity-specific booking and capacity units, such as seats, tables, or service units.
12. The exact attendance-window duration and operational check-in cutoff for each applicable Activity category.
13. The booking-level attendance workflow for Activities that do not create BookingParticipant records.
14. The exceptional correction and audit policy for attendance after Booking finalization.

The following decisions are already approved and must not be treated as unresolved:

### 16.1 Approved Capacity Decisions

- Request Booking uses a temporary capacity hold.
- The default Request Booking hold duration is 30 minutes and is configurable within platform limits.
- A Request Booking remains Pending while awaiting provider approval.
- Approval converts the active hold into confirmed capacity.
- Rejection, valid cancellation, or expiration releases the relevant capacity exactly once.
- Instant Booking confirms the Booking and reserves confirmed capacity directly within one atomic server-side transaction.
- Instant Booking does not create a separate temporary hold.
- Capacity is tracked per ActivitySchedule through total, confirmed, and held quantities.
- Expired holds must not count as occupied capacity even before cleanup completes.

### 16.2 Approved Attendance Decisions

- Attendance is tracked independently for every BookingParticipant.
- A group Booking supports partial attendance.
- Each participant has one attendance state: `NotCheckedIn`, `CheckedIn`, or `NoShow`.
- A booking-level QR scan does not automatically check in all participants.
- Group check-in requires an explicit authorized action.
- Individual Tickets are required only when the Activity ticketing policy requires them.
- Ticket status and participant attendance status are independent.
- Attendance finalization occurs only after the applicable attendance window closes.
- All eligible participants checked in results in Booking `Completed`.
- Partial attendance, where at least one eligible participant checked in and others are `NoShow`, results in Booking `Completed`.
- Booking `NoShow` is used only when all eligible participants are recorded as `NoShow`.
- Attendance recording and finalization do not release or decrement confirmed capacity.
- A Booking with no participant records follows a separately defined booking-level attendance policy.

The question of whether partial or group check-in is supported is no longer an open domain decision. It is an approved capability subject to staff authorization and Activity policy.

---

## 17. Implementation Guardrails

- Do not place every domain model in `packages/shared_models`.
- Share only models and contracts genuinely required by multiple applications.
- Keep feature-specific models and DTOs inside their owning application or feature.
- Keep Firestore-specific serialization and data-source implementation outside pure domain entities.
- Do not expose Firebase SDK dependencies to the domain layer.
- Do not trust client-side validation for capacity, Booking, approval, payment, or check-in integrity.
- Do not mutate historical Booking snapshots when Activities change.
- Do not publish an Activity without an approved provider and an approved Activity revision.
- Do not confirm a Request Booking after its hold expires.
- Do not create a separate temporary hold for Instant Booking.
- Do not update capacity counters directly from Flutter clients.
- Do not allow capacity release or reservation conversion more than once.
- Do not rely on Firestore TTL alone for capacity expiration.
- Do not track group attendance using only the Booking status.
- Do not mark every participant as checked in when scanning a booking-level QR.
- Do not mark a participant as `NoShow` before the applicable attendance window closes.
- Do not mark a Booking as `NoShow` if at least one eligible participant has checked in.
- Do not finalize attendance while check-in is still permitted.
- Do not release confirmed capacity when attendance is recorded or finalized.
- Do not treat Ticket status as a replacement for participant attendance status.
- Do not automatically mark a Booking with no participant records as `NoShow`.
- Do not allow ordinary client operations to modify finalized attendance.
- All attendance and finalization operations must be authorized, auditable, and idempotent.

---

## 18. Document Status

This document establishes the updated conceptual domain model and proposed Firestore structure for Fusha.

It incorporates the approved:

- Request Booking and Instant Booking capacity policies.
- Temporary capacity hold and expiration rules.
- Participant-level attendance policy.
- Partial group attendance behavior.
- Booking attendance finalization rules.
- Ticket and participant attendance separation.
- Booking-level participant attendance counters and their transactional consistency rules.
- Durable GroupCheckInOperation processing and participant progress tracking.
- Persisted IdempotencyRecord behavior.
- Provider onboarding and Activity moderation policies.

It is an updated domain and data-model specification, not yet a final Firestore implementation specification.

Before creating production collections or Dart models, the model must be reviewed against:

- PRD requirements.
- Backend Architecture.
- Booking workflow and lifecycle decisions.
- Firestore query patterns.
- Security and authorization rules.
- Capacity concurrency and expiration behavior.
- Participant attendance and finalization behavior.
- MVP scope.

The next implementation stage should define concrete Firestore document schemas, indexes, security rules, and backend transaction contracts before creating application models.