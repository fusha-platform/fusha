# Fusha — Data Model

> **Document status:** Initial Draft — Updated
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
- Provider approval and activity moderation.

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

A submitted or confirmed booking must retain the relevant activity, schedule, location, and pricing information as it was presented when the booking was created.

Changes to an Activity must not silently rewrite existing booking details.

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
- A Booking may contain multiple participants.
- A Request Booking may have one temporary CapacityReservation.
- A confirmed booking consumes confirmed capacity.
- A Booking may have one booking-level Ticket and/or multiple participant Tickets.

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
| idempotencyKey | String | Duplicate request protection |
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
| Completed | Activity attendance or service has been completed |
| NoShow | Customer did not attend |

Payment statuses:

- Unpaid
- Paid
- Refunded
- Partially Refunded

Booking status and payment status are independent.

The exact payment and cancellation transitions must be defined in the booking workflow specification.

### 9.2 BookingParticipant

Represents an individual participant within a group Booking.

Participant details may be optional depending on the Activity policy.

Possible fields:

- id
- bookingId
- displayName
- contactDetails, when required
- participantReference
- ticketId, when individual tickets are required
- attendanceStatus
- createdAt
- updatedAt

Attendance statuses may include:

- NotCheckedIn
- CheckedIn
- NoShow

A Booking does not always require participant records.

For example, a restaurant table reservation may be represented by a booking quantity and table details instead.

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

A Pending Request Booking must not reserve capacity indefinitely.

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
9. Record `confirmedAt`.

These operations must be performed atomically.

A provider must not confirm a Booking after its hold has expired.

#### 9.4.3 Request Booking — Rejection and Cancellation

When the provider rejects a Booking:

- Release the associated active hold.
- Decrease `heldQuantity` exactly once.
- Update the CapacityReservation state to `Released`.
- Change Booking status to `Rejected`.

When a customer cancels a Booking:

- Validate the applicable cancellation policy.
- Release the hold or confirmed capacity as appropriate.
- Update the reservation and Booking states consistently.
- Record the cancellation timestamp.

Capacity release must be idempotent.

Repeated cancellation or release operations must not decrement capacity more than once.

#### 9.4.4 Request Booking — Hold Expiration

Temporary hold expiration must be enforced by trusted backend processes.

The default expiration period is 30 minutes.

The backend must:

- Check the CapacityReservation `expiresAt` before accepting provider approval.
- Exclude expired reservations from valid capacity.
- Release expired capacity through trusted backend processing.
- Update Booking status to `Expired`.
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
6. Increase `confirmedQuantity`.
7. Record `confirmedAt`.
8. Persist all related booking and capacity changes together.

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
- `Released`: Capacity was released after rejection or cancellation.
- `Expired`: Hold expired and capacity was released.

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
| participantId | String? | Associated participant |
| activityId | String | Associated Activity |
| scheduleId | String? | Associated schedule |
| tokenHash | String | Secure token hash or reference |
| ticketType | String | Booking or Participant |
| status | String | Ticket status |
| issuedAt | Timestamp | Issuance date |
| usedAt | Timestamp? | Check-in date |

Ticket statuses:

- Valid
- Used
- Cancelled
- Expired

QR codes must contain an opaque, unpredictable token or secure reference.

They must not contain personal information or sensitive Booking details.

The backend must validate the token and ticket state before accepting a check-in.

### 10.2 CheckIn

A CheckIn records attendance.

Proposed fields:

- id
- ticketId
- bookingId
- participantId, when applicable
- activityId
- scheduleId
- checkedInByUserId
- checkedInAt
- status

Scanning a booking-level QR must not automatically check in every participant.

Checking in all participants requires an explicit authorized action.

The backend must validate:

- Ticket validity.
- Booking status.
- Activity and schedule association.
- Staff authorization.
- Prior ticket usage.
- Check-in eligibility.

A Ticket must not be reused for multiple check-ins unless an explicitly defined policy permits it.

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
- Permission changes.

Proposed fields:

- id
- actorUserId
- action
- targetType
- targetId
- previousState, when applicable
- newState, when applicable
- metadata
- createdAt

Audit records must not be editable by ordinary clients.

Sensitive information must not be copied into audit metadata unnecessarily.

---

## 12. Proposed Firestore Structure

The following is the initial proposed collection layout.

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

activityReviews/{reviewId}

auditLogs/{auditLogId}
```

Additional collections may be introduced according to MVP requirements and actual query patterns.

Examples:

- `favorites`
- `reviews`
- `notifications`
- `idempotencyRecords`

### 12.1 Firestore Structure Notes

- Business Branches may be stored as a subcollection because they belong to one Business.
- Activity Versions and Schedules may be stored as subcollections because they belong to one Activity.
- Booking Participants may be stored as a subcollection because they belong to one Booking.
- CapacityReservations are proposed as a top-level collection to support expiration processing and reservation lookup.
- Tickets and CheckIns are proposed as top-level collections to support provider and administrative lookup patterns.

The final decision between top-level collections and subcollections must consider collection-group queries, access patterns, and lifecycle operations.

### 12.2 Capacity Reservation Consistency

A CapacityReservation must reference:

- Its Booking.
- Its ActivitySchedule.
- Its Activity.

The ActivitySchedule counters are aggregate values maintained by trusted backend operations.

The reservation record is the source for an individual hold's lifecycle.

The schedule counters must be reconciled with reservation states through transactional operations and trusted expiration processing.

---

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
- Check-in records.
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
- Validate QR and check in participants.

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

For example:

- Request Booking creation and hold reservation.
- Request Booking approval and hold conversion.
- Request Booking rejection and hold release.
- Instant Booking creation and confirmed capacity update.
- Booking cancellation and capacity release.

These operations must not leave partially updated documents.

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

### 15.3 Provider Dashboard

- Activities by provider.
- Activities by publication status.
- Schedules by Activity and date.
- Bookings by provider and status.
- Pending Request Bookings awaiting provider action.
- Capacity reservations by schedule.

### 15.4 Administration

- Provider Applications awaiting review.
- Activities awaiting review.
- Suspended providers and Activities.
- Audit records by target and date.
- Expired active CapacityReservations.

Required composite indexes must be added to the repository's Firestore index configuration once query specifications are finalized.

---

## 16. MVP Boundaries & Open Decisions

The following details must be finalized before implementing the corresponding domains:

1. Exact cancellation and refund policies.
2. Provider response and hold duration limits.
3. Whether all Activity categories require individual participant details.
4. Which Activity categories require individual Tickets.
5. Whether staff can perform partial or group check-in.
6. Exact Business and Organizer membership roles and permissions.
7. Whether Admin and Super Admin use one dashboard or separate applications.
8. Which supporting domains are included in MVP: Reviews, Favorites, Notifications, and Analytics.
9. Supported currencies and payment methods for launch.
10. Whether unlimited-capacity Activities are supported in MVP.
11. Exact provider and Activity review requirements and document types.
12. Activity-specific booking and capacity units, such as seats, tables, or service units.

The following booking capacity decisions are already approved:

- Request Booking uses a temporary capacity hold.
- The default Request Booking hold duration is 30 minutes and is configurable within platform limits.
- A Request Booking remains Pending while awaiting provider approval.
- Approval converts the active hold into confirmed capacity.
- Rejection, valid cancellation, or expiration releases the held capacity.
- Instant Booking confirms the Booking and reserves confirmed capacity directly within one atomic server-side transaction.
- Instant Booking does not create a separate temporary hold.
- Capacity is tracked per ActivitySchedule through total, confirmed, and held quantities.

These approved decisions must not be treated as unresolved items.

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

---

## 18. Document Status

This document establishes the initial conceptual and proposed Firestore data model for Fusha.

It incorporates the approved Request Booking and Instant Booking capacity policies.

It is not yet a final Firestore implementation specification.

Before creating production collections or Dart models, the model must be reviewed against:

- PRD requirements.
- Booking workflow decisions.
- Firestore query patterns.
- Security and authorization rules.
- Capacity concurrency and expiration behavior.
- MVP scope.

The next implementation stage should define concrete Firestore document schemas, indexes, security rules, and backend transaction contracts before creating application models.