# Fusha — Backend Documentation Review Report

**Review date:** 2026-11-26  
**Sources reviewed:** Uploaded `BACKEND_ARCHITECTURE.md` (2,888 source lines), `DATA_MODEL.md` (1,930 source lines), current repository `docs/product/PRD.md`, and established Fusha project decisions.  
**Result:** Cross-reviewed documentation package prepared; implementation readiness remains conditional on the blocking decisions below.

---

## 1. Executive Summary

The Backend Architecture and Data Model share a coherent overall direction:

- Firebase-first Modular Monolith.
- TypeScript on Cloud Functions Gen 2.
- Cloud Firestore as the primary operational database.
- Explicit module ownership and layered architecture.
- Server-authoritative authorization.
- Transactional Booking and capacity management.
- Request Booking holds and direct Instant Booking confirmation.
- Idempotent state transitions and bounded expiration reconciliation.
- Ticket lifecycle separated from participant attendance.
- Durable group check-in and participant-level attendance.
- Claim/lease/fencing protocol for attendance finalization.
- Trusted backend processing, auditability, and operational recovery.

No change was made to these established domain rules.

The documents are **not yet production implementation specifications**. The Data Model labels its Firestore layout as proposed, and important authorization entities, provider relationships, review records, direct-read/write policies, Storage paths, and API wire schemas remain incomplete. Deployable Rules and exported Function contracts would require decisions not present in the source material.

## 2. Sources and Review Coverage

### Source documents

1. `BACKEND_ARCHITECTURE(3).md` — all 2,888 lines reviewed by section.
2. `DATA_MODEL(3).md` — all 1,930 lines reviewed by section.
3. `docs/product/PRD.md` from the repository — consulted to reconcile initial product scope, roles, payment strategy, and open requirements.
4. Established project decisions — used only where newer decisions supersede earlier draft wording.

### Review dimensions

- Architecture and module ownership.
- Identity, roles, memberships, and authorization boundaries.
- Entity completeness and field consistency.
- Firestore paths and query implications.
- Booking and capacity lifecycle.
- Idempotency and concurrency.
- Tickets, check-in, group operations, and attendance finalization.
- Security, Storage, and Admin SDK boundaries.
- API operation catalogue and error requirements.
- Testing, deployment, observability, and recovery.
- Cross-document references and unresolved decisions.

## 3. Consistency Findings

### 3.1 Areas aligned across the two source documents

| Area | Review result |
|---|---|
| Backend architecture | Consistent Modular Monolith and Firebase-first direction |
| Layer boundaries | Domain/application independence from Firebase SDKs is consistent |
| Module ownership | Identity, providers, publishing, bookings, tickets, attendance, notifications, and audit responsibilities are broadly aligned |
| Identity | Trusted UID from auth context; client user ID is not identity proof |
| Authorization | Platform roles and provider memberships are distinct |
| Capacity | Schedule-level capacity counters and transactional updates are consistent |
| Request Booking | Pending Booking + Active hold; 30-minute default; conversion/release/expiration rules align |
| Instant Booking | Direct confirmation; no temporary CapacityReservation |
| Expiration | Trusted clock, scheduled processing plus synchronous reconciliation, no TTL-based capacity release |
| Idempotency | Persisted actor/operation/key scope and normalized request hash are consistent |
| Attendance | Participant-level attendance and partial attendance rules align |
| Group check-in | Explicit participant selection and durable progress tracking align |
| Ticketing | Ticket status is distinct from participant attendance |
| Finalization | Claim ID, lease, fencing, bounded batches, retry/recovery, and trusted server time align |
| Capacity after attendance | Attendance and finalization do not release confirmed capacity |

### 3.2 Clarifications applied

1. **Strategic market scope:** Updated Data Model metadata to distinguish global/multi-country strategic scope from Palestine as the market named in the current PRD v1. This avoids turning the current PRD market statement into a single-country architecture constraint.
2. **Business ownership:** Explicitly recorded the unresolved relationship between `Business.ownerUserId` and `BusinessMembership.role = Owner`.
3. **Activity review/publication:** Clarified that `ActivityVersion.reviewStatus` and `Activity.publicationStatus` are separate fields whose exact transition mapping remains to be approved.
4. **Incomplete entity definitions:** Marked `PlatformRole`, `Permission`, `OrganizerBusinessLink`, and `ActivityReview` as incomplete schema decisions rather than filling in guessed fields.
5. **Attendance transaction coordination:** Clarified that participant check-in updates the parent Booking counter in the same transaction when participant counters apply, making the shared Booking coordination point explicit.
6. **Direct client writes:** Clarified that no general direct-write allowlist currently exists; default client writes remain denied until an explicit field-level policy is approved.
7. **MFA:** Added the established requirement for MFA on sensitive/high-privilege accounts while leaving factors, step-up, recovery, and enforcement points open.
8. **Group check-in operation catalogue:** Added the individual and group check-in application use cases already described in the attendance architecture.
9. **Independent Ticket expiry:** Added an explicit requirement that Ticket status expiry be persisted independently of Booking attendance finalization; the exact processing mechanism remains open.

These are clarifications and traceability corrections. They do not approve new role names, permission values, Firestore paths, API endpoint names, or payment rules.

## 4. Important Gaps and Risks

### Blocking before production schema/rules/API freeze

- PlatformRole and Permission lack complete schemas and authoritative paths.
- OrganizerMembership role/status enumerations are incomplete.
- OrganizerBusinessLink has a proposed path but no complete schema.
- ActivityReview has a proposed entity/path but no complete schema.
- Business ownership has two representations without a declared authority.
- ActivityVersion review status and Activity publication status need a transition map.
- Public/private data projections and direct Firestore query scopes are not frozen.
- No direct client-write field allowlist is approved.
- Ticket expiration must occur independently from attendance finalization, but its persisted processing mechanism is not specified.
- Cloud Storage paths and file constraints are not defined.
- API payloads, response schemas, exported Function names, and stable error-code strings are not frozen.
- Booking quantity/participant/capacity-unit relationships need a complete policy.
- `Booking.scheduleId` is nullable while capacity is schedule-owned; unscheduled booking behavior is not specified.
- The booking-level attendance policy for bookings without participants is still open.
- Payment lifecycle and cancellation/refund policy are incomplete.

### Important before launch

- MFA enforcement and recovery.
- App Check enforcement by endpoint.
- User suspension/disable semantics.
- Booking reference generation.
- Idempotency retention duration.
- Ticket issuance, QR token details, and the independent persisted Ticket-expiration processing mechanism.
- Attendance correction policy.
- Schedule cancellation effects.
- Data retention, deletion, privacy, and data residency.
- Rate limits, abuse protection, backup/restore, and operational alert thresholds.

The full register is in `OPEN_DECISIONS.md`.

## 5. Companion Documents Added

| File | Purpose | Readiness |
|---|---|---|
| `SECURITY_RULES.md` | Authorization principles, access matrix, protected state, Firestore/Storage design, test requirements | Design specification; not deployable Rules code |
| `API_CONTRACTS.md` | Logical operation catalogue, common contract requirements, idempotency, errors, transaction requirements | Operation catalogue; wire contracts not frozen |
| `OPEN_DECISIONS.md` | Consolidated decisions that must not be silently invented | Ready for decision tracking |
| `README_AR.md` | Package map, status, integration order, and safety notes | Ready |

## 6. Readiness Assessment

| Workstream | Assessment |
|---|---|
| Architectural direction | Sufficiently defined for continued detailed design |
| Booking/capacity domain policy | Strongly specified; validate with implementation tests |
| Attendance/finalization protocol | Strongly specified; validate with concurrency and recovery tests |
| Core entity model | Useful conceptual draft, but incomplete for production schema |
| Firestore path design | Proposed; not final |
| Authorization matrix | Principles defined; exact permissions and several schemas unresolved |
| Firestore/Storage Rules | Not deployable yet |
| API contracts | Logical operation catalogue only; wire contracts not frozen |
| Indexes | Query patterns listed; concrete indexes not finalized |
| Production readiness | Not ready until blocking decisions, implementation, emulator tests, load tests, and operational controls are completed |

## 7. Explicit Non-Goals of This Review

This package does not:

- Implement backend TypeScript or Firebase Functions.
- Generate production Firestore or Storage Rules.
- Freeze callable function names or JSON payloads.
- Invent permission identifiers or role mappings.
- Invent missing entity schemas or collection paths.
- Decide cancellation/refund, payment, pricing, or no-participant attendance policies.
- Change the PRD itself.
- Claim that integration, emulator, or load tests have passed.

## 8. Recommended Next Sequence

1. Resolve the blocking Identity/Provider/Activity schema decisions in `OPEN_DECISIONS.md`.
2. Approve the role-to-permission matrix and public/private data projections.
3. Finalize the Firestore schemas and query/index specifications.
4. Freeze the API request/response/error contracts.
5. Convert `SECURITY_RULES.md` into deployable Firestore and Storage Rules.
6. Implement backend modules with Emulator tests, concurrency tests, and load tests.
7. Complete operational controls and only then prepare production release.

**Final conclusion:** The source documents provide a solid conceptual backend foundation, especially for booking, capacity, idempotency, ticketing, and attendance. They should proceed as reviewed design documents, but must not yet be treated as production-ready schemas, Security Rules, or API contracts.
