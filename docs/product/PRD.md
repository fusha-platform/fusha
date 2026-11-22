# Fusha | فُسحة
# Product Requirements Document (PRD)

**Document Version:** 1.0 – Initial Draft
**Product Name:** Fusha (فُسحة)
**Product Type:** Multi-Vendor Experiences & Activities Discovery and Booking Marketplace
**Target Market:** Palestine
**Primary Platforms:** Flutter Customer Mobile App + Flutter Web Management Dashboard
**Tagline:** كل يوم إله فُسحة.
**Core Value:** Discover. Book. Experience.

---

## 1. Product Overview

### 1.1 What is Fusha?

Fusha is a Palestinian digital marketplace that connects people looking for activities, experiences, events, and recreational services with businesses, venues, organizers, and activity providers.

The platform enables customers to discover local experiences, explore available options, review details and prices, check schedules and availability, and make reservations through a unified digital experience.

At the same time, Fusha provides management tools for businesses and organizers to publish and manage their activities, schedules, capacity, and bookings.

Platform administrators can oversee users, providers, activities, bookings, and platform operations.

### 1.2 Product Vision

To become a trusted digital destination for discovering and booking experiences across Palestine, making it easier for people to find something meaningful to do and for local businesses to reach more customers.

### 1.3 Core Value Proposition

- **For Customers:** Discover interesting local activities and book them conveniently.
- **For Businesses:** Reach potential customers and manage activities and reservations.
- **For Organizers:** Publish and manage events and experiences.
- **For Platform Administrators:** Manage and monitor the marketplace from one place.

---

## 2. Problem Statement

Discovering local activities and experiences can require searching across multiple social media pages, websites, and communication channels.

Customers may struggle to find reliable information about:
- Available activities and experiences.
- Prices and included services.
- Locations and directions.
- Dates, schedules, and available capacity.
- Booking requirements and confirmation status.

Meanwhile, local businesses and organizers may lack a unified tool to publish activities and manage reservations.

Fusha aims to bring discovery, booking, and activity management together in one platform.

---

## 3. Product Goals

The primary goals are:

1. Provide a centralized marketplace for discovering activities and experiences in Palestine.
2. Make activity information easy to explore and compare.
3. Enable customers to make and track reservations.
4. Support both instant confirmation and provider-approved booking requests.
5. Help businesses and organizers manage activities, schedules, capacity, and bookings.
6. Give platform administrators tools to oversee marketplace operations.
7. Build a scalable foundation that can support additional activity categories and services.

### 3.1 Non-Goals

Fusha is not intended to be:

- A Learning Management System (LMS).
- A Student Management System.
- A School Management System.
- A Course Management Platform.
- A Training Center Management System.

Workshops and educational activities may exist as marketplace categories, but education management is not the platform's central purpose.

---

## 4. Target Users and Roles

### 4.1 Guest

A visitor who has not signed in.

Responsibilities:
- Browse publicly available activities.
- Explore categories.
- View activity details.
- Discover businesses and venues.

Booking and account-specific actions may require authentication.

### 4.2 Customer

A registered user who discovers and books activities.

Responsibilities:
- Manage their profile.
- Search and explore activities.
- View activity details and availability.
- Make booking requests or instant bookings.
- Track booking status.
- Access tickets when issued.
- Manage favorites and reviews, where supported.

### 4.3 Business Owner

A person responsible for managing a business or venue listed on Fusha.

Responsibilities:
- Manage business information.
- Create and manage activities.
- Configure schedules and capacity.
- Review and manage bookings.
- Manage staff access, where enabled.
- Monitor business performance.

### 4.4 Organizer

A person or organization responsible for organizing events and activities.

Responsibilities:
- Create and manage events.
- Configure event schedules and capacity.
- Manage booking requests.
- Track reservations and attendance.

### 4.5 Staff

A team member who performs assigned operational tasks.

Responsibilities and permissions depend on the access granted by the associated business or organizer.

### 4.6 Admin

A platform administrator responsible for day-to-day marketplace operations.

Responsibilities:
- Manage customers and providers.
- Review businesses and organizers.
- Moderate activities and content.
- Monitor bookings.
- Manage categories and platform information.
- Handle operational issues and reports.

### 4.7 Super Admin

A high-privilege platform role.

Responsibilities:
- Manage platform-wide configuration.
- Manage administrator access.
- Control high-level permissions.
- Oversee critical system operations.

**Important:** These roles describe product responsibilities. The exact permission matrix and authorization rules will be defined separately.

---

## 5. Activity Categories

Fusha supports different types of local activities and experiences.

Initial categories include:

| Category | Examples |
|---|---|
| Events | Concerts, festivals, exhibitions, cultural events |
| Experiences | Trips, adventures, tours, recreational experiences |
| Family | Family activities, children's activities, entertainment spaces |
| Restaurants | Restaurants and dining experiences |
| Sports | Sports facilities, courts, and recreational sports |
| Workshops | Art, cooking, crafts, and interactive workshops |
| Venues | Event halls, recreational spaces, and reservable venues |

Categories are intended to be manageable through platform administration rather than permanently hardcoded into the applications.

The list is an initial product scope and may evolve.

---

## 6. Platform Components

### 6.1 Customer Mobile App

**Technology:** Flutter

The mobile application is the primary customer-facing experience.

Main areas:

- Home
- Explore
- Search
- Categories
- Activity Details
- Booking
- My Bookings
- Tickets
- Favorites
- Profile
- Notifications

### 6.2 Management Dashboard

**Technology:** Flutter Web

The management dashboard provides role-based interfaces for businesses, organizers, and their staff.

Main areas:

- Authentication
- Overview
- Businesses
- Organizers
- Activities
- Schedules
- Bookings
- Customers
- Staff
- Reports
- Settings

The available sections and actions depend on the authenticated user's role and permissions.

### 6.3 Platform Administration

Platform administration provides centralized tools for managing the marketplace.

Main areas:

- User management
- Business and organizer management
- Provider onboarding and review
- Activity moderation
- Category management
- Booking monitoring
- Reports
- Complaints and operational management
- Roles and permissions
- Platform settings

The initial technical structure places the customer application and management dashboard in separate apps. Whether platform administration is a separate dashboard or a privileged area inside the management dashboard remains an architectural decision.

---

## 7. Core Customer Journey

The primary customer journey is:

1. Customer opens Fusha.
2. Customer explores available activities.
3. Customer selects an activity.
4. Customer reviews its details, price, location, schedule, and availability.
5. Customer selects a suitable date and available option.
6. Customer submits a booking.
7. The platform processes the booking according to its booking type.
8. Customer receives the resulting booking status.
9. A ticket may be issued when the booking is confirmed.
10. Customer attends the activity.

---

## 8. Booking System

Booking is one of Fusha's core product capabilities.

### 8.1 Instant Booking

The booking is confirmed immediately when the required conditions are satisfied.

Expected behavior:
- Customer selects an available option.
- Customer submits the booking.
- The system validates availability and booking requirements.
- The system confirms the booking if successful.
- The customer receives confirmation.

### 8.2 Request Booking

The customer submits a reservation request that requires provider approval.

Expected behavior:
- Customer selects an available option.
- Customer submits a booking request.
- The request is recorded as awaiting approval.
- The provider reviews the request.
- The provider approves or rejects it.
- The customer is informed of the decision.

### 8.3 Booking Lifecycle

The initial booking lifecycle should support the following conceptual states:

- Pending Approval
- Confirmed
- Rejected
- Cancelled
- Completed

Additional states, such as Expired or No-Show, may be introduced if required by the final business rules.

The exact state transitions, cancellation rules, and permissions will be specified in the booking and data-model documentation.

### 8.4 Availability and Capacity

The booking system must consider:
- Activity schedules.
- Available time slots.
- Capacity limits.
- Existing reservations.
- Booking restrictions.
- Provider-specific booking rules.

The system must prevent overbooking when multiple customers attempt to reserve the same remaining capacity.

---

## 9. Payment Strategy

### 9.1 Initial Release

The initial release uses:

**Cash on Arrival / Payment at Business**

Customers pay at the business or activity location rather than through an integrated online payment gateway.

### 9.2 Future Consideration

Online payments may be evaluated in a later phase.

The architecture should avoid unnecessarily coupling booking creation and confirmation to a single payment provider.

Payment statuses and financial workflows require separate business-rule decisions before implementation.

---

## 10. Functional Requirements

### 10.1 Discovery

The platform should allow customers and guests to:
- Browse available activities.
- Explore activity categories.
- View activity details.
- Search for activities.
- Discover activities by location.
- Filter and sort results when supported.

### 10.2 Activity Management

Authorized providers should be able to:
- Create activities.
- Update activity information.
- Manage descriptions and media.
- Set prices and relevant booking information.
- Configure activity schedules and capacity.
- Submit activities for review when required.
- Manage activity availability and publication status.

### 10.3 Booking Management

The platform should:
- Support instant bookings.
- Support booking requests requiring approval.
- Validate available capacity.
- Track booking status.
- Allow authorized providers to review requests.
- Notify customers about booking decisions.
- Provide customers with access to their booking history.

### 10.4 Ticket Management

The platform is intended to support digital tickets and QR codes.

The final ticket issuance rules, validation workflow, and scanning permissions must be defined before implementation.

### 10.5 Business and Organizer Management

Authorized users should be able to:
- Manage provider profiles.
- Manage associated activities.
- Manage schedules and reservations.
- Manage staff access where enabled.
- View relevant operational information.

### 10.6 Administration

Platform administrators should be able to:
- Manage marketplace users.
- Review provider applications.
- Moderate activities.
- Manage categories.
- Monitor bookings.
- Handle platform reports and operational issues.

### 10.7 Provider & Activity Approval Policy

Fusha uses a two-level administrative approval process to maintain marketplace trust and content quality.

#### Provider Approval

Every Business and Independent Organizer must receive administrative approval before accessing provider publishing capabilities.

Provider onboarding workflow:

1. Provider creates an account.
2. Provider submits an onboarding application.
3. Provider provides the required information and supporting documents.
4. Admin reviews the application.
5. Admin approves or rejects the application.
6. Approved providers gain access to the relevant management capabilities.

Provider statuses:

- Draft
- Pending Review
- Approved
- Rejected
- Suspended

A rejected provider may be allowed to submit an updated application according to platform policy.

Suspended providers cannot publish activities or perform restricted provider operations.

#### Activity Approval

Every activity must be reviewed and approved by an Admin before becoming publicly visible and bookable.

Activity submission workflow:

1. An approved provider creates an activity draft.
2. The provider submits the activity for review.
3. Admin reviews the submitted activity.
4. Admin approves, rejects, or requests changes.
5. An approved activity can be published through an authorized publishing operation.

Activity statuses:

- Draft
- Pending Review
- Approved
- Published
- Rejected
- Changes Requested
- Suspended
- Archived

Provider approval does not automatically approve its activities.

Activity approval does not bypass publishing permissions or server-side validation.

#### Activity Updates and Revisions

Changes to an existing published activity must follow the platform's content-review policy.

Minor changes may be applied without a new approval when permitted by platform policy.

Material changes, including changes to the activity location, category, core identity, safety information, or essential conditions, require administrative review.

When a material revision is submitted, the previously published version should remain available to customers until the revision is approved, unless the activity is suspended for safety, compliance, or other operational reasons.

The platform must preserve the distinction between the currently published version and a pending revision.

Changes affecting existing bookings must follow explicit booking and customer-notification rules.

#### Publishing Authorization

Publishing permissions must be enforced on the backend.

The publishing operation must verify:

1. The authenticated user's identity.
2. The provider's approval and active status.
3. The user's publishing permissions.
4. The activity's approval status.
5. Required activity data and publishing conditions.

Clients must not be allowed to publish activities by directly modifying their status.

All approval, rejection, suspension, and publishing operations must be auditable.

#### Provider Publishing Permissions

- Pending or rejected providers cannot publish activities.
- Approved providers may create drafts and submit activities for review.
- Approved providers cannot independently bypass activity approval.
- Admin users may review and manage provider and activity approvals according to their permissions.

#### Backend Enforcement

All sensitive approval and publishing transitions must be enforced server-side through trusted backend operations.

Firestore Security Rules must prevent unauthorized direct status changes and protect provider, activity, and booking data.

### 10.7 Additional Customer Features

The product scope includes:
- Favorites.
- Reviews and ratings.
- Notifications.
- Customer profile management.

Their detailed rules and release priorities will be refined during feature planning.

---

## 11. MVP Scope

The first release should focus on delivering a reliable end-to-end discovery and booking experience.

### Core MVP Capabilities

**Customer:**
- Authentication and profile.
- Home and activity discovery.
- Categories.
- Search and activity details.
- Schedule and availability display.
- Instant booking.
- Request booking.
- Booking history and status tracking.

**Business / Organizer:**
- Authentication and role-based access.
- Provider and activity management.
- Schedule and capacity management.
- Booking review and management.

**Platform Administration:**
- User and provider management.
- Activity and category moderation.
- Booking oversight.

**Booking and Payment:**
- Capacity validation.
- Instant confirmation.
- Approval-based confirmation.
- Payment at the business.

### Scope Requiring Prioritization

The following capabilities are part of the broader product vision, but their exact MVP inclusion must be confirmed:

- QR ticket generation and scanning.
- Reviews and ratings.
- Favorites.
- Push notifications.
- Advanced reports and analytics.
- Staff management.
- Online payments.
- Complaints and dispute management.

---

## 12. Non-Functional Requirements

### 12.1 Architecture and Maintainability

- Use a modular and maintainable architecture.
- Keep business logic separate from presentation and infrastructure.
- Avoid unnecessary dependencies between shared packages.
- Reuse genuinely shared domain concepts across applications.
- Keep app-specific models inside their respective features.

### 12.2 Performance

- Provide responsive discovery and search experiences.
- Avoid unnecessary network requests.
- Support efficient loading of activity images and lists.
- Handle larger activity catalogs without degrading the user experience.

### 12.3 Reliability

- Prevent duplicate and conflicting bookings.
- Protect booking capacity from concurrent reservation attempts.
- Maintain consistent booking status transitions.
- Handle network failures without creating misleading confirmation states.

### 12.4 Security

- Enforce authentication and authorization.
- Apply role-based access control.
- Protect customer and provider data.
- Validate sensitive booking operations on the backend.
- Never rely exclusively on client-side permission checks.

### 12.5 Localization and Accessibility

The applications should be designed with localization, accessibility, and appropriate layout direction in mind. Supported languages and detailed accessibility requirements will be confirmed during product and design planning.

---

## 13. Success Metrics

The platform should measure:

**Discovery**
- Number of active activities.
- Activity detail views.
- Search-to-detail conversion.

**Booking**
- Number of booking attempts.
- Booking confirmation rate.
- Pending request approval rate.
- Booking cancellation rate.
- Booking completion rate.

**Provider Adoption**
- Number of registered businesses and organizers.
- Number of active providers.
- Number of published activities.

**Customer Engagement**
- Active customers.
- Repeat booking rate.
- Customer retention.

Specific targets should be established after the initial release and baseline data collection.

---

## 14. Assumptions and Open Decisions

The following decisions require further product definition before they become implementation rules:

1. Which customer authentication methods will be supported?
2. Will provider onboarding require manual approval?
3. Can one business have multiple branches or locations?
4. Can an activity belong to more than one category?
5. How are activity prices represented: fixed price, per person, per group, or configurable pricing?
6. Can customers book for multiple participants?
7. What are the cancellation and refund policies?
8. Can providers reject requests after initially accepting them?
9. How long can a booking request remain pending?
10. When exactly is a QR ticket generated?
11. Who can scan and validate tickets?
12. What are the rules for customer reviews?
13. Which languages and currencies are supported at launch?
14. Will Admin and Super Admin use the same web application?
15. What reports and analytics are essential for the MVP?

These decisions should be documented before implementing dependent business logic.

---

## 15. Product Definition Summary

**Fusha is a Palestinian Experiences & Activities Discovery and Booking Platform.**

It connects customers with businesses, venues, organizers, and activity providers, enabling them to discover local experiences, explore available options, and make reservations.

The platform provides:
- A customer-facing Flutter mobile application.
- A role-based Flutter web management dashboard.
- Centralized marketplace administration.
- Instant and approval-based booking workflows.
- Payment at the business in the initial release.

Fusha is a multi-vendor marketplace, not an education management platform.

**Discover. Book. Experience.**

**كل يوم إله فُسحة.**