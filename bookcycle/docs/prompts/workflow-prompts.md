# Bookcycle – Workflow Prompts für KI-Assistenten

**Zweck**: Strukturierte Prompts für häufige Entwicklungs-Workflows  
**Format**: Template + Beispiel  
**Zielgruppe**: Entwickler + KI-Assistenten

---

## 1️⃣ Brainstorming → GitHub Issue

### Prompt Template

```markdown
# Brainstorming Session

## Initiale Idee
[Unstrukturierte User-Anforderung oder Problem]

## Kontext
- Feature Category: [Backend / Web / Admin]
- Requester: [Developer Name / Stakeholder]
- Business Value: [Why do we need this?]
- Timeline: [ASAP / Next Sprint / Future]

## KI-Auftrag
Du bist ein Product Owner. Helfe mir, diese Idee in eine klare GitHub Issue
zu verwandeln. Nutze folgende Struktur:

1. **Titel** (5-10 Worte, Action-orientiert)
2. **Beschreibung** (2-3 Sätze, Business Value)
3. **Akzeptanzkriterien** (5-8 konkrete, testbare Kriterien)
4. **Bemerkungen** (Abhängigkeiten, Tech Stack, Edge Cases)
5. **Checkliste** (Implementation-Punkte)
```

### Beispiel: Issue-Generierung

```markdown
## Initiale Idee
"Benutzer möchten Bücher nach Status filtern"

## Kontext
- Feature Category: Backend + Web + Admin
- Requester: Product Owner
- Business Value: Bessere Discoverability, UX-Verbesserung
- Timeline: Next Sprint

## KI-Auftrag
[Wie oben]

---

## OUTPUT: GitHub Issue (READY TO COPY)

### Title
Filter books by status (available/borrowed/lost)

### Description
Enable users and admins to filter the book list by status.
This improves discoverability and helps users quickly find available books
to borrow while allowing admins to manage inventory by status.

### Acceptance Criteria
- [ ] GET /api/books?status=AVAILABLE filters to available books only
- [ ] GET /api/books?status=BORROWED shows only borrowed books
- [ ] Web UI shows filter dropdown on /books page
- [ ] Admin UI has status filter chips on book list
- [ ] Invalid status values return 400 with error message
- [ ] Default view shows all statuses (no filter applied)
- [ ] Filter persists on page refresh (URL params)

### Related Issues
- [Link existing related issues]

### Technical Notes
- Use existing BookStatus enum
- Implement @RequestParam("status") in BookController
- Update BookRepository.findBy...() queries
- Add Riverpod StateProvider for Flutter filter state
```

---

## 2️⃣ Anforderung → User Story

### Prompt Template

```markdown
# Requirements to User Story Conversion

## Raw Requirement
[Business Anforderung oder Anfrage]

## Context Information
- Epic: [Which Epic does this belong to?]
- Personas: [Who will use this? (User/Admin/System)]
- Current System State: [What exists now?]
- Constraints: [Time, Tech, Resources]

## KI-Auftrag
Du bist ein agiler Scrum Master. Wandle diese Anforderung in User Stories
nach dem INVEST-Kriterium um:

- Independent: Kann isoliert implementiert werden
- Negotiable: Details können mit Team diskutiert werden
- Valuable: Liefert Business Value
- Estimable: Team kann Aufwand schätzen
- Small: Passt in einen Sprint
- Testable: Akzeptanzkriterien klar definiert

Struktur pro Story:
1. **As a [Persona] I want to [Action] So that [Value]**
2. **Acceptance Criteria** (5-7 konkrete Kriterien)
3. **Definition of Done** (Code-Review, Tests, Docs)
4. **Estimation** (Fibonacci: 1, 2, 3, 5, 8, 13)
5. **Dependencies** (Welche anderen Stories/Features braucht es?)
6. **Risks** (Was könnte schiefgehen?)
```

### Beispiel: Story-Zerlegung

```markdown
## Raw Requirement
"Admins müssen Bücher verwalten können (hinzufügen, bearbeiten, löschen)"

## Context Information
- Epic: Book Inventory Management
- Personas: Admin
- Current System State: Read-only book view exists
- Constraints: Muss in 2 Sprints fertig sein, nur CRUD vorerst

---

## OUTPUT: 3 User Stories

### Story 1: Add New Book to Inventory
**As an** admin
**I want to** add new books to the inventory
**So that** users can discover and borrow them

#### Acceptance Criteria
- [ ] POST /api/books accepts CreateBookDTO
- [ ] Validates: ISBN (10 or 13 digits), title (1-255 chars), pages (>0)
- [ ] ISBN must be unique (409 Conflict if duplicate)
- [ ] Response: 201 Created with BookDTO
- [ ] Web form: title, isbn, description, pages inputs
- [ ] Admin app has "Add Book" button → CreateBookScreen
- [ ] Form validation shows errors before submit
- [ ] Success message after creation

#### Definition of Done
- [ ] Code in feature branch
- [ ] 85%+ test coverage (unit + integration)
- [ ] Code review approved
- [ ] Deployment checklist completed

#### Estimation: 5 Story Points

#### Dependencies
- User authentication (exists)
- Book entity & repository (Story 1 of previous epic)

---

### Story 2: Edit Book Details
**As an** admin
**I want to** edit book information
**So that** I can correct errors or update details

#### Acceptance Criteria
- [ ] PUT /api/books/{id} updates book
- [ ] Can update: title, description, pages
- [ ] Cannot change: ISBN (immutable)
- [ ] Validation same as create
- [ ] Response: 200 OK with updated BookDTO
- [ ] Web & Admin UI: Edit form pre-populated with current values

#### Estimation: 3 Story Points

---

### Story 3: Delete Book from Inventory
**As an** admin
**I want to** remove books no longer in circulation
**So that** the inventory reflects reality

#### Acceptance Criteria
- [ ] DELETE /api/books/{id} soft-deletes (status=RETIRED)
- [ ] Cannot delete if currently borrowed
- [ ] Response: 204 No Content on success
- [ ] 409 Conflict if book is borrowed

#### Estimation: 2 Story Points
```

---

## 3️⃣ Code Diff → Pull Request Beschreibung

### Prompt Template

```markdown
# Code Diff to PR Description Generator

## Git Diff Input
[Paste your: git diff main..feature-branch]

## Story Context
- User Story: [Link or Title]
- Feature Category: [Backend / Web / Admin]
- Files Changed: [List of key files]

## KI-Auftrag
Du bist ein Technical Writer. Erstelle eine PR-Beschreibung aus diesem Diff:

1. **Summary** (1-2 Sätze, was ändert sich)
2. **Changes** (Bullet-Punkte pro Komponente)
3. **Testing** (Wie wurde getestet?)
4. **Checklist** (Architektur-, Quality-Checks)
5. **Screenshots/Videos** (Falls UI-Changes)
6. **Reviewers** (Wer sollte reviewed?)

Nutze:
- Technische Präzision
- Keine Grammatik-Fehler
- Linking zu Issues (#123)
- Breaking-Change-Warnings
```

### Beispiel: PR-Beschreibung

```markdown
## Summary
Implemented BookService.borrowBook() with business validations and created
REST endpoint POST /api/borrows for initiating book borrowing transactions.

## Changes

### Backend Service Layer
- Added `BorrowRecord` entity with JPA mappings (borrowedAt, dueDate, status)
- Implemented `IBookService.borrowBook(bookId, userId)` with:
  - User verification check
  - Max 5 concurrent borrows per user validation
  - Book availability check
  - Duplicate borrow prevention
  - Transactional boundary (REQUIRED, cascading)
- Custom exceptions: `BorrowLimitExceededException`, `BookNotAvailableException`

### REST Controller
- POST /api/borrows endpoint with OpenAPI documentation
- Input validation via @Valid
- Error handling: 400/409 with meaningful messages

### Tests
- Unit tests: BookServiceTest (6 test methods, all branches covered)
- Integration tests: BookRepositoryTest (H2 in-memory DB)
- Controller tests: BorrowControllerTest (MockMvc)
- Coverage: 87% on service layer, 92% on repository

## Testing Performed
```bash
# Local unit tests
mvn test -Dtest=BookServiceTest

# Integration tests with H2
mvn verify

# Manual testing
curl -X POST http://localhost:8080/api/borrows \
  -H "Content-Type: application/json" \
  -d '{"bookId": 1, "userId": 1}'
```

## Architecture Review
- [ ] No business logic in controller
- [ ] DTOs used for REST input/output
- [ ] Service layer handles @Transactional boundary
- [ ] Custom exceptions in domain layer
- [ ] Tests cover happy path + error cases
- [ ] Logging added (INFO, WARN, ERROR levels)

## Related Issues
Closes #BOOK-45 (Implement Borrow Feature)
Related to #BOOK-46 (Admin Borrow Management)

## Reviewers
@backend-lead @qa-engineer

---

## Screenshots / Videos
[If applicable: Add UI screenshots or test recordings]

## Breaking Changes
None. Backward compatible with existing API.

## Deployment Notes
- No DB migrations needed (schema auto-update: validate)
- No config changes required
- Can be deployed immediately after merge
```

---

## 4️⃣ Fehler Analysis → Bug Report

### Prompt Template

```markdown
# Bug Analysis & Report Generation

## Error Details
[Stack trace, Error message, or unexpected behavior]

## Reproduction Steps
1. [Step 1]
2. [Step 2]
3. [Expected: ...]
4. [Actual: ...]

## Environment
- OS: [Windows/Mac/Linux]
- Java/Flutter Version: [Version]
- Browser: [Chrome/Firefox]
- Bookcycle Version/Branch: [main/develop]

## KI-Auftrag
Du bist ein QA Engineer. Erstelle einen präzisen Bug Report:

1. **Title** (Clear, reproduzierbar)
2. **Severity** (Critical/High/Medium/Low)
3. **Affected Component** (Backend/Web/Admin)
4. **Root Cause Analysis** (Was ist wahrscheinlich falsch?)
5. **Suggested Fix** (Code Example)
6. **Test Case** (Wie man es reproduziert)
```

### Beispiel: Bug Report

```markdown
## Title
BookService.borrowBook() throws NPE when user email is null

## Severity
High (User-facing error, blocks borrowing feature)

## Affected Component
Backend (BookService)

## Description
When a verified user attempts to borrow a book, the service throws
a NullPointerException instead of a validation error.

## Reproduction Steps
1. Create user with null email (edge case, but possible)
2. Mark user as verified
3. POST /api/borrows with that user's ID
4. Expected: 400 with "Invalid user email"
5. Actual: 500 NullPointerException

## Stack Trace
```
java.lang.NullPointerException: Cannot invoke method on null object
  at com.bookcycle.application.services.BookService.validateBorrow(BookService.java:87)
  at com.bookcycle.application.services.BookService.borrowBook(BookService.java:45)
```

## Root Cause Analysis
In BookService.validateBorrow(), line 87:
```java
if (user.getEmail().isEmpty()) {  // NPE when email is null
```
Should check for null first.

## Suggested Fix
```java
if (user.getEmail() == null || user.getEmail().isEmpty()) {
    throw new InvalidUserException("User email is required");
}
```

## Test Case
```java
@Test
void shouldThrowWhenUserEmailNull() {
    User userNoEmail = User.builder()
        .id(1L)
        .email(null)  // Edge case
        .verified(true)
        .build();
    
    Book book = Book.builder()
        .id(1L)
        .status(BookStatus.AVAILABLE)
        .build();
    
    assertThrows(InvalidUserException.class,
        () -> service.borrowBook(1L, userNoEmail.getId()));
}
```

## Related Issues
[If this is regression]: Caused by #PR-89 (User email validation)

## Assigned To
@backend-lead
```

---

## 5️⃣ Lessons Learned / Post-Mortem

### Prompt Template

```markdown
# Post-Implementation Retrospective

## Feature Completed
[User Story Title & Link]

## Duration
- Planned: [X Story Points / Y days]
- Actual: [A days, reason for deviation]

## KI-Auftrag
Du bist ein Agile Coach. Helfe dem Team, Lessons Learned zu dokumentieren:

1. **What Went Well** (3-5 positive Punkte)
2. **What Could Be Improved** (3-5 Verbesserungspotentiale)
3. **Action Items** (Konkrete Maßnahmen für nächste Sprints)
4. **Metrics Impact** (Velocity, Quality, Performance)
5. **Knowledge Transfer** (Was sollte andere Devs wissen?)

Struktur:
- Spezifisch & messbar
- Konstruktiv, nicht kritisch
- Fokus auf System, nicht Personen
- Umsetzbare Aktionen
```

### Beispiel: Post-Mortem

```markdown
## Feature Completed
Story #BOOK-45: Implement Book Borrowing Feature

## Duration
- Planned: 8 Story Points / 3 days
- Actual: 3.5 days (Scope was well-estimated)

## What Went Well

1. **Clear Task Breakdown**
   - Project Manager provided detailed task list for Backend/Web/Admin
   - Each developer knew exactly what to implement
   - Parallel work was possible with minimal blocking

2. **Comprehensive Testing Strategy**
   - Tests written before implementation (TDD mindset)
   - Unit tests + Integration tests caught edge cases early
   - MockMvc tests validated REST contract

3. **Effective KI-Agent Usage**
   - Backend Agent generated 90% correct code
   - Minimal manual refactoring needed
   - Tests generated by Agent passed on first run

4. **Code Review Efficiency**
   - Architecture checklist ensured quality gate
   - No back-and-forth on design decisions
   - Single-approval merge (confidence in process)

## What Could Be Improved

1. **API Documentation Timing**
   - OpenAPI spec written AFTER code implementation
   - Should be written BEFORE (contract-first approach)
   - Time loss: ~2 hours on annotation cleanup

2. **Integration Test Data Setup**
   - TestEntityManager setup was verbose
   - No fixtures or builders initially available
   - Solution: Created Builder pattern for future tests

3. **Flutter State Management Learning Curve**
   - Admin dev needed extra time to understand Riverpod
   - Concept of FutureProvider vs StateNotifier not initially clear
   - Solution: Created example pattern, documented in copilot-instructions

4. **Cross-Team Communication**
   - Backend finished early, Web/Admin still working
   - Idle time waiting for PR merge
   - Solution: Use feature flags for async development

## Action Items

| Item | Owner | Sprint | Priority |
|------|-------|--------|----------|
| Write API contracts (OpenAPI) BEFORE implementation | Backend Lead | Sprint 5 | High |
| Create test fixture builders for common entities | QA Lead | Sprint 5 | High |
| Add Riverpod best practices guide to docs | Admin Lead | Sprint 4 | Medium |
| Enable GitHub feature flags for parallel development | DevOps | Sprint 5 | Medium |
| Refactor DTOs to single-responsibility objects | Backend Lead | Sprint 6 | Low |

## Metrics Impact

| Metric | Before | After | Trend |
|--------|--------|-------|-------|
| Avg Story Completion | 3.5 days | 3.2 days | ↓ Better |
| Test Coverage | 78% | 87% | ↑ Better |
| Code Review Time | 6h | 3h | ↓ Better |
| Production Issues | 2 per sprint | 0 | ↑ Better |
| Developer Satisfaction | 7/10 | 9/10 | ↑ Better |

## Knowledge Transfer

**For Next Similar Feature:**

1. **API-First Design**: Write OpenAPI spec first
   - Generate stubs/mocks from spec
   - Parallel development for backend/frontend

2. **Fixture Strategy**: Use Builder Pattern
   ```java
   // Reusable for all tests
   Book.builder().withDefaults().withCustomField(value).build();
   ```

3. **Riverpod Patterns**: Document async data flow
   - FutureProvider für Datenladung
   - StateNotifier für Benutzeraktionen
   - Keep separation strict

4. **CI/CD Gate Optimization**: Run parallel steps
   - Tests können parallele laufen
   - Sparen ~30% CI time

---

## Team Feedback Summary

> "Clear requirements + good KI Agents = fast implementation." – Backend Dev

> "Testing first saved us hours in debugging." – QA

> "Architectural checklist prevented regressions." – Tech Lead
```

---

## 6️⃣ Performance Problem → Optimization Task

### Prompt Template

```markdown
# Performance Investigation & Optimization

## Observed Problem
[Slow endpoint, high memory usage, database query timeout, etc.]

## Metrics
- Baseline: [Original time/memory/queries]
- Threshold: [Target time/memory/queries]
- Current: [Current problematic state]

## KI-Auftrag
Du bist ein Performance Engineer. Identifiziere Bottleneck und schlage
Optimierungen vor:

1. **Root Cause Analysis** (Profiling, Metrics, Logs)
2. **Optimization Options** (Pro/Con für jede)
3. **Recommended Solution** (Mit Begründung)
4. **Implementation Plan** (Code changes + Tests)
5. **Validation** (Wie man improvement misst)
```

---

## 7️⃣ Component-Testing mit API-Mocks

### Prompt Template

```markdown
# Mock-Integration für Flutter Components

## Component unter Test
[Component Name, z.B. BookCard, UserProfile]

## API Dependencies
[Welche API-Endpoints braucht die Component?]
- GET /api/books/{id}
- POST /api/books/{id}/favorite
- etc.

## Szenarien zu testen

### Happy Path (Daten erfolgreich geladen)
```dart
when(mockApi.getBook(1)).thenAnswer((_) async => Book(
  id: 1,
  title: 'Clean Code',
  author: 'Robert C. Martin',
  pages: 464,
));
```

### Loading State (Während API-Fetch)
- [ ] Skeleton/Placeholder wird gezeigt
- [ ] No buttons clickable
- [ ] Loading indicator sichtbar

### Error State (API schlägt fehl)
```dart
when(mockApi.getBook(1)).thenThrow(Exception('Network Error'));
```
- [ ] Error message angezeigt
- [ ] Retry button vorhanden
- [ ] Kein null pointer

## KI-Auftrag
Generiere komplette Widget-Test-Suite mit Mockito:
1. Data state (happy path)
2. Loading state
3. Error state
4. User interactions (taps, swipes, etc.)
5. Accessibility checks (Semantics, focus)

Output: Dart test code mit mindestens 80% coverage.
```

---

## 8️⃣ UI-Component Accessibility & Design-Tokens

### Prompt Template

```markdown
# Component-Accessibility Audit

## Component Details
[Component Name, Beschreibung]

## Design-Token Anforderungen
- Colors: [Verwende `DesignTokens.primary`, `DesignTokens.error`, etc.]
- Spacing: [xs, sm, md, lg, xl aus Design Tokens]
- Typography: [headline1, body, caption aus Tokens]
- Border Radius: [borderRadius, borderRadiusLarge]

## WCAG 2.1 AA Checklist
- [ ] Color Contrast: 4.5:1 für Text (normal weight)
- [ ] Touch Target: Min 48x48 dp
- [ ] Focus Order: Logische Reihenfolge
- [ ] Keyboard Navigation: Tab durch alle Inputs
- [ ] Screen Reader: Semantics + labels für alle Elemente
- [ ] Responsive: Portrait + Landscape
- [ ] Zoom: 200% readable ohne overflow

## KI-Auftrag
Generiere Flutter Widget mit:
1. **Design-Token compliance** (aus shared-resources)
2. **WCAG 2.1 AA compliance** (Contrast, Touch, Focus)
3. **Responsive layout** (LayoutBuilder für verschiedene Breiten)
4. **Accessibility semantics** (Semantics widget, labels)
5. **Test suite** (Widget tests für alle States)

Struktur:
```dart
class MyComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive: wide vs narrow
        return Semantics(
          label: 'Descriptive label',
          child: Container(
            padding: EdgeInsets.all(DesignTokens.md),
            decoration: BoxDecoration(
              color: DesignTokens.primary,
              borderRadius: BorderRadius.circular(DesignTokens.borderRadius),
            ),
            child: ...
          ),
        );
      },
    );
  }
}
```
```

---

## 📚 Referenz-Struktur

Alle Prompts folgen:
```
1. INPUT: Context + Data
2. KI-AUFTRAG: Klare Anweisung + Struktur-Template
3. OUTPUT: Konkrete Artefakte (GitHub Issues, PRs, etc.)
4. VALIDATION: Wie ist die Qualität messbar?
```

---

**Nutze diese Prompts in Verbindung mit den spezialisierten Agents!**
