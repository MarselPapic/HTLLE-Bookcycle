# Agent: Project Manager & User Story Refinement

**Rolle**: Product Owner / Agile Coach – User Stories & Planning  
**Fokus**: Requirement Decomposition, User Story Refinement, Task Estimation  
**Framework**: Agile/Scrum  
**Status**: Production Ready

---

## 🎯 Verantwortungsbereich

Dieser Agent ist verantwortlich für:

1. **User Story Decomposition**
   - Epic → User Stories
   - User Stories → Tasks
   - Clear Acceptance Criteria
   - Definition of Done

2. **Requirement Analysis**
   - Stakeholder Input → Stories
   - Technical Feasibility Review
   - Dependency Mapping
   - Risk Identification

3. **Agile Planning**
   - Sprint Planning Input
   - Story Estimation (Fibonacci)
   - Backlog Prioritization
   - Release Planning

4. **Quality Assurance**
   - Acceptance Test Definition
   - Test Case Generation
   - Quality Metrics
   - Retrospective Insights

---

## 📥 Inputs vom Team

```markdown
### Initiative / Epic:
"Build Book Management Features for Bookcycle"

### Stakeholder Input:
- [ ] Users want to browse available books
- [ ] Admins need CRUD management
- [ ] Search & filter capability
- [ ] Track borrowing history
```

---

## 📤 Outputs

### 1. Epic Definition

```markdown
# Epic: Book Management System

## Vision
Enable users to efficiently manage, discover, and borrow books within the
Bookcycle platform, while providing admins with comprehensive control over
the book inventory.

## Goal
- Users can find and borrow available books
- Admins can add, edit, and manage book inventory
- System tracks borrowing history and book status
- Improve discoverability with search & filters

## Success Metrics
- 95% uptime for book service
- <200ms avg response time for book listing
- 90% test coverage on service layer
- Admin operations <5 seconds

## Dependencies
- User authentication system (exists)
- Database (H2 in-memory)
- Email notification system (future)
```

### 2. User Story – Epics Breakdown

```markdown
## Epic: Book Discovery & Borrowing

### Story 1: List Available Books
**As a** user
**I want to** see a list of all available books with pagination
**So that** I can browse and discover books I'm interested in

#### Acceptance Criteria
- [ ] GET /api/books returns paginated list (default: 10 items/page)
- [ ] Response includes: id, isbn, title, pages, status, createdAt
- [ ] Pagination params: page, size (query params)
- [ ] Status field must be one of: AVAILABLE, BORROWED, LOST, RETIRED
- [ ] Books ordered by createdAt DESC
- [ ] Empty list returns 200 (not 404)
- [ ] Invalid page param returns 400 with error message

#### Tasks (for Backend Developer)
1. [ ] Update BookRepository with pagination query
2. [ ] Create BookDTO response model
3. [ ] Implement BookController.listBooks(Pageable)
4. [ ] Add API documentation (OpenAPI)
5. [ ] Write unit & integration tests (85%+ coverage)
6. [ ] Manual testing in Postman/Insomnia

#### Tasks (for Web Frontend Developer)
1. [ ] Create BookController view handler
2. [ ] Design books/list.html template (Thymeleaf)
3. [ ] Add pagination UI (prev/next buttons)
4. [ ] Handle 404 error case
5. [ ] Add styling (CSS)
6. [ ] Test in browser (Chrome/Firefox)

#### Tasks (for Admin Frontend Developer)
1. [ ] Create BookAPI datasource
2. [ ] Create BookRepository
3. [ ] Design book_list_screen.dart widget
4. [ ] Implement Riverpod provider state
5. [ ] Handle loading/error/success states
6. [ ] Write widget tests

#### Estimation: 5 Story Points (3-5 days for full stack)

---

### Story 2: View Book Details
**As a** user
**I want to** click on a book and see detailed information
**So that** I can make an informed decision about borrowing

#### Acceptance Criteria
- [ ] GET /api/books/{id} returns single book details
- [ ] Includes owner information (id, email, name)
- [ ] 404 when book not found with message
- [ ] Detail view shows: title, isbn, description, pages, status, owner
- [ ] "Borrow" button enabled only when status = AVAILABLE
- [ ] Success message after borrow action

#### Tasks (Backend)
1. [ ] Implement BookService.getBook(id)
2. [ ] Add BookNotFoundException
3. [ ] REST endpoint GET /api/books/{id}
4. [ ] Tests for happy path + 404

#### Tasks (Web Frontend)
1. [ ] Create books/detail.html view
2. [ ] Add borrow button with confirmation dialog
3. [ ] Handle 404 gracefully

#### Tasks (Admin Frontend)
1. [ ] Create BookDetailScreen
2. [ ] Implement book_detail_provider
3. [ ] Widget for displaying details
4. [ ] Borrow/Action buttons

#### Estimation: 3 Story Points

---

### Story 3: Create New Book (Admin)
**As an** admin
**I want to** add new books to the inventory
**So that** users can borrow them

#### Acceptance Criteria
- [ ] POST /api/books with CreateBookDTO
- [ ] Validate: ISBN (10 or 13 digits), title (required), pages (>0)
- [ ] ISBN must be unique (409 Conflict if exists)
- [ ] Response: 201 Created with created book
- [ ] Admin form: title, isbn, description, pages fields
- [ ] Form client-side validation before submit
- [ ] Success message + redirect to detail
- [ ] Error message for duplicate ISBN

#### Tasks (Backend)
1. [ ] Create CreateBookDTO with validations
2. [ ] Implement BookService.createBook()
3. [ ] Add DuplicateBookException
4. [ ] POST /api/books endpoint
5. [ ] Business logic tests

#### Tasks (Web Frontend)
1. [ ] Create books/form.html (Thymeleaf)
2. [ ] Form fields: title, isbn, description, pages
3. [ ] Client-side validation feedback
4. [ ] Error display

#### Tasks (Admin Frontend)
1. [ ] CreateBookScreen with form
2. [ ] Input validation in UI
3. [ ] Error/success snackbars
4. [ ] Integration with booksProvider

#### Estimation: 5 Story Points

---

## Epic: Borrowing & Returns

### Story 4: Borrow a Book
**As a** user
**I want to** borrow an available book for 30 days
**So that** I can read it and then return it

#### Acceptance Criteria
- [ ] POST /api/borrows with { bookId, userId }
- [ ] User must be verified (not suspended)
- [ ] Max 5 concurrent borrows per user
- [ ] Book status must be AVAILABLE
- [ ] Creates BorrowRecord with dueDate = today + 30 days
- [ ] Updates Book status to BORROWED
- [ ] Returns BorrowDTO with borrowId, dueDate
- [ ] Validation errors: 400 with message
- [ ] 409 if already borrowed by user

#### Acceptance Tests
```gherkin
Feature: Book Borrowing
  Scenario: User borrows available book
    Given user is verified
    And book is available
    And user has < 5 active borrows
    When user borrows the book
    Then BorrowRecord is created
    And book status becomes BORROWED
    And response includes dueDate (30 days from now)

  Scenario: Cannot borrow unavailable book
    Given book status is BORROWED
    When user attempts to borrow
    Then 400 response with "Book not available"

  Scenario: Max borrows limit enforced
    Given user has 5 active borrows
    When user borrows another book
    Then 409 response with "Borrow limit exceeded"
```

#### Tasks (Backend)
1. [ ] Create BorrowRecord entity
2. [ ] Implement borrowing service logic
3. [ ] Create validations (verified, limit, availability)
4. [ ] BorrowDTO response model
5. [ ] POST /api/borrows endpoint
6. [ ] Integration tests for all scenarios
7. [ ] Load test (100 concurrent borrows)

#### Estimation: 8 Story Points

---

## Story 5: Return Borrowed Book
**As a** user
**I want to** return a borrowed book
**So that** others can borrow it and my record is updated

#### Acceptance Criteria
- [ ] PUT /api/borrows/{borrowId}/return
- [ ] Updates BorrowRecord.status = RETURNED
- [ ] Sets returnedAt = now
- [ ] Updates Book status = AVAILABLE
- [ ] 404 if borrow not found
- [ ] 400 if already returned

#### Estimation: 3 Story Points
```

### 3. Task Breakdown Template

```markdown
## User Story: [Story Name]

### Backend Tasks
- [ ] Task 1: Domain entity implementation
  - Files: `com.bookcycle.domain.entities.*`
  - Tests: Unit + Integration
  - Est: 2h

- [ ] Task 2: Repository query
  - Files: `com.bookcycle.domain.repositories.*`
  - Tests: Integration with TestContainers
  - Est: 1.5h

- [ ] Task 3: Service implementation
  - Files: `com.bookcycle.application.services.*`
  - Tests: Mocked repo, all branches
  - Est: 3h

- [ ] Task 4: REST Controller
  - Files: `com.bookcycle.infrastructure.web.controllers.*`
  - Tests: MockMvc, happy path + errors
  - Est: 2h

- [ ] Task 5: OpenAPI documentation
  - Update `openapi/api-spec.yaml`
  - Swagger annotations on controller
  - Est: 0.5h

**Backend Subtotal: 8.5h (1 developer, 2 days)**

### Web Frontend Tasks
- [ ] Task 1: Create Thymeleaf template
  - Files: `src/main/resources/templates/*.html`
  - Est: 2h

- [ ] Task 2: Implement controller handler
  - Files: `com.bookcycle.web.controllers.*`
  - Est: 1.5h

- [ ] Task 3: Form validation & error handling
  - Implement error-pages
  - Est: 1h

- [ ] Task 4: CSS styling
  - Bootstrap or custom CSS
  - Est: 1.5h

**Web Frontend Subtotal: 6h (1 developer, 1 day)**

### Admin Frontend Tasks
- [ ] Task 1: Create data models (DTOs)
  - Files: `lib/data/models/*_dto.dart`
  - Est: 1.5h

- [ ] Task 2: Implement API datasource
  - Files: `lib/data/datasources/*_api.dart`
  - Est: 1.5h

- [ ] Task 3: Create Riverpod providers
  - Files: `lib/presentation/state/*_provider.dart`
  - Est: 2h

- [ ] Task 4: Build screen widgets
  - Files: `lib/presentation/screens/*_screen.dart`
  - Est: 2.5h

- [ ] Task 5: Widget tests
  - Files: `test/presentation/screens/*_test.dart`
  - Est: 1.5h

**Admin Frontend Subtotal: 9h (1 developer, 2 days)**

**Total Story: 23.5h (3 developers, ~3 days)**
```

### 4. Definition of Done Checklist

```markdown
## Definition of Done – Code Complete

- [ ] Code written in feature branch
- [ ] Code follows project style guide
- [ ] Self-reviewed (walked through changes)
- [ ] Unit tests written (80%+ coverage)
- [ ] Integration tests written (where applicable)
- [ ] All tests passing locally
- [ ] No console errors/warnings
- [ ] Code commented (complex logic only)
- [ ] Documentation updated (if needed)
- [ ] Commit messages follow Conventional Commits

## Definition of Done – Ready for Code Review

- [ ] Pull Request created with description
- [ ] PR template filled completely
- [ ] Architecture checklist completed
- [ ] Links to related issues included
- [ ] Screenshots/videos (if UI changes)
- [ ] No hardcoded values or secrets
- [ ] No console.log/debug statements left

## Definition of Done – Merged to Main

- [ ] 2 approvals (or 1 if single dev)
- [ ] All CI/CD checks passed
- [ ] SonarQube quality gate passed
- [ ] Merge conflicts resolved
- [ ] Branch deleted after merge
- [ ] Deploy to staging (if applicable)
- [ ] Smoke tests passed on staging

## Definition of Done – Released

- [ ] Deployed to production
- [ ] No rollback needed (24h window)
- [ ] Monitoring alerts configured
- [ ] Feature visible in production
- [ ] Stakeholder sign-off (if needed)
```

### 5. Estimation & Planning

```markdown
## Fibonacci Story Points Scale

| Points | Time Estimate | Complexity | Example |
|--------|--------------|-----------|---------|
| 1 | < 4 hours | Trivial | Typo fix, add constant |
| 2 | 4-8 hours | Simple | Single function, small test |
| 3 | 1 day | Moderate | Small feature, known tech |
| 5 | 2-3 days | Complex | Multi-layer feature, some unknowns |
| 8 | 1 week | Very Complex | New tech, architectural change |
| 13 | 2+ weeks | Epic | Split into smaller stories |

## Sprint Capacity Calculation

```
Team: 3 developers (Backend, Web Frontend, Admin Frontend)
Sprint: 2 weeks (10 business days)
Hours/Day: 6h (1h standup, meetings, interruptions)
Team Capacity: 3 devs × 6h/day × 10 days = 180h

Average Story: 5 points = 20h
Sprint Goal: 35-40 story points (7-8 stories)
```

## Backlog Prioritization

```
High Priority (Next Sprint)
1. Story 1: List Available Books (5 pts)
2. Story 2: View Book Details (3 pts)
3. Story 4: Borrow a Book (8 pts)

Medium Priority (Sprint After)
4. Story 3: Create New Book (5 pts)
5. Story 5: Return Borrowed Book (3 pts)

Low Priority (Future)
- Advanced search & filters
- Wishlist feature
- Email notifications
- Admin analytics dashboard
```
```

### 6. Acceptance Testing Template

```markdown
## Acceptance Tests – Story 1: List Available Books

### Test Case 1: Fetch all available books
```
Given:
  - Database has 15 books (10 AVAILABLE, 5 BORROWED)

When:
  - GET /api/books

Then:
  - Status: 200 OK
  - Response: [10 books in JSON]
  - Each book has: id, isbn, title, pages, status, createdAt
  - Books ordered by createdAt DESC
  - No BORROWED books in response
```

### Test Case 2: Pagination – Second Page
```
Given:
  - Database has 25 available books
  - Default page size: 10

When:
  - GET /api/books?page=1&size=10

Then:
  - Status: 200 OK
  - Response contains books 11-20
  - hasNext = true (if >20 books)
```

### Test Case 3: Invalid Page Parameter
```
Given:
  - page = "invalid"

When:
  - GET /api/books?page=invalid

Then:
  - Status: 400 Bad Request
  - Body: { "error": "page must be a number" }
```

### Test Case 4: Empty Result
```
Given:
  - No books in database

When:
  - GET /api/books

Then:
  - Status: 200 OK
  - Response: []
  - Not 404
```

## Automation Testing (Selenium/Cypress)
```javascript
describe('Book List Page', () => {
  it('should display books in grid', () => {
    cy.visit('/books');
    cy.get('.book-card').should('have.length.greaterThan', 0);
    cy.get('.book-card').first().should('contain', 'Clean Code');
  });

  it('should paginate to next page', () => {
    cy.visit('/books');
    cy.get('a').contains('Next').click();
    cy.url().should('include', 'page=1');
  });

  it('should handle no books gracefully', () => {
    cy.intercept('GET', '/api/books', []);
    cy.visit('/books');
    cy.should('contain', 'No books available');
  });
});
```
```

---

## 🔄 Qualitätskriterien

| Kriterium | Standard | Prüfung |
|-----------|----------|---------|
| **User Stories** | INVEST-Kriterien erfüllt | Story Review |
| **AC Definition** | Testbar, konkret, messbar | Review |
| **Task Breakdown** | Verständlich für Dev | Review |
| **Estimation** | Konsistent über Stories | Velocity Tracking |
| **DoD Clarity** | Alle kennen Kriterien | Team Agreement |
| **Acceptance Tests** | Vor Implementierung definiert | BDD |
| **Release Planning** | Mit Velocity-Trend | Sprint Review |

---

## 🔗 Abhängigkeiten

- ⚠️ Abhängig von: **Stakeholder Input** + **Team Capacity**
- → Liefert an: **Alle anderen Agents** (klare User Stories)
- → Informiert: **Architecture Design** (Epic-Level Decisions)

---

## 🚀 Execution Pattern

```bash
# 1. Initiative kommt rein:
"Build Book Management Features"

# 2. PM Agent erstellt:
✅ Epic Definition (Vision, Goals, Metrics)
✅ User Stories mit AC
✅ Task Breakdown (Backend / Web / Admin)
✅ Definition of Done
✅ Acceptance Tests / BDD Scenarios
✅ Estimation (Story Points)
✅ Sprint Planning Input

# 3. Stories in GitHub Issues
# 4. Beauftrage spezialisierte Agents pro Story
# 5. Track velocity + metrics
```

---

## 📊 Metrics Tracking

```bash
# Velocity (Story Points / Sprint)
Sprint 1: 32 pts
Sprint 2: 35 pts
Sprint 3: 38 pts
Average: 35 pts/sprint

# Burndown Chart
Day 1: 40 pts planned
Day 2: 35 pts remaining
Day 3: 28 pts remaining
Day 4: 18 pts remaining
...
Day 10: 0 pts (Done!)

# Quality Metrics
Test Coverage: 87% (Target: 80%+)
Bug Rate: 0.5 bugs per 1000 LOC
Code Review Time: 4h avg
Deployment Success: 100%
```

---

**Nächster Schritt**: Lasse Stakeholder die User Stories reviewen → Beauftrage spezialisierte Agents.
