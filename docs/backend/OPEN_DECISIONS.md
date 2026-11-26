# Fusha — Backend Open Decisions Register

**Document status:** Consolidated decision register  
**Review date:** 2026-11-26  
**Purpose:** Prevent undocumented assumptions from becoming schema, authorization, API, or production behavior.

This register contains decisions that the current `BACKEND_ARCHITECTURE.md`, `DATA_MODEL.md`, and current PRD do not fully settle. It does not replace those sources. An item is marked open when implementation would otherwise require an assumption.

## 1. How to Use This Register

- **Blocking** means the dependent production schema, Security Rules, API contract, or workflow must not be finalized until the decision is made.
- **Before launch** means the feature may be designed, but the policy must be resolved before exposing it to users.
- **Later / scope-dependent** means it may be deferred if the feature is excluded from the MVP.
- Once decided, update the owning source document and remove or mark the item resolved here.
- Do not treat a proposed example, operation label, or Firestore path as an approved implementation contract.

## 2. Identity, Roles, and Authorization

**Review outcome (2026-11-26):** The architectural direction for AUTH-01 through AUTH-10 is accepted for incorporation, subject to the refinements below. This is not a declaration that all implementation details, Firestore paths, permission identifiers, MFA factors, or API contracts are finalized. AUTH-11 is added as an accepted architectural requirement. Blocking implementation details remain open until their owning schemas and policies are completed.

### 2.1 Accepted architectural principles

1. **Three independent authorization dimensions:**
   - `PlatformRole`: platform-wide role, initially `Customer`, `Admin`, or `Super Admin`.
   - Provider membership role: role within one specific Business or Organizer membership, such as `Owner`, `Manager`, or `Staff`.
   - Granular permissions: effective operations granted within the exact provider membership/resource scope.
2. A single user may simultaneously be a platform `Customer`, `Owner` in Business A, `Staff` in Business B, and `Manager` in Organizer C. These contexts do not collapse into one global role.
3. A provider role or membership never grants platform administration. A platform role never implicitly grants provider membership.
4. **Role and permission are distinct:** a role supplies a default permission set; granular permissions determine the allowed operations within the membership scope. Any customization must be bounded by a server-defined ceiling for that role and provider type. A member cannot grant themselves a higher role, ownership, or permissions outside that ceiling.
5. Permissions are evaluated against the authenticated UID, current account state, membership identity and status, provider type and ID, requested permission, resource ownership/scope, and applicable business state. The selected UI context is not authorization evidence.
6. `BusinessMembership` with role `Owner` is the authoritative ownership representation. `Business.ownerUserId`, if retained, is a denormalized/helper field and must be synchronized with the authoritative membership during a single atomic ownership-transfer operation. The operation validates the current owner and recipient, updates ownership representations, and records an audit event atomically; failure leaves all state unchanged. The last active Owner cannot be removed without a valid replacement.
7. Platform account status and provider membership status are independent state dimensions. `Active`, `Suspended`, and `Disabled` apply to the platform account; `Pending`, `Active`, `Suspended`, and `Revoked` apply to Business and Organizer memberships. Suspending one provider membership does not suspend the user's account or unrelated memberships. A suspended/disabled platform account blocks protected operations across all provider contexts.
8. MFA remains separate from the primary sign-in methods. Management Dashboard authentication remains Email + Password and Google Sign-In; Phone OTP remains deferred. MFA is mandatory for `Admin` and `Super Admin`; Owner MFA enforcement and step-up requirements for sensitive provider operations remain to be specified.
9. Custom Claims are non-authoritative hints/optimization only. Sensitive operations re-read current authoritative account and role state. Role changes require a defined claims refresh and session/token revocation strategy; stale tokens must not preserve revoked privileges.
10. App Check is enforced according to environment and endpoint capability. It does not replace Authentication, Authorization, or webhook signature verification. Direct Firestore/Storage access is not globally prohibited by this decision; each service/path must have an explicit approved read/write policy, query scope, and matching Security Rules. Default deny remains in force until such a policy is approved.
11. **Multi-provider membership context (AUTH-11):** a user can switch between their authorized Business and Organizer contexts without signing out or creating multiple accounts. Selecting a context only selects the scope for evaluation; it never grants access. Every backend operation independently verifies identity, platform account status, target membership and its status, required permission, resource-to-provider relationship, and requested operation.

### 2.2 Remaining decisions and implementation blockers

| ID | Priority | Remaining decision | Why it matters / dependent work |
|---|---|---|---|
| AUTH-01 | Blocking | Finalize `PlatformRole` schema, authoritative storage path, role lifecycle, and Admin/Super Admin role set semantics. `Customer` remains the default platform role and need not require an administrative assignment. | Required for Admin/Super Admin authorization, role management, and Security Rules. No Firestore path is approved by this review outcome. |
| AUTH-02 | Blocking | Define the `Permission` schema/catalog, stable permission identifiers, default permission sets per provider role/type, customization boundaries, and permission-ceiling enforcement. | Required for backend authorization, membership management, API contracts, and Security Rules. Example identifiers are illustrative only until catalog approval. |
| AUTH-03 | Blocking | Confirm OrganizerMembership role/status enums and whether their permission catalog differs from BusinessMembership. `Owner`, `Manager`, `Staff` and the four membership statuses are the accepted proposed direction, pending final schema approval. | Required for Organizer authorization and membership workflows. |
| AUTH-04 | Blocking | Finalize ownership-transfer concurrency/idempotency behavior, recipient eligibility, and the retained/deprecated status of `Business.ownerUserId`. | Required for a safe atomic ownership transfer and consistent reads. |
| AUTH-05 | Blocking | Define `OrganizerBusinessLink` schema, lifecycle, initiator/approval rules, collaboration scope, and explicitly grantable cross-provider permissions. No implicit access is allowed. | Required to avoid cross-provider data leakage. |
| AUTH-06 | Blocking | Finalize first Super Admin bootstrap, break-glass recovery, role assignment/revocation authority, last-Super-Admin safeguards, and audit requirements. | Required before production platform role management. Bootstrap must not be exposed through public app registration. |
| AUTH-07 | Before launch | Specify exact sign-in/refresh/session revocation, read/write denial, recovery, and support behavior for platform `Suspended` and `Disabled` states. | Account and membership status separation is accepted; enforcement lifecycle remains open. |
| AUTH-08 | Before launch | Specify accepted MFA factors, enrollment deadline, enforcement gates, step-up freshness, recovery, exception handling, and whether/when Business and Organizer Owners require MFA. | Admin and Super Admin MFA requirement is accepted; operational policy is open. |
| AUTH-09 | Before launch | Define custom-claim contents, refresh strategy, revocation mechanisms, and authoritative re-check policy by operation risk. | Stale claims/tokens must not retain revoked privileges. |
| AUTH-10 | Before launch | Map App Check enforcement by environment and endpoint, and approve direct Firestore/Storage read/write paths with query and Rules requirements. | No global direct-access ban is approved; each path requires an explicit policy. |
| AUTH-11 | Blocking | Define the membership-context representation/selection lifecycle, context-switch UX/API, and safeguards against stale or cross-provider resource context. | Required for multi-provider dashboards and tenant isolation. Context selection is never an authorization grant. |


## 3. Provider Onboarding and Moderation

**Review outcome (2026-11-26):** The architectural direction and principles for PROV-01 through PROV-06 are accepted, including the six additional controls below. This does not finalize implementation schemas, status-transition policies, verification requirements, retention rules, or material/minor change classification.

### 3.1 Accepted architectural principles

1. `ProviderApplication`, the resulting `Business`/`Organizer` provider record, and provider `Membership` are separate domain records with distinct lifecycles. Submission/retry must not create duplicate provider records or memberships.
2. Each `ActivityReview` is tied to one exact `ActivityVersion` and one independent review round. Review history is retained; a later revision does not overwrite earlier review evidence.
3. `ActivityVersion.reviewStatus` and `Activity.publicationStatus` are distinct. `Approved` does not mean `Published`; the currently published version remains protected while a new version is reviewed.
4. A publish operation changing `publishedVersionId` must verify that the approved version belongs to the same Activity and is eligible for publication.
5. Public projections are distinct from private provider data. Their update mechanism must prevent unapproved or private data from becoming publicly visible; read permissions are independently defined.
6. Provider verification requirements are configurable by provider type and country/jurisdiction. Each uploaded document has its own status and traceable version/reference, uploader, and reviewer. Re-uploading does not silently replace historical evidence.
7. Material Activity changes require a new version and review; minor changes follow a less restrictive backend policy. Existing Booking snapshots remain immutable, and changes affecting existing bookings require an explicit handling and notification policy.
8. Provider application outcomes remain distinct: `Rejected` may permit a new application under policy; `Changes Requested` permits editing and resubmitting the same application while preserving review history; `Withdrawn` records applicant withdrawal. A rejected application is not reopened or reused in a way that erases prior reviews.
9. Provider approval and activation of the initial `Owner` membership are one atomic, idempotent backend operation. Partial states (including active Owner membership without approved provider) are prohibited. External notifications are not sent inside the Firestore transaction; a durable event/Outbox record is written atomically and processed after commit.

### 3.2 Remaining decisions and implementation blockers

The PROV-01 through PROV-06 rows below remain open only for the detailed policies and schemas described in their descriptions. The accepted principles above are not open for re-interpretation without new evidence.

| ID | Priority | Open decision | Why it matters / dependent work |
|---|---|---|---|
| PROV-01 | Blocking | Define the exact creation/linking lifecycle among User, ProviderApplication, Business/Organizer, and initial Owner membership. | The application has optional `providerId`, but the atomic approval/create/membership process is not defined. |
| PROV-02 | Blocking | Define `ActivityReview` fields, lifecycle, reviewer notes, revision reference, and relationship to `ActivityVersion.reviewStatus`. | `ActivityReview` is named in the domain overview and collection layout but has no complete entity schema. |
| PROV-03 | Blocking | Define the authoritative relationship between `ActivityVersion.reviewStatus` and `Activity.publicationStatus`, including transition mapping and concurrent revision handling. | Both fields contain overlapping review/publication concepts; the mapping is not frozen. |
| PROV-04 | Before launch | Define which Business/Organizer profile fields are public and which are private/internal. | Direct Firestore reads are proposed, but public/private field projections are not defined. |
| PROV-05 | Before launch | Define exact provider verification document types, upload workflow, reviewer access, resubmission behavior, and retention. | ProviderApplication references restricted documents, but the document schema and storage policy are incomplete. |
| PROV-06 | Before launch | Define exact Activity material/minor change criteria and the effects of revisions on existing Bookings and customer notifications. | The model gives examples but defers the complete policy. |

## 4. Marketplace, Schedule, and Capacity

**Review outcome (2026-11-26):** The architectural principles in the CAP-01 through CAP-08 review batch are accepted, including the additional controls below. The four initial blocking gates and the expanded gate list remain mandatory before implementing booking/capacity logic. The CAP identifiers in the legacy open-decision table below predate this review batch and retain their original meanings; they are not a renumbering of the review-batch labels.

### 4.1 Accepted architectural principles

1. `ActivitySchedule` owns capacity and availability for scheduled bookings. Unscheduled booking policy remains open and must not be inferred.
2. Capacity is represented conceptually by `Capacity` (the allowed limit), `Held` (temporary reservations), and `Confirmed` (confirmed consumption). `Available` is derived from the limit and applicable counters; it is not an independently authoritative counter. It may be materialized only as a rebuildable/read-optimized projection.
3. Booking record count, participant count, and consumed capacity quantity are distinct concepts. Every Booking must have an explicit capacity consumption value consistent with the Activity/Schedule policy; the unit model remains open.
4. Instant Booking creation and capacity consumption are one atomic operation. Request Booking creates a temporary hold; the default hold duration is 30 minutes and configurable within platform limits.
5. All capacity and related Booking/CapacityReservation state transitions are performed by trusted backend operations transactionally. Client apps and provider dashboards cannot directly mutate capacity counters.
6. Expiration is effective according to trusted server time and reservation state even if cleanup has not run. A concurrent approval/expiration race must resolve transactionally to one consistent outcome; an expired hold cannot be confirmed or released twice.
7. Idempotent retries must not repeat commercial effects. Booking confirmation must not leave an incomplete core record set: the required transactional records must be identified, while safely recoverable downstream work (including ticket issuance where appropriate) may use a durable Outbox/event and idempotent retry without duplicate tickets.
8. Schedule/capacity changes must preserve existing commitments and immutable Booking snapshots. Increasing capacity does not alter existing bookings; reducing capacity cannot reduce existing commitments; closing a schedule blocks new bookings according to its state; cancellation requires explicit handling of affected bookings and notifications.
9. The capacity counters are trusted backend-maintained aggregates. Their final names, definitions, reconciliation mechanism, and monitoring policy remain open. `capacity = null` semantics also remain open.

### 4.2 Mandatory pre-implementation gates

- Unscheduled Activity booking and capacity ownership.
- Capacity consumption unit, participant relationship, and `capacity = null` semantics.
- Hold extension policy and transactionally deterministic approval-versus-expiration behavior.
- Final counter model plus expiration/reconciliation/monitoring mechanism.
- Idempotency key scope and retention.
- Schedule edits, capacity reduction, closure/cancellation, and handling/notification of affected bookings.
- Required transactional records for confirmation versus recoverable Outbox-driven work such as ticket issuance.

### 4.3 Remaining decisions and implementation blockers

The CAP rows below retain their original register identifiers and should be read together with the accepted principles above. Where a concern is already accepted architecturally, the row remains open only for its detailed policy/schema/operational definition.

| ID | Priority | Open decision | Why it matters / dependent work |
|---|---|---|---|
| CAP-01 | Blocking | Define supported booking units by Activity policy (person, seat, table, group, service unit, or other) and how `Booking.quantity` maps to participants and capacity. | The documents allow several units but do not define a complete unit model. |
| CAP-02 | Blocking | Decide whether a Booking may omit `scheduleId`; if so, define capacity and availability ownership for unscheduled bookings. | Booking.scheduleId is nullable, while capacity accounting is owned by ActivitySchedule. |
| CAP-03 | Blocking | Define the operational meaning of `capacity = null` and whether `confirmedQuantity`/`heldQuantity` continue to be maintained for unlimited schedules. | Unlimited capacity is allowed conceptually, but counter semantics and safeguards are not finalized. |
| CAP-04 | Before launch | Define how Activity-level `bookingType` applies to schedules and whether an Activity may support both Request and Instant Booking for different schedules/options. | Activity currently has one `bookingType` field; mixed booking policies are not described. |
| CAP-05 | Before launch | Define booking cutoff behavior, schedule timezone validation, daylight-saving transitions, and handling of schedule edits after bookings exist. | `timeZone` and `bookingCutoffAt` exist, but detailed temporal policy is not specified. |
| CAP-06 | Blocking | Define the attendance-window policy by Activity category or booking policy and the exact derivation of `attendanceWindowEndsAt`. | Finalization and ticket expiration depend on this trusted value. |
| CAP-07 | Before launch | Define whether a schedule cancellation changes existing Booking states, capacity, Ticket states, and customer notification requirements. | Schedule status includes Cancelled, but the complete cascade behavior is not specified. |
| CAP-08 | Before launch | Define the exact price model (fixed/per-person/per-group/configurable), fee/tax treatment, and immutable price snapshot fields. | Booking has totalAmount/currency but Activity pricing schema is not defined. |

## 5. Booking Domain and Financial Lifecycle

**Review outcome (2026-11-26):** The architectural principles for the review batch `BKG-R01` through `BKG-R08` are accepted with the refinements below. These review identifiers are distinct from the historical `BOOK-01` through `BOOK-08` identifiers retained in the open-decision register that follows. No historical identifier is renamed, reused, or reinterpreted. This acceptance does not finalize cancellation policies, payment/refund/settlement schemas, booking-reference format, or participant-change rules.

### 5.1 Accepted architectural principles

1. **Booking lifecycle:** `Booking.status` describes the commercial/service booking lifecycle. `Expired` for an expired Booking hold is distinct from `Ticket.status = Expired`; Ticket expiration must never automatically change Booking status. `Completed` and `NoShow` are outcomes of the approved attendance-finalization rules, not arbitrary manual status edits. A participant-based Booking may become `NoShow` only when every eligible participant is `NoShow`; partial attendance remains compatible with `Completed`.
2. **Booking identity and history:** Internal document identity and public `Booking.reference` are separate. The reference must be unique within its eventually approved scope, but its format is not selected here. `scheduleId` requiredness remains blocked by the unscheduled-booking decision in CAP. Booking snapshots must preserve sufficient activity, schedule, location, price, and applicable booking-policy terms to retain the historical meaning of the transaction.
3. **Cancellation authority:** Customer, Provider, and Platform cancellation are distinct authorized operations. Cancellation authority does not implicitly grant permission to record a Refund, alter Payment, alter Settlement, or bypass cancellation policy. Exceptional correction of a terminal booking is a separate audited correction operation, not direct reopening or arbitrary status mutation.
4. **Cancellation-policy snapshot:** `bookingPolicySnapshot` must preserve the actual terms applicable to and accepted by the customer at booking time, not merely a mutable `policyId` reference. Cancellation cutoffs, fee percentages, policy precedence, and commercial exceptions remain open.
5. **Independent financial dimensions:** `Booking.status`, `Payment.status`, and `Settlement.status` are separate state dimensions. The current Payment statuses (`Unpaid`, `Paid`, `Refunded`, `Partially Refunded`) are conceptual/proposed and are not a final exhaustive lifecycle for future payment methods. For MVP, Payment at Business / Cash on Arrival is the accepted payment route. Only an authorized actor may record receipt; the customer cannot attest payment to themselves. A payment record should capture amount, currency, actor, timestamp, and reference/evidence appropriate to the approved workflow.
6. **Refund and settlement integrity:** Payment, Refund, and Settlement are distinct concepts. Updating `paymentStatus` alone is not proof of a financial transaction. Financial operations require independently traceable records that are not silently erased or overwritten; corrections use documented reversing/corrective entries. The final financial entity model, commission recognition, payout, and reconciliation policies remain open.
7. **Participant changes:** After confirmation, participants and booking quantity must not be changed through direct or unaudited mutation. Future add/remove/replace/quantity-change operations may be supported only through explicit policy and consistent audited operations that account for capacity, price, tickets, and attendance. A participant with attendance history must never be deleted or replaced in a way that erases that history.
8. **Events, Outbox, and idempotency:** Retryable booking, approval, rejection, and cancellation commands must follow the established idempotency rule: same key and same normalized payload replay the prior logical result; same key with a different payload conflicts. Each business event has a unique identity to prevent duplicate effects. Outbox persistence is distinct from external notification delivery; workers must be restartable/resumable, and delivery failure does not reverse a committed booking operation.
9. **Cross-domain invariants:** Booking operations must respect current AUTH account/membership/permission checks and PROV provider scope. Booking, CapacityReservation, and ActivitySchedule capacity effects must remain consistent and atomic under CAP. BookingParticipant remains the source of truth for participant-level attendance under ATT. Partial attendance does not produce Booking `NoShow`, and attendance finalization/NoShow does not release confirmed capacity retroactively.

### 5.2 Remaining decisions and implementation blockers

- Final Booking status-transition matrix, terminal-state rules, and audited administrative correction workflow.
- Booking reference generation, uniqueness scope, exposure policy, and collision handling.
- Cancellation eligibility, authority by actor, cutoffs, fee calculation, and policy precedence.
- Cash-at-provider payment recording permissions, evidence/reference, corrections, and any intermediate states.
- Payment, Refund, Settlement, commission, payout, and reconciliation entity model and lifecycle.
- Whether participant add/remove/replace and quantity changes are supported after confirmation, and their capacity/price/ticket/attendance effects.
- Event catalogue, Outbox schema, unique event identity, retry/recovery/dead-letter policy, retention, and worker actor representation.
- Idempotency key scope, retention, retry window, cleanup, and required linkage for client-created Bookings.
- Snapshot field set and versioning for activity, schedule, price, and accepted booking/cancellation terms.

The historical `BOOK-01` through `BOOK-08` rows below remain unchanged and retain their original meanings. They record unresolved detailed decisions and must not be repurposed as the identifiers for this review batch.

## 6. Historical Booking, Payment, and Idempotency Open Decisions

| ID | Priority | Open decision | Why it matters / dependent work |
|---|---|---|---|
| BOOK-01 | Blocking | Define cancellation eligibility and refund rules for Pending and Confirmed Bookings, including time cutoffs and provider/customer authority. | Architecture explicitly defers exact cancellation/refund policy. |
| BOOK-02 | Before launch | Define the Request Booking hold-duration configuration schema and platform/Activity minimum and maximum limits. | Default is 30 minutes, configurable within platform limits; limits and precedence are not defined. |
| BOOK-03 | Before launch | Define when/how `paymentStatus` changes for Payment at Business, who may mark payment received, and how corrections are audited. | Current PRD says Cash on Arrival / Payment at Business; Booking has payment fields but no operational payment workflow. |
| BOOK-04 | Later / scope-dependent | Define online payment provider integration, payment intents, webhooks, refunds, reconciliation, and failure handling if online payments are introduced. | PRD places online payments in a future phase. |
| BOOK-05 | Blocking | Define supported launch currencies and country-specific monetary/tax rules. | Multi-country product scope and ISO currency field exist; launch currency policy remains open in PRD. |
| BOOK-06 | Blocking | Define idempotency key format/length, scope, retention duration, retry window, and cleanup policy for Booking and other retryable capacity-affecting commands. | Idempotency is accepted as a principle; exact scope and retention remain unspecified. |
| BOOK-07 | Before launch | Define Booking reference generation, uniqueness scope, exposure policy, and collision handling. | `Booking.reference` is proposed but generation and uniqueness rules are absent. |
| BOOK-08 | Blocking | Decide whether `Booking.idempotencyRecordId` is required for every client-created Booking or nullable only for trusted/imported legacy records. | Client Booking commands require idempotency, while the model field is nullable. |

## 7. Tickets, Check-in, and Attendance

**Review outcome (2026-11-26):** The architectural principles in ATT-R01 through ATT-R09 are accepted with the refinements below. This review preserves the historical `ATT-01` through `ATT-09` identifiers and does not convert illustrative permission names or unresolved implementation choices into approved schemas or contracts. Ticket entitlement, verification credentials, and attendance evidence are distinct concepts.

### 7.1 Accepted architectural principles

1. **Separate domain concepts:** `Booking` represents the commercial commitment; `BookingParticipant` represents an eligible participant where participant-level attendance applies; `Ticket` represents an admission/attendance entitlement; `PublicTicketReference` is a display/search reference; `VerificationToken` is a secret used to verify a ticket; and the attendance/check-in record is evidence that check-in actually occurred. A QR code is only a transport/presentation mechanism for verification data, not a Ticket or Attendance Record.
2. **Ticket ownership and supported ticket models:** every Ticket belongs to exactly one Booking. The system may support an individual Ticket bound to one `BookingParticipant`, or a Booking-level Ticket representing the Booking without replacing participant records. Ticket type and permitted use must be explicit and must never be inferred from the QR payload. A Booking-level Ticket does not authorize implicit group check-in.
3. **Public reference versus secret:** `PublicTicketReference` and `VerificationToken` are distinct. The former may be displayed and used as a public reference under an approved exposure policy; the latter is an unpredictable secret and must not be treated as a public identifier.
4. **Issuance through durable Outbox:** Ticket issuance occurs after Booking confirmation through a durable Outbox event written atomically with the confirmation transaction. A worker issues tickets idempotently by Booking, participant (where applicable), and issuance type. A Booking may be `Confirmed` while issuance is `Pending` or being retried, but issuance work must be observable, recoverable, and must not become silently stuck. Notification/delivery is a separate downstream operation; delivery failure does not undo a successfully issued Ticket.
5. **Ticket lifecycle remains independent:** Ticket state is independent from Booking state and participant attendance. The previously accepted Booking-level Ticket states and meanings remain authoritative: `Valid` (no eligible participant checked in), `PartiallyUsed` (one or more but not all eligible participants checked in), `Used` (all eligible participants checked in), `Expired` (usage window ended), and `Cancelled` (Booking cancelled). These meanings apply to Booking-level Tickets; individual Ticket lifecycle semantics and exact transitions remain open. Ticket expiry does not change Booking status; expiration of a Booking hold does not imply a Ticket existed or expired; `Confirmed` alone does not prove a Ticket is currently usable. Usage-window checks use trusted server time and the approved Activity/Schedule attendance window. Schedule changes must not silently alter Ticket validity and require an explicit, audited process.
6. **QR and verification security:** QR is not proof of attendance and successful verification is not itself Check-in. Verification uses a strong unpredictable token; QR must not expose personal or sensitive Booking details. A public Ticket ID/reference alone is insufficient for admission. The backend validates current Ticket and Booking state, schedule/time window, provider/activity scope, and participant eligibility as applicable. Tokens must be revocable/replacable; old tokens cease to work after revocation/rotation. Full tokens must not be written to exposed application/server logs. Offline Verification is deferred and is not enabled by this decision.
7. **Check-in authorization:** Check-in is a protected server-side operation. The backend verifies authenticated identity, current platform account state, current provider membership/status, scoped permission, and the Ticket/Booking/Activity/Participant relationship. A distinct permission concept such as `attendance.check_in` is accepted as the preferred authorization direction; `attendance.view`, `attendance.correct`, and `attendance.finalize` are illustrative candidates only, not a finalized Permission Catalogue. `bookings.manage`, Staff membership, Ticket read access, or QR access does not implicitly grant Check-in authority.
8. **Atomic and duplicate-safe Check-in:** participant Check-in is transactional and checks the participant's current authoritative attendance state inside the transaction. Repeating the same request with the same idempotency key and normalized payload returns the prior logical result. A new request for an already checked-in participant returns an already-checked-in/duplicate outcome without creating another attendance record. Concurrent attempts result in at most one successful Check-in. Retries after network interruption are safe, and dependent side effects are also deduplicated. Attendance evidence records the acting user, trusted check-in time, and Ticket/verification reference or method as appropriate.
9. **Group Check-in and participant eligibility:** Booking-level QR opens verification of the Booking but does not check in all participants. Group Check-in requires explicit participant IDs; the backend verifies each selected participant belongs to the same Booking and is eligible. Each participant has independent attendance evidence. At least one eligible participant checked in prevents Booking `NoShow`; all eligible participants must be `NoShow` for Booking `NoShow` after finalization. An empty participant list is not `NoShow` and does not imply automatic Booking-level attendance.
10. **Attendance modes are policy-driven:** activities may be configured for no Check-in requirement, Booking-level Check-in, or Participant-level Check-in. The applicable mode is an Activity/Schedule policy, not inferred merely from whether the participant list happens to be empty. Activities that do not require attendance are explicitly excluded from attendance finalization and NoShow processing.
11. **Attendance finalization:** the previously accepted Claim ID, lease, fencing-token, trusted-server-time, bounded-batch, and transactional ownership-validation protocol remains in force. Finalization start time and any grace period are policy-driven by Activity/Schedule; activity end does not automatically imply immediate finalization. Eligible participants with no attendance outcome must be resolved only under the approved finalization policy, not left unresolved indefinitely or prematurely marked `NoShow`. Re-running an already completed finalization is safe and does not rewrite attendance results. Corrections use the separate audited correction path. Finalization/NoShow never releases confirmed capacity.
12. **Corrections and audit:** attendance correction is a distinct, authorized, audited operation; direct/unaudited mutation is prohibited. A correction requires a reason and preserves before/after values, actor, timestamp, and links to participant, Booking, and Activity. It does not erase prior attendance or finalization history and does not automatically alter capacity, Payment, or Refund. Corrections that change Booking outcome (for example `NoShow` to `Completed`) or affect a Ticket or financial dispute require a higher review level under a policy still to be defined. After finalization, the correction process re-evaluates affected derived outcomes while retaining the original finalization record.
13. **Capacity isolation:** Check-in, NoShow, attendance finalization, and attendance correction do not release or modify confirmed capacity and do not implicitly mutate Payment, Refund, or Settlement state.

### 7.2 Remaining decisions and implementation blockers

The historical `ATT-01` through `ATT-09` rows below are retained without renumbering. They identify unresolved implementation/policy details only; the accepted principles above govern their interpretation.

| ID | Priority | Open decision | Why it matters / dependent work |
|---|---|---|---|
| ATT-01 | Blocking | Define the booking-level attendance/service-completion policy for Bookings without BookingParticipant records. | The documents explicitly prohibit treating an empty participant set as NoShow but defer the alternate policy. |
| ATT-02 | Before launch | Define the exact policy selecting booking-level QR, individual Tickets, or both by Activity/category. | Ticket types and behavior are described, but issuance policy is conditional. |
| ATT-03 | Before launch | Define when Tickets are issued for Request and Instant Bookings, which records are transactionally required for Booking confirmation, and how cancellation, schedule changes, and refunds affect Tickets. | Ticket issuance may be Outbox-driven only if it is durable, recoverable, idempotent, and cannot issue duplicates; exact timing and transactional boundary remain open. |
| ATT-04 | Blocking | Define the exceptional correction workflow for attendance after finalization, including historical CheckIn treatment and audit requirements. | Ordinary corrections are prohibited but the correction contract is not defined. |
| ATT-05 | Before launch | Define the exact staff permissions for individual check-in, group check-in, and any booking-level check-in without participant records. | Staff authorization and Activity policy are required, but permission names are not finalized. |
| ATT-06 | Before launch | Define QR token generation parameters, rotation/revocation, scan replay behavior, and whether token hashes alone are stored. | Opaque unpredictable tokens and `tokenHash` are proposed; cryptographic and operational details are not. |
| ATT-07 | Blocking | Define the trusted worker actor representation in `AuditLog.actorUserId` and `IdempotencyRecord.actorUserId`. | Both fields are user-oriented while background operations may run under system identities. |
| ATT-08 | Before launch | Define the operational recovery process for stuck GroupCheckInOperation records, permanent failures, and partial completion. | Durable progress is specified, but operator intervention and alert/escalation policy are not. |
| ATT-09 | Before launch | Define how unused and partially used Tickets are persistently transitioned to `Expired` when the attendance window closes, independently of Booking attendance finalization. | Ticket expiration is required to be independent from attendance finalization, but a dedicated scheduled/lazy transactional processing mechanism is not specified. Check-in must still reject expired windows using trusted server time even if the persisted Ticket status has not yet been updated. |

## 8. Firestore, Storage, and Security

| ID | Priority | Open decision | Why it matters / dependent work |
|---|---|---|---|
| DATA-01 | Blocking | Define final schemas and paths for PlatformRole, Permission, OrganizerBusinessLink, and ActivityReview. | They are referenced but not fully modeled. |
| DATA-02 | Blocking | Define public read projections or separate documents for public Business/Organizer/Activity data versus private fields. | Firestore Rules cannot redact selected fields from a readable document. |
| DATA-03 | Blocking | Define direct client read queries and the matching Rules predicates for each app. | Direct reads are allowed conditionally, but actual queries and scopes are not frozen. |
| DATA-04 | Blocking | Decide whether any client direct writes are allowed and define an explicit field allowlist for each path. | Architecture says only limited explicitly permitted writes; none are currently enumerated. |
| DATA-05 | Blocking | Define Cloud Storage path conventions, public/private buckets or prefixes, upload authorization, size/type limits, and content validation. | Security document intentionally avoids invented paths. |
| DATA-06 | Before launch | Define retention/deletion policy for user data, provider documents, Bookings, Tickets, CheckIns, audit logs, and idempotency records. | No complete lifecycle/retention policy is specified. |
| DATA-07 | Before launch | Define Firestore composite indexes from finalized query specifications and check collection-group access requirements. | The model lists query patterns but no finalized index file. |
| DATA-08 | Before launch | Define backup/restore, point-in-time recovery, data export, incident response, and disaster-recovery objectives. | Deployment and observability are described, but recovery objectives are not. |
| DATA-09 | Before launch | Define data residency and privacy obligations per country as rollout expands beyond Palestine. | Product scope is multi-country; jurisdiction-specific handling remains open. |
| DATA-10 | Before launch | Define Notification/outbox schemas, event identity, delivery attempts, deduplication, retention, and recovery ownership. | Architecture requires persisted notification/outbox records when reliable delivery is needed, but the Data Model does not define a complete notification/outbox entity. |


## 9. Firestore, Storage, and Data Governance — Accepted Review Principles

**Review outcome (2026-11-26):** The architectural principles in DATA-R01 through DATA-R10 are accepted with the refinements below. These review-batch identifiers are distinct from the historical `DATA-01` through `DATA-10` identifiers in Section 8; the historical identifiers and their original meanings remain unchanged. This acceptance does not approve new Firestore Collection Paths, Document Schemas, Storage Paths, direct-access allowlists, Indexes, Security Rules, or deployable contracts. `DATA_MODEL.md` remains the source for the approved data model and paths; `BACKEND_ARCHITECTURE.md` remains the source for data ownership, module boundaries, and server responsibilities. This register does not replace or override either document.

### 9.1 Accepted architectural principles

1. **Data ownership and authoritative sources:** Every domain datum has an authoritative owner and source of truth. Firebase Authentication establishes identity; backend identity/authorization determines account state, permissions, and access context. `BookingParticipant` is the source of truth for participant attendance. `ActivitySchedule` together with trusted capacity operations is authoritative for schedule capacity, holds, and confirmed consumption under CAP. A Public Projection is a published representation, not the authoritative Activity record. Firebase Admin SDK use does not grant unrestricted cross-domain write authority.
2. **Module-to-module communication:** Cross-module collaboration should use approved internal Domain/Application Commands, Query Interfaces, Domain Events, or Read Models as appropriate. A module must not duplicate another module's business rules or mutate another module's owned data directly. A module may read another module's Firestore documents only where that access is part of an explicitly approved internal contract and preserves ownership boundaries.
3. **Firestore structure:** A domain entity does not automatically require its own Collection. Collection/Subcollection/document organization must consider data ownership, access boundaries, read/write patterns, transaction requirements, expected data volume, and query shape. The structure must not make required atomic operations unnecessarily impossible or complex. No existing approved path or structure in `DATA_MODEL.md` is changed by this review. Internal Document ID, public reference, and security token are distinct concepts and must not be collapsed into one value.
4. **Public/private separation:** Public and private data must be separated at a document/projection boundary suitable for Firestore Rules; hiding fields in Flutter is not security. Public Projections contain only data eligible for publication and are generated/updated through trusted backend processes. Publication must respect PROV's `ActivityVersion`, `publicationStatus`, and `publishedVersionId` invariants. Projection failures must fail safely without exposing private data; unpublish/suspension must reliably remove or disable public visibility; projections must be rebuildable/repairable from authoritative sources. Public Provider Profiles remain separate from Business/Organizer memberships, applications, and private documents.
5. **Direct Firestore reads:** Direct client reads are conditional, not a blanket Public Read grant. Each approved query must have all of: an approved public/private data classification and path, matching Security Rules, and a query whose constraints are compatible with the caller's authorization scope. Firestore Rules are not result filters; queries that could return unauthorized documents must fail. Provider access checks current membership state, permission, and provider/resource scope, not `providerId` or selected UI context alone. Each direct query requires a Query Specification covering owner, consumer, classification, authentication, authorization scope, constraints, pagination, and expected Rules behavior. Any query-category examples remain illustrative, not an allowlist.
6. **Direct client writes:** Default Client Write is Deny. Any future exception must be explicitly approved per path and operation, including actor, ownership scope, create/update field allowlist, value types and bounds, immutable fields, permitted state transitions, and automated Rules tests. Permission to write a document does not grant free mutation of all its fields. A client write must never modify fields owned by backend-controlled domains, even if those fields share a document with client-editable data. No direct-write exception is approved by this review.
7. **Cloud Storage:** Firestore stores metadata/relationships; Cloud Storage stores binary objects. Access to sensitive files must not rely on public or long-lived bearer download URLs as though Security Rules reauthorize every access. Sensitive documents must not be exposed through public download links or public documents. File access, upload, revocation, and replacement must follow trusted identity, ownership/membership, permission, and file-classification policies. Validation must inspect actual content as appropriate, not trust extension or client-supplied Content-Type alone; malware/content scanning and review are applied according to the approved file policy. Re-uploading verification evidence preserves historical versions. No new Bucket or Prefix layout is approved here.
8. **Data categories and consistency:** Distinguish (a) authoritative data, (b) materialized/read-optimized projections, and (c) immutable historical snapshots. Every important denormalized field/projection has a documented authoritative source, owning module, update/consistency strategy, monitoring, and repair/rebuild procedure. `Available` remains derived under CAP; any stored availability is a rebuildable projection, not an independently authoritative counter. Booking snapshots and accepted policy snapshots preserve historical commitments and are not refreshed from current source data. `BookingParticipant` remains attendance authority; Booking-level `Ticket.status` follows its own accepted lifecycle and must not be conflated with Attendance.
9. **Queries and indexes:** A Query Catalogue precedes index approval. Each Query Specification records query owner, consumer, data scope, filters, ordering, pagination, expected result volume, security requirements, and index requirements. Indexes are created only for defined queries, not speculative future usage. An index proves neither authorization nor query correctness. Index configuration is version-controlled and actual queries/security behavior are tested with Firebase Emulator, including Collection Group queries where applicable.
10. **Retention, privacy, and deletion:** Account Deactivation, Access Revocation, Data Deletion, Data Anonymization, Data Retention, and Legal Hold are distinct operations/policies. Account deletion does not automatically erase records needed for legitimate commercial, financial, legal, audit, or other parties' rights; this is not permission for indefinite personal-data retention. Export/deletion requests require trusted, auditable workflows that protect other parties' data. Retention periods, residency, and jurisdiction-specific obligations remain open per market.
11. **Operational limits and recovery:** Transaction/Batch sizes and worker concurrency are not fixed by assumption; validate against actual Firestore limits, contention, and load tests. Scheduled workers alone do not guarantee completion: work must be observable, restartable, and recoverable. Reconciliation jobs operate only against documented invariants and safe repair rules. Backup, Point-in-Time Recovery, Disaster Recovery, and Reconciliation are separate capabilities and must be tested, not merely enabled. RPO/RTO are defined according to data criticality rather than assumed to be one global value.
12. **Cross-domain invariants:** AUTH claims are non-authoritative hints; clients cannot grant themselves roles, permissions, or membership authority. PROV public projections are backend-published and membership/private data remains separate. CAP counters and reservations are backend-owned and `Available` is derived. BKG and its snapshots cannot be silently rewritten; financial records are not client-writable. ATT keeps participant attendance, Ticket entitlement, QR verification, and attendance evidence distinct. Each projection has an owner, source, update strategy, and repair mechanism.

### 9.2 Remaining decisions and implementation blockers

The historical DATA-01 through DATA-10 rows in Section 8 remain unchanged and retain their original meanings. Read them together with these accepted principles. Before production design is frozen, the project must still:

- Review every Collection Path and Document Structure against `DATA_MODEL.md`; this review authorizes no path/schema changes.
- Complete the AUTH-owned schemas and contracts for PlatformRole, Permission, OrganizerBusinessLink, Organizer membership, and ActivityReview relationships without inventing paths in this register.
- Define Public/Private Projection fields, publication/unpublication triggers, safe failure behavior, and rebuild/repair ownership in coordination with PROV.
- Approve each direct-read Query Specification and its matching Rules predicates and authorization scope.
- Decide whether any direct Client Writes are needed; if so, approve a narrowly scoped field/operation allowlist and emulator tests. Until then, default deny.
- Define the Cloud Storage access model, exact approved paths, upload constraints, content validation/scanning, sensitive-file access/revocation, and retention.
- Finalize Query Catalogue and only then commit required indexes to version control.
- Complete Firestore and Storage Rules and test them in Emulator Suite; this review does not make `SECURITY_RULES.md` deployable.
- Define retention/deletion/anonymization/export/legal-hold and country-specific privacy/data-residency policies before launch.
- Define and test backup/restore, supported point-in-time recovery, incident response, disaster recovery, and data-criticality-based RPO/RTO before production.
- Validate Firestore transaction/batch/worker limits through emulator and load testing; define operational monitoring and reconciliation repair invariants.

No Firestore schema, Collection Path, Storage Path, Bucket topology, permission identifier catalogue, direct read/write allowlist, or index is approved merely by accepting DATA-R01 through DATA-R10.

## 10. API & Backend Contracts — Accepted Review Principles

**Review outcome (2026-11-26):** API-R01 through API-R10 are accepted as architectural principles with the clarifications below. This acceptance does not freeze Firebase Function exports, HTTPS routes, request/response schemas, validation libraries, error-code strings, event/outbox schemas, API versioning, pagination configuration, or operational limits. `API_CONTRACTS.md` remains a design-level draft and its Logical Operation Catalogue is not an export catalogue.

### 10.1 Accepted architectural principles

1. **Transport is selected per operation:** Callable Functions are the default external interface for authenticated Flutter application commands; HTTPS Functions are used where conventional HTTP semantics are appropriate, including external webhooks and integrations. Trusted internal operations and workers do not need a Callable entry point. Direct Firestore reads/writes remain governed by DATA access decisions and matching Security Rules. Transport types must not leak into Domain or Application Use Cases.
2. **Separate entry points, application operations, and execution triggers:** distinguish external Entry Points, internal Application Use Cases/Operations, and trusted Worker or Scheduled Triggers. A Logical Operation Catalogue is not a Firebase Functions Export Catalogue. Cross-module collaboration uses approved Application interfaces, Domain Events, or Read Models; modules must not import another module's private repositories to mutate its data.
3. **No implicit trust in identifiers or context:** the backend derives Actor identity from trusted authentication context. Client-supplied IDs (including provider, booking, activity, and resource identifiers) are untrusted references, not authorization evidence. Actor, selected Provider Context, and actual Resource Scope are distinct. The backend validates the target resource's ownership/provider relationship and current membership, account state, permission, and scope. Context may be derived server-side when safe; it need not be redundantly supplied by the client.
4. **Commands and Queries are conceptually separate:** Commands change business state and must use current authoritative backend state, not client-supplied status/snapshots as truth. Queries do not change business state, though separately governed operational telemetry/security records may be produced. A query for a long-running operation reads its authoritative persisted progress. This separation does not require different transports.
5. **Validation is server-owned and module-aware:** external requests are validated server-side. The external contract must explicitly define unknown-field behavior; strict rejection is the accepted recommendation, especially for sensitive commands, but its exact shared policy remains to be finalized. Responses must also be validated/projected to prevent private/internal fields leaking. Each owning module controls its business validation; shared primitives do not own domain rules. No validation library/version is selected.
6. **Idempotency protects business effects across distinct retry mechanisms:** distinguish Client Retry, Firestore Transaction Retry, and Worker Retry. Client Idempotency Keys, Transaction retry safety, and Worker/Event identity are separate mechanisms and must not be conflated. Payload hashing uses normalized contract-approved fields, not raw JSON serialization. Booking, financial, ticket, and other consequential effects must remain duplicate-safe beyond the retention of a client idempotency record. Exact key format, retention, cleanup, and per-operation requirements remain open.
7. **Transaction boundaries are use-case-owned and invariant-driven:** use a Firestore transaction when the operation's invariants require atomic reads/writes; do not add transactions mechanically to every use case. Complete required reads before writes, revalidate current state inside the transaction, and keep callbacks free of external side effects. Distinguish committed Business Events, durable Outbox Records, Worker Executions, and External Deliveries. Business commit does not imply successful external delivery. Reliable follow-up work must be durably recorded and recoverable.
8. **Errors and asynchronous outcomes are distinct:** stable application error categories/codes are independent of Firebase or HTTP transport codes and localized message text. Distinguish request failures, business failures, operational failures, and accepted/processing outcomes. `Processing Pending` or `Accepted` may be a normal asynchronous result, not a business error. Responses must not disclose resource existence or private details to unauthorized callers.
9. **External contract compatibility and bounded queries:** versioning protects published external contracts; internal Use Cases do not require artificial API versioning. List contracts must support bounded, deterministic pagination where needed, with opaque cursors that cannot bypass authorization/query scope. Long-running work distinguishes request acceptance from completion and exposes a durable operation reference/status when applicable. Exact versioning, cursor representation, page limits, request limits, and retry/time limits remain open.
10. **Contracts are testable and observable:** tests include negative authorization and tenant/provider-scope substitution cases, transaction/idempotency/worker recovery cases, and backward compatibility against actually published contracts. Correlation identifiers should connect a request to its Use Case, transaction, Outbox, and Worker stages where applicable. Logs are not Audit Logs; actor/worker attribution follows the audit policy. Secrets, QR/verification tokens, credentials, and unnecessary personal payloads must not be logged. Outbox delay and worker failures are operational health signals.

### 10.2 Cross-cutting rules

- **Contract ownership:** each module owns the business contract and validation rules for its operations.
- **Least privilege:** each operation receives only the authorization and resource scope it needs.
- **Explicit side effects:** every Command contract records its business effects and any asynchronous/external follow-up effects.
- **No implicit trust:** client-supplied role, status, price, ownership, identity, or context never substitutes for server-side authority.
- A future operation definition should identify its logical name/type, entry point/transport, owning module, authentication and authorization, provider context/resource scope, request/response contracts, error categories, idempotency, transaction boundary, events/outbox effects, operational constraints, and tests. This is a future documentation checklist, not a request to freeze schemas in this review.

### 10.3 Remaining decisions and implementation blockers

| ID | Priority | Remaining decision | Why it matters / dependent work |
|---|---|---|---|
| API-01 | Blocking before external contract freeze | Audit every logical operation and classify its external entry point, owning module, command/query role, or trusted trigger. | Prevents accidental public exports and cross-module boundary violations. |
| API-02 | Blocking before external contract freeze | Define per-operation authentication, authorization, Provider Context, and Resource Scope requirements, including resource-ID substitution defenses. | Required for tenant isolation and least privilege. |
| API-03 | Blocking before external contract freeze | Define Request and Response schemas, validation ownership, unknown-field policy, output projection, and schema compatibility. | No production DTO or endpoint may be inferred from examples. |
| API-04 | Blocking before external contract freeze | Define Client Idempotency requirements per command, normalized payload hashing, and durable duplicate-effect protection. | Must align with BOOK/BKG idempotency decisions and non-booking operations. |
| API-05 | Blocking before external contract freeze | Define transaction boundaries and the distinction between business events, outbox records, worker attempts, and external delivery. | Must preserve CAP, PROV, BKG, and ATT atomicity and recovery invariants. |
| API-06 | Blocking before external contract freeze | Define stable application error-code registry and mapping to Callable/HTTPS transport behavior, safe messages, and retry metadata. | Prevents client coupling to Firebase/HTTP implementation errors. |
| API-07 | Before launch | Define external API versioning and backward-compatibility/deprecation policy. | Protects already released mobile/dashboard clients without imposing needless internal versioning. |
| API-08 | Before launch | Define Query Catalogue, deterministic pagination/cursor contracts, page/request limits, and query-specific authorization constraints. | Required before exposing bounded list APIs and indexes. |
| API-09 | Before production | Define rate limits, abuse controls, client timeout/retry/backoff expectations, long-running operation limits, and worker concurrency bounds. | Required for safe operational behavior under load and abuse. |
| API-10 | Before production | Define correlation/trace propagation, logging/redaction, metrics/alerts, audit attribution, and backward-compatibility/negative-authorization test suites. | Required for incident investigation without leaking sensitive data. |

## 11. Operational and Release Decisions

| ID | Priority | Open decision | Why it matters / dependent work |
|---|---|---|---|
| OPS-01 | Blocking before backend foundation freeze | Pin the Node.js LTS version, Firebase Functions SDK, Admin SDK, TypeScript, package manager, and build tooling. | Architecture explicitly says versions must be verified and pinned during implementation. |
| OPS-02 | Before production | Validate transaction batch sizes, pagination, group-check-in parallelism, and attendance finalization batch sizes through Emulator and load tests. | No fixed values are approved; Firestore limits and contention must be measured. |
| OPS-03 | Before production | Define attendance finalization lease duration and renewal interval configuration. | They must be configurable; no fixed numeric values are prescribed. |
| OPS-04 | Before launch | Define alert thresholds, retry/backoff limits, dead-letter or quarantine handling, and operational dashboards. | Observability categories exist, but numeric thresholds and on-call procedures do not. |
| OPS-05 | Before launch | Define environment regions, deployment approvals, secrets rotation, and production release controls. | Separate environments are required, but exact project/region and release policy remain open. |
| OPS-06 | Later / scope-dependent | Confirm MVP inclusion and detailed schemas for Favorites, Reviews, Notifications, Analytics, Complaints, and Reports. | PRD and Data Model explicitly leave some supporting domains subject to prioritization. |
| OPS-07 | Blocking before booking/capacity implementation | Define the final schedule capacity counter model, reconciliation algorithm, expiration worker recovery, monitoring, and alert/escalation behavior. | Capacity counters are trusted backend-maintained aggregates; expiration must be effective before cleanup and reconciliation must not double-release or overbook. |

## 12. Decisions Already Established — Do Not Reopen Without New Evidence

The following are established in the project context and current source documents:

- Fusha is a multi-vendor experiences and activities discovery/booking marketplace, not an LMS.
- Strategic product scope is global/multi-country; the current PRD v1 describes Palestine as the initial market context.
- Hybrid revenue model: commissions, provider subscriptions, and paid services.
- Marketplace discovery and booking are the core transaction engine; community features are secondary.
- Backend direction: Firebase-first Modular Monolith, TypeScript, Cloud Functions Gen 2, Cloud Firestore.
- Platform roles and provider memberships are separate; provider membership never grants platform administration.
- Backend derives identity from trusted authentication context; client `userId` is not proof of identity.
- Request Booking uses a temporary hold; default duration is 30 minutes, configurable within platform limits.
- Booking, Payment, and Settlement statuses are independent; cancellation authority does not imply financial authority.
- Booking snapshots preserve the historical activity, schedule, and accepted booking-policy terms; later policy/activity edits do not rewrite existing commitments.
- Ticket expiration is independent of Booking expiration/status; `Completed` and `NoShow` arise from approved attendance finalization rules.
- Financial transactions require independently traceable records; `paymentStatus` alone is not an accounting record, and corrections must be documented through reversing/corrective entries.
- Confirmed participant/quantity changes cannot be made through direct or unaudited mutation; any future supported changes must preserve participant attendance history and reconcile capacity, price, tickets, and attendance.
- Booking-related events use unique identities and durable, restartable Outbox processing; notification delivery is separate from successful event persistence and booking commit.
- ProviderApplication, Provider, and Membership are separate lifecycle records; provider approval and initial Owner activation are atomic and idempotent, with external notifications processed through a durable Outbox after commit.
- Provider review history is retained per exact ActivityVersion/review round; `Approved` does not imply `Published`, and public projections must not expose unapproved/private data.
- Booking snapshots remain immutable; changes affecting existing bookings require an explicit handling/notification policy.
- Instant Booking confirms directly and does not create a temporary CapacityReservation.
- Capacity belongs to ActivitySchedule and is updated transactionally by trusted backend operations.
- Capacity is conceptually separated into its limit, temporary `Held`, and confirmed `Confirmed` consumption; `Available` is derived, not an independent authoritative counter. The exact unit and counter schema remain open.
- Booking count, participant count, and capacity consumption quantity are distinct; every booking must specify its capacity consumption under the eventual activity/schedule policy.
- Instant Booking creation and capacity consumption are atomic; clients and provider dashboards cannot directly mutate capacity counters.
- Schedule changes must preserve existing commitments and immutable Booking snapshots; schedule closure blocks new bookings, and cancellation requires explicit handling of affected bookings.
- Booking confirmation must define its required transactional records; downstream Outbox work must be durable, recoverable, idempotent, and duplicate-safe.
- Expired holds must not remain valid merely because scheduled cleanup is delayed.
- Firestore TTL is not responsible for releasing capacity.
- Idempotency is required for retryable booking operations.
- Attendance is tracked per eligible BookingParticipant when participant-level attendance applies.
- Partial attendance is valid; at least one checked-in eligible participant yields Booking `Completed` after finalization.
- Booking `NoShow` is permitted only when every eligible participant is `NoShow`.
- Booking-level QR scanning never checks in all participants automatically.
- Group check-in requires explicit authorization and selected participant IDs.
- Ticket state and participant attendance state are separate.
- Attendance finalization uses a unique claim ID, configurable lease, fencing checks, bounded batches, and trusted server time.
- Lease renewal is transactional; an expired lease must not be renewed.
- Attendance finalization and participant NoShow do not release confirmed capacity.
- Attendance finalization and participant NoShow do not release confirmed capacity.
- Ticket entitlement, public Ticket reference, secret Verification Token, QR presentation, and attendance evidence are separate concepts; QR verification is not Check-in.
- Every Ticket belongs to exactly one Booking; individual participant-bound and Booking-level Ticket models may both be supported, with explicit use semantics.
- Ticket issuance follows Booking confirmation through a durable, idempotent, observable, and recoverable Outbox workflow; Ticket delivery/notification is independent.
- Booking-level Ticket states remain `Valid`, `PartiallyUsed`, `Used`, `Expired`, and `Cancelled` with the meanings documented in Section 7; individual Ticket lifecycle details remain open.
- Offline Ticket Verification is deferred and is not enabled by the accepted attendance principles.
- Check-in is a protected backend operation with independent scoped authorization; Booking management, Staff membership, and Ticket/QR read access do not implicitly grant it.
- Participant Check-in is transactional and duplicate-safe; group check-in requires explicit participant IDs and never checks in all participants implicitly.
- Attendance mode is explicitly policy-driven: no check-in, Booking-level check-in, or Participant-level check-in. Empty participant lists do not imply Booking-level check-in or NoShow.
- Attendance corrections require a separate audited operation and reason; they preserve prior evidence and do not automatically alter capacity or financial records.
- Firebase Admin SDK bypasses Firestore Security Rules; server-side authorization is mandatory.
- Data ownership is domain-scoped; Firebase Admin SDK does not grant unrestricted cross-domain mutation authority, and internal modules collaborate through approved interfaces/events/read models.
- `DATA_MODEL.md` remains authoritative for approved data entities/paths and `BACKEND_ARCHITECTURE.md` for ownership/module/server boundaries; the decision register does not replace either.
- Public/private data separation is enforced at document/projection boundaries; public projections are backend-controlled, publication-eligible, safely revocable, and rebuildable.
- Direct Firestore reads require an approved query specification, matching Rules, and query constraints compatible with the caller's authorization scope; Rules are not query filters.
- Default direct Client Write is Deny; any exception requires a narrowly scoped path/actor/field/transition allowlist and emulator tests. No exception is approved by the DATA review.
- Sensitive Cloud Storage files must not rely on public or long-lived bearer download URLs as though Rules reauthorize every access; file access and validation follow approved classification and authorization policy.
- Authoritative data, materialized projections, and immutable historical snapshots are distinct; each important projection has an owner, source, update strategy, and repair path.
- Query Catalogue and Query Specifications precede index approval; indexes are version-controlled and do not establish query authorization.
- Account deactivation, access revocation, deletion, anonymization, retention, and legal hold are distinct; retention and privacy policies remain jurisdiction-specific open decisions.
- Firestore limits are validated through testing; recovery includes tested backup/restore, applicable point-in-time recovery, disaster recovery, reconciliation invariants, and data-criticality-based RPO/RTO.
- Management Dashboard initial authentication uses Email + Password and Google Sign-In; Phone OTP is deferred.
- Sensitive/high-privilege accounts require MFA; exact enforcement details remain open.
- Management Dashboard is one Flutter Web app with separate Provider and Platform Admin logical contexts; backend authorization remains authoritative.
- API-R01 through API-R10 architectural principles are accepted: per-operation transport; separate entry points/use cases/workers; server-derived identity and resource-scope authorization; Commands/Queries separation; module-owned request/response validation; distinct client/transaction/worker retry mechanisms; invariant-driven transactions and durable Outbox; transport-independent error categories and explicit asynchronous outcomes; versioned bounded external contracts; and tested, observable operations. Exact wire contracts and operational settings remain open.
- BMS-R01 through BMS-R08 are accepted: complete MVP commercial journey; P0 core modules; durable Outbox and operational recovery from the beginning; minimum administration; deferred future-facing features; parallel minimum Discovery read models; explicit module Definition of Done; mandatory domain/security gates; vertical-slice delivery; and no speculative abstractions.
- The official TypeScript/Firebase Functions Gen 2 backend source path is `backend/functions`; `packages/firebase_backend` remains the Flutter/Dart Firebase Client integration package. Dart/Melos and Node.js workspaces and CI checks remain independent.

## 14. Backend MVP Scope and Implementation Order — Accepted Review Decisions

**Review outcome (2026-11-26):** BMS-R01 through BMS-R08 are accepted with the clarifications and controls below. These decisions define MVP scope and execution sequencing; they do not simplify the approved security, domain, data-ownership, or reliability architecture. They do not close the detailed schema and policy gates already recorded in this register.

### 14.1 Accepted decisions

1. **BMS-R01 — Complete commercial journey:** The MVP must support the end-to-end journey from provider application and review, through activity authoring/review/publication, schedule and capacity setup, public discovery, Instant Booking or Request/Approval Booking, cancellation/hold expiration, ticket availability and status verification, ticket verification/check-in, attendance finalization, and operational monitoring. Booking, Payment, and Settlement lifecycles remain separate. A customer must be able to retrieve the booking reference and query ticket issuance/status even when ticket issuance is asynchronous.
2. **BMS-R02 — MVP modules and priorities:** P0 modules are `identity`, `providers`, `catalog`, `publishing`, `scheduling`, `bookings`, `tickets`, `attendance`, `discovery`, `audit`, and minimum `administration`. `notifications` is P1 only for expansion of delivery channels and advanced delivery features; durable Outbox persistence, queryable processing state, retry/recovery, and essential operational notifications are foundational requirements from the start. `engagement` is P2 and scope-dependent. Minimum administration means only the controls required for provider/activity moderation, essential account administration, and sensitive operations under approved Admin/Super Admin authorization; it does not imply a large administrative product.
3. **BMS-R03 — MVP product surfaces:** Customer App, Provider Dashboard, and Platform Admin Dashboard implement only the capabilities needed for the approved journey. Business and Organizer memberships/permissions remain independent; provider context selection never grants authority; every operation validates actual resource scope. Published Activity versions remain immutable while revisions are reviewed. Admin cannot elevate their own privilege; Admin and Super Admin remain distinct from provider memberships; required MFA and audited sensitive actions apply. Cash receipt may be recorded only by an authorized actor, with amount, currency, actor, time, and reference traceability; customer-submitted payment claims are not authoritative financial records. Confirmed participant/quantity changes are not direct or unaudited edits and remain subject to the BKG rules.
4. **BMS-R04 — Deferred scope:** Community feed/posts/comments/direct messaging, advanced reviews, full complaints workflow, coupons/promotions, advanced analytics/reports, offline ticket verification, payment gateway, automated payouts, subscription billing, and recommendation engine are deferred unless separately approved. Deferring Reviews does not prohibit a later minimal rating feature; no rating system is required by this decision. Deferring a complaints workflow does not remove essential incident/safety response or authorized activity suspension controls. Deferring payment infrastructure does not alter the strategic hybrid revenue model.
5. **BMS-R05 — Implementation order and parallel work:** Execute Backend Foundation first; then Identity & Providers; then Catalog & Publishing. Minimum public Discovery read models may be developed in parallel with Catalog & Publishing, but must not expose ineligible/unpublished/private data. Next implement Scheduling & Bookings only after CAP/BKG gates are closed; then Tickets & Attendance only after their model and attendance gates are closed. Complete Discovery and Dashboard read models thereafter, followed by expanded Notifications & Operations. This sequencing allows independent work to proceed early but never bypasses a feature's commercial, security, data, or contract gates.
6. **BMS-R06 — Module Definition of Done:** A module is not complete merely because files exist or unit tests pass. Review responsibilities and ownership, dependency boundaries, authorization, data ownership, Domain/Application tests, relevant Infrastructure/Emulator tests, concurrency and idempotency tests for sensitive operations, and absence of unauthorized direct access to another module's private repositories. No commercial Collection, Firestore Path, schema, or Function export is introduced without approval in its owning contract/source document.
7. **BMS-R07 — Explicit implementation gates:** Foundation scaffolding and local tests may proceed without a production Firebase project. Pin a mutually compatible minimum toolchain (Node.js runtime, TypeScript, Firebase Functions SDK, Firebase Admin SDK, Firebase CLI, and package manager) before establishing the reproducible Foundation. A local Emulator project ID may be used for tests. Production Firebase configuration is required for real integration and deployment, not local scaffolding. AUTH schemas and permissions block Identity operations; Provider permissions/contracts block Provider operations; Activity Version contracts block Publishing; capacity unit/counter and booking transaction-core decisions block Capacity/Booking logic; Ticket model details block issuance; Attendance Mode policy blocks check-in/finalization. Security Rules do not block Domain development but block exposure of unapproved direct reads. No temporary business logic may be built on guessed domain contracts.
8. **BMS-R08 — Scope discipline:** Do not create generalized abstractions for hypothetical future use cases. Do not implement payment-provider, recommendation, subscription, or unapproved role/permission frameworks before their actual requirements are approved. Conversely, MVP scope never justifies weakening current security, business invariants, data ownership, or authorization boundaries.

### 14.2 Cross-cutting delivery rules

- **MVP scope is not architecture simplification:** deferring features does not permit bypassing Clean Architecture, module ownership, backend authorization, or reliability requirements.
- **No feature exposure before gates:** no user-facing feature is exposed until its required commercial, security, data, and contract gates are satisfied.
- **End-to-end vertical slices:** once dependencies are ready, prefer a complete testable path across entry point, application logic, data, and client integration over isolated layers with no end-to-end validation.
- **Definition of Done:** each module/feature has explicit acceptance and test criteria; completion is evidenced by passing required checks, not by implementation status alone.
- **Outbox reliability from the beginning:** durable business follow-up work, queryable processing state, recovery/retry, and worker observability are foundational. External notification channels may be delivered incrementally.

## 15. Backend Workspace Location and Toolchain Boundaries — Accepted

**Review outcome (2026-11-26):** `backend/functions` is the official TypeScript/Firebase Cloud Functions Gen 2 backend source path inside the Fusha monorepo. The existing `packages/firebase_backend` remains the Flutter/Dart integration package and is not repurposed.

1. **Independent workspaces:** Melos and the Dart Workspace continue to manage Flutter applications and Dart packages. `backend/functions` manages its own Node.js/TypeScript dependencies and lockfile independently.
2. **SDK separation:** Firebase Client SDK dependencies and client-side integration remain in `packages/firebase_backend`; trusted backend logic uses Firebase Admin SDK and Cloud Functions SDK only within `backend/functions`. Do not move trusted business logic into the Flutter package or import Firebase Client SDK into the backend.
3. **Firebase CLI configuration location:** the location of `firebase.json` and the Firebase project configuration is not prescribed by this path decision. Before introducing Firebase CLI configuration, inspect and approve the repository-level arrangement, including the Functions source mapping to `backend/functions`. Do not create `.firebaserc`, production project IDs, or deployment targets by assumption.
4. **No premature commercial implementation:** the Foundation may establish technical boundaries and shared primitives only. It must not create commercial Function exports, Collections, Firestore paths, domain schemas, or guessed API contracts.
5. **Independent CI:** Backend checks must be runnable independently of Flutter/Melos checks. Changes under `backend/functions` must not break or unnecessarily execute the existing Dart CI workflow; changes to existing Flutter workspace configuration must be avoided unless specifically required and reviewed.

The `backend/functions` path decision does not close OPS-01's exact toolchain pinning until the compatible versions are committed and verified in the Foundation implementation.

## 13. Resolution Workflow

For each decision:

1. Record the approved decision in the relevant product/backend source.
2. Update the Data Model if entity fields, relationships, or paths change.
3. Update Backend Architecture if ownership, transaction, or module boundaries change.
4. Update Security Rules and API Contracts.
5. Add emulator/unit/concurrency tests for the new invariant.
6. Remove or mark the item resolved in this register.
7. Do not deploy rules or expose endpoints while a blocking item remains unresolved.
