# Bookcycle SYP Project – Must-have User Stories
Papic, Schüller, Erdkönig, Iszovits, Luschenz, Wieser

## 1) Refined MUST-HAVE User Stories

### US-001 – Search Listings  
**As a visitor or logged-in user, I want to search for book listings by title, author, or ISBN and see availability, so that I can quickly find matching offers.**

**Conversation points**
- Free-text search; fuzzy match on title & author; ISBN exact match
- Default sort: relevance; optional: date, price
- Filters (MVP): Genre, Condition ≥ Good, Price range, Location (city/ZIP), grade/year group, field of study
- Result card shows: title/author, condition, price, availability, location, thumbnail
- Pagination or infinite scroll

**Acceptance Criteria (Gherkin)**
- Given I enter a query, when I search, then matching results are shown including condition, price, availability.
- Given no results, when I search, then I see an empty state with a link to clear filters.
- Given many results, when I sort by Price (low → high), then results reorder accordingly.
- Given I apply filters, when I apply, then only matching listings are shown.

**Story Points:** 5  
**Priority:** Must-Have  
**Epic:** Search

---

### US-002 – Create & Publish Listing  
**As a seller, I want to create and publish a book listing with photos, condition and price, so that others can discover and buy my book.**

**Conversation points**
- Required fields: ISBN or title, author, condition, price, location, at least one photo
- State model: Draft → Published → (Reserved) → Sold/Closed
- One listing = one physical copy (BookItem)

**Acceptance Criteria (Gherkin)**
- Given I am logged in, when I complete required fields and publish, the listing becomes *Published* and searchable.
- Given a listing is Published, when I close it, then status becomes *Closed* and disappears from search.
- Given I enter an ISBN, then metadata is autofilled.
- Given I upload photos, first upload becomes thumbnail.

**Story Points:** 5  
**Priority:** Must-Have  
**Epic:** Sell/Offer

---

### US-003 – Checkout & Handover  
**As a buyer, I want to commit to a listing via checkout and create a handover protocol, so that the transaction is transparent and traceable.**

**Conversation Points**
- No online payment; in-person handover (cash/free)
- Purchase created at checkout; listing becomes Sold after both confirm
- HandoverProtocol stores meeting time/place/condition; both confirm

**Acceptance Criteria (Gherkin)**
- Buy now → Purchase Pending + seller notified.
- Meeting time/place recorded → visible to both.
- Both confirm handover → Protocol stored; listing Sold; purchase HandedOver.
- Buyer cancels before handover → purchase Cancelled; listing returns to Published.

**Story Points:** 8  
**Priority:** Must-Have  
**Epic:** Checkout

---

### US-004 – Chat  
**As a user, I want a simple chat to ask questions about a listing.**

**Conversation Points**
- One conversation per buyer↔seller per listing
- Real-time indicators; push notifications
- Attachments out of scope

**Acceptance Criteria**
- Chat opens from listing, real-time messages
- Sending triggers push notification
- Messages view sorted by last message

**Story Points:** 5  
**Priority:** Must-Have  
**Epic:** Communication

---

### US-005 – User Management  
**As a user, I want to sign up, sign in and edit my profile.**

**Conversation Points**
- Email/password auth, reset via email
- Profile: display name, avatar, location
- Roles: Member, Admin, Moderator
- UI prototypes: shared-resources/docs/ui/mobile-registration.html, mobile-login.html, mobile-profile.html

**Acceptance Criteria**
- Registration signs in user
- Password reset email generated
- Profile edits visible publicly

**Story Points:** 3  
**Priority:** Must-Have  
**Epic:** User Management

---

### US-006 – Moderation Dashboard  
**As a moderator, I want to see active listings & flagged content.**

**Conversation Points**
- Users can report listings/messages
- Moderators can hide content; actions logged
- Filters: status, date, reporter, subject type
- UI prototypes: shared-resources/docs/ui/admin-login.html, admin-dashboard.html, admin-user-management.html

**Acceptance Criteria**
- Reports visible in queue
- Moderator hides listing → reporter notified
- Filter active listings by status

**Story Points:** 5  
**Priority:** Must-Have  
**Epic:** Admin/Moderation

---

### US-007 – Report Function  
**As a user, I want to report a listing or message.**

**Conversation Points**
- Report button on listings & chat
- Reasons: Spam, Inappropriate content, Fraud (+ optional comment)
- Confirmation dialog

**Acceptance Criteria**
- Listing report: choose reason & submit
- Chat message report: message ID + reason sent to moderators
- Confirmation message after success

**Story Points:** 3  
**Priority:** Must-Have  
**Epic:** Admin/Moderation

---

### US-008 – Password Reset  
**As a user, I want to reset my password.**

**Conversation Points**
- “Forgot password?” link
- Secure token via email; expires after 15 minutes
- UI prototype: shared-resources/docs/ui/mobile-password-reset.html

**Acceptance Criteria**
- Forgot password → enter email
- Valid email → receives reset link
- New password → login possible

**Story Points:** 3  
**Priority:** Must-Have  
**Epic:** User Management

---

## Working Time Examples
| Story Points | Time | Description |
|-------------|-------|-------------|
| 3 SP | 0.5–1 h | Small feature |
| 5 SP | 2–3 h | Medium feature |
| 8 SP | ~0.5 day | Complex flow |

# Tasks and technical notes for all must have user stories

---

## US-001 – Search Listings (Web User)
**As a visitor or logged-in user, I want to search for listings…**

### Tasks
1. Implement Spring Data JPA query for fuzzy title/author search and exact ISBN match.  
2. Build REST endpoint: `GET /api/listings/search`.  
3. Implement filter logic (genre, condition, price range, location).  
4. Add sorting options (relevance, date, price).  
5. Implement pagination with Spring's Pageable.  
6. Web UI: build Search Bar + Filter UI + Results Page.

### Technical Notes
- Fuzzy search using LIKE `%query%` is enough for H2.  
- Add DB indexes on title, author, ISBN, location for performance.  
- Only return listings with status = Published.  
- Use a dedicated service method:  
  `ListingService.search(query, filters, pagination)`.  

---

## US-002 – Create & Publish Listing (Web User)

### Tasks
1. Implement REST endpoint: `POST /api/listings` for creating a draft listing.  
2. Implement `Listing.publish()` domain method with validation rules.  
3. Add image upload (store Base64, or file-path in H2).  
4. Auto-fill title/author via a simple internal ISBN metadata service.  
5. Implement Spring Data entities for Listing, BookItem, Photo.  
6. Web UI: Form to create listing, upload photos, publish listing.

### Technical Notes
- Listing workflow: Draft → Published → Reserved → Sold/Closed  
- Validate mandatory fields during `Listing.publish()`.  
- Save image references (Base64 or local storage path).  
- Use Spring Boot validation annotations (`@NotNull`, etc).  

---

## US-003 – Checkout & Handover Protocol (Web User)

### Tasks
1. Implement `CheckoutService.checkout(listingId, buyerId)` in Spring Boot.  
2. Add `HandoverProtocol` JPA entity and DB table.  
3. Create endpoints for creating and updating a Purchase.  
4. Implement `Purchase.confirmHandover()` and `Purchase.cancel()`.  
5. Web UI: Purchase detail view + handover form.

### Technical Notes
- Once Purchase = Pending → Listing becomes Reserved.  
- After both confirm → Listing becomes Sold, Purchase → HandedOver.  
- Use Spring transactions (`@Transactional`) for state transitions.  
- Use relational tables, not JSON (H2 limitation).  

---

## US-004 – Chat / Messaging (Web User)

### Tasks
1. Create Conversation + Message JPA entities.  
2. Implement REST endpoints for sending messages (MVP instead of WebSockets).  
3. (Optional) Implement WebSocket endpoint for real-time chat.  
4. Create Spring Boot service for conversation management.  
5. Web UI: Chat UI with live updates (polling interval 2–3 seconds).

### Technical Notes
- Conversation identity = (buyerId, sellerId, listingId).  
- Messages stored with timestamps and senderId.  
- Ensure ordering by `sentAt ASC`.  
- Notifications: Create domain event → push to admin app if needed.

---

## US-005 – User Registration, Login, Profile Edit (Web User)

### Tasks
1. Implement Spring Security for authentication (email + password).  
2. Create `POST /api/auth/register` and `POST /api/auth/login`.  
3. Add password reset logic with expiring token in DB.  
4. Implement Profile update endpoint.  
5. Web UI: Login/Register/Profile pages.

### Technical Notes
- Use `BCryptPasswordEncoder`.  
- Reset tokens stored in H2 with expiration timestamp.  
- Validate email uniqueness.  
- Profile stored as separate entity.  

---

## US-006 – Moderation Dashboard (Flutter App — Admin)

### Tasks
1. Implement API: `GET /api/moderation/reports`, `POST /api/moderation/hideListing`, etc.  
2. Add JPA entity for Report.  
3. Add admin authentication (role = MODERATOR).  
4. Flutter app: List reports, show details, apply actions.  
5. Flutter UI: Filters for date, reporter, status, type.

### Technical Notes
- Soft-delete listings using `Listing.status = Closed` or hidden flag.  
- Moderator actions logged (AOP or service logging).  
- Flutter uses REST calls to Spring backend.  
- Configure CORS.

---

## US-007 – Report Listing/Message (Web User)

### Tasks
1. Create endpoint: `POST /api/report` with reason + target type.  
2. Add validation (target must exist).  
3. Link report to listing or message.  
4. Notify admins (domain event + push to Flutter app).  
5. Web UI: Add “Report” button in listing & message view.

### Technical Notes
- Store reason, optional comment, reporterId, timestamp.  
- Use enums: spam, inappropriate, fraud.  
- Report should appear instantly in admin app.  
- Avoid deletion → hide/flag.

---

## US-008 – Password Reset (Web User)

### Tasks
1. Endpoint: `POST /api/auth/reset-password-request`.  
2. Generate reset token + store (15 min expiration).  
3. Endpoint: `POST /api/auth/reset-password`.  
4. Implement email sending (stub/local).  
5. Web UI: reset-password form.

### Technical Notes
- Store token with: userId, token, expiresAt.  
- Use SecureRandom token.  
- Always return generic success response.  
- Invalidate old tokens after use.

---

# User Story Domain-Objekt Typ Code-Repräsentation Bounded Context



| User Story | Domain Object | Type | Code Representation | Bounded Context |
|------------|---------------|------|----------------------|------------------|
| US-001 | Listing | Aggregate Root | class Listing | Marketplace |
| US-001 | BookItem | Entity | class BookItem | Marketplace |
| US-001 | SearchCriteria | Value Object | record SearchCriteria(String query, Filters filters) | Marketplace |
| US-001 | ListingFilters | Value Object | record ListingFilters(...) | Marketplace |
| US-001 | ISBN | Value Object | record ISBN(String value) | Shared Kernel |
| US-001 | Money | Value Object | record Money(BigDecimal amount, Currency currency) | Shared Kernel |
| US-001 | Location | Value Object | record Location(String city, String zipCode) | Shared Kernel |
| US-001 | ListingSearchService | Domain Service | interface ListingSearchService | Marketplace |
| US-002 | Listing | Aggregate Root | class Listing | Marketplace |
| US-002 | BookItem | Entity | class BookItem | Marketplace |
| US-002 | Photo | Entity | class Photo | Marketplace |
| US-002 | ListingStatus | Enum | enum ListingStatus | Marketplace |
| US-002 | ISBN | Value Object | record ISBN(String value) | Shared Kernel |
| US-002 | Money | Value Object | record Money(...) | Shared Kernel |
| US-002 | Location | Value Object | record Location(...) | Shared Kernel |
| US-002 | IsbnMetadataService | Domain Service | interface IsbnMetadataService | Marketplace |
| US-003 | Purchase | Aggregate Root | class Purchase | Trading |
| US-003 | HandoverProtocol | Entity | class HandoverProtocol | Trading |
| US-003 | MeetingDetails | Value Object | record MeetingDetails(...) | Trading |
| US-003 | PurchaseStatus | Enum | enum PurchaseStatus | Trading |
| US-003 | Listing | Aggregate Root | class Listing | Marketplace |
| US-003 | CheckoutService | Domain Service | interface CheckoutService | Trading |
| US-004 | Conversation | Aggregate Root | class Conversation | Chat |
| US-004 | Message | Entity | class Message | Chat |
| US-004 | ConversationId | Value Object | record ConversationId(...) | Chat |
| US-004 | ChatService | Domain Service | interface ChatService | Chat |
| US-005 | UserAccount | Aggregate Root | class UserAccount | Identity and access management |
| US-005 | UserProfile | Entity | class UserProfile | Identity and access management |
| US-005 | Email | Value Object | record Email(String value) | Identity and access management |
| US-005 | PasswordHash | Value Object | record PasswordHash(String value) | Identity and access management |
| US-005 | UserRole | Enum | enum UserRole | Identity and access management |
| US-005 | AuthService | Domain Service | interface AuthService | Identity and access management |
| US-006 | Report | Aggregate Root | class Report | Moderation |
| US-006 | ReportStatus | Enum | enum ReportStatus | Moderation |
| US-006 | ModerationAction | Entity | class ModerationAction | Moderation |
| US-006 | Listing | Aggregate Root | class Listing | Marketplace |
| US-006 | Message | Entity | class Message | Chat |
| US-006 | Moderator | Entity | class Moderator | Identity & Access / Moderation |
| US-006 | ModerationService | Domain Service | interface ModerationService | Moderation |
| US-007 | Report | Aggregate Root | class Report | Moderation |
| US-007 | ReportTarget | Value Object | record ReportTarget(...) | Moderation |
| US-007 | ReportReason | Enum | enum ReportReason | Moderation |
| US-007 | Listing | Aggregate Root | class Listing | Marketplace |
| US-007 | Message | Entity | class Message | Chat |
| US-008 | UserAccount | Aggregate Root | class UserAccount | Identity & Access |
| US-008 | PasswordResetToken | Entity | class PasswordResetToken | Identity & Access |
| US-008 | Email | Value Object | record Email(String value) | Identity & Access |
| US-008 | PasswordPolicy | Domain Service | interface PasswordPolicy | Identity & Access |
| US-008 | AuthService | Domain Service | interface AuthService | Identity & Access |

---
