# Bookcycle – KI-Entwicklungsrichtlinien

**Status**: Bindend für alle Entwickler und KI-Assistenten  
**Gültig ab**: 2026-01-13  
**Zielgruppe**: Frontend (Spring Web MVC), Backend (Spring Boot), Admin-Frontend (Flutter)

---

## 🎯 Projektmission

Bookcycle ist eine Plattform zum Verwalten, Tauschen und Verleihen von Büchern. Das System trennt strikt:

- **Backend** (Spring Boot / Java 17+) – Core Business-Logik
- **Frontend** (Spring Web MVC) – Web-Oberfläche für Benutzer
- **Admin-Frontend** (Flutter) – Verwaltungs-Oberfläche

---

## 📐 Architektur-Fundament

### Clean Architecture (Backend)

```
Domain Layer
├── Entities (pure Java objects, keine Framework-Annotationen)
├── Enums & Value Objects
└── Interfaces (Contracts)

Application Layer (Use Cases)
├── Service-Klassen
├── DTOs (Data Transfer Objects)
└── Exception-Handling

Infrastructure Layer
├── Repositories (Spring Data JPA)
├── API-Controller
└── Framework-Integration
```

**Goldene Regeln:**
- Abhängigkeiten zeigen immer nach innen (Domain → App → Infrastructure)
- Domain-Layer ist 100% Framework-unabhängig
- DTOs sind Brücke zwischen Rest-API und Service-Layer
- Tests auf jeder Layer isoliert

### Spring Web MVC (Frontend)

```
Controller (Request/Response)
    ↓
Service-Layer (Geschäftslogik)
    ↓
View (Thymeleaf Template)
    
Model (Datenübergabe)
Form Binding & Bean Validation
```

**Goldene Regeln:**
- Controller leitet nur weiter, hat keine Geschäftslogik
- Service ist Einziger Zugriff auf Domain-Logik
- Views sind reine Templates ohne Java-Logik
- Fehler über dedicated Error-Views + Model-Attribute
- Validierung mit `@Valid` + `BindingResult`

### Flutter Admin Frontend

```
UI Layer
├── Screens / Widgets
├── State Management (Provider/Riverpod)
└── Error Handling UI

API Layer
├── REST-Client
├── DTOs (Models)
└── Error Handling

State Layer
├── Providers / Controllers
└── Data Transformation
```

**Goldene Regeln:**
- Keine direkten API-Calls in Widgets
- Explizite States: Loading, Error, Success, Empty
- Models exakt an Backend-DTOs angelehnt
- Fehlerbehandlung transparent für User

---

## 🏛️ Coding Standards

### 1. Java/Spring Backend

#### Naming Conventions

| Artefakt | Regel | Beispiel |
|----------|-------|---------|
| **Entity** | Singular, PascalCase | `Book`, `BorrowRecord` |
| **Enum** | PascalCase, no `Enum`-Suffix | `BorrowStatus`, `UserRole` |
| **DTO** | Suffix `DTO`, PascalCase | `BookDTO`, `CreateBorrowRequestDTO` |
| **Service** | Suffix `Service`, Interface-first | `IBookService`, `BookServiceImpl` |
| **Repository** | Suffix `Repository` | `BookRepository` |
| **Controller** | Suffix `Controller`, REST-fokussiert | `BookController` |
| **Exception** | Suffix `Exception` | `BookNotFoundException`, `InvalidBorrowException` |
| **Config** | Suffix `Config` | `DatabaseConfig` |
| **Mapper** | Suffix `Mapper` | `BookMapper` |

#### Package-Struktur

```
com.bookcycle
├── domain
│   ├── entities
│   ├── enums
│   ├── repositories (Interfaces!)
│   └── exceptions
├── application
│   ├── services
│   ├── dtos
│   ├── mappers
│   └── usecases
├── infrastructure
│   ├── persistence (JPA-Repos)
│   ├── web
│   │   ├── controllers
│   │   └── advice (Exception Handler)
│   └── config
└── shared
    └── utils
```

#### Annotation Rules

```java
// ✅ RICHTIG: Service-Layer
@Service
@Transactional  // Nur hier!
public class BookService {
    @Autowired private BookRepository repo;
    
    public BookDTO createBook(CreateBookDTO dto) {
        Book book = BookMapper.toDomain(dto);
        Book saved = repo.save(book);
        return BookMapper.toDTO(saved);
    }
}

// ❌ FALSCH: @Transactional im Controller
@RestController
@Transactional  // VERBOTEN!
public class BookController { }
```

#### Exception Handling

```java
// Domain Layer - Custom Exceptions
public class BookNotFoundException extends RuntimeException {
    public BookNotFoundException(String isbn) {
        super(String.format("Book with ISBN %s not found", isbn));
    }
}

// Service Layer - Catch & Wrap
@Service
public class BookService {
    public BookDTO getBook(String isbn) {
        return repository.findByIsbn(isbn)
            .map(BookMapper::toDTO)
            .orElseThrow(() -> new BookNotFoundException(isbn));
    }
}

// Controller Advice - Global Exception Handling
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(BookNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(
        BookNotFoundException e
    ) {
        return ResponseEntity.status(404)
            .body(new ErrorResponse(e.getMessage()));
    }
}
```

#### DTO Pattern

```java
// Request DTO – für Input
@Data
@AllArgsConstructor
@NoArgsConstructor
public class CreateBookDTO {
    @NotBlank(message = "Title required")
    private String title;
    
    @Email
    private String authorEmail;
    
    @Min(0)
    private int pages;
}

// Response DTO – für Output
@Data
public class BookDTO {
    private Long id;
    private String title;
    private String authorEmail;
    private int pages;
    private BookStatus status;
}

// Entity – Domain Model (no REST)
@Entity
@Data
public class Book {
    @Id @GeneratedValue
    private Long id;
    private String title;
    private String isbn;
    private int pages;
    
    @Enumerated(EnumType.STRING)
    private BookStatus status;
}
```

#### Testing Strategy

```
src/test/java/
├── unit/
│   ├── domain/entities
│   └── application/services
├── integration/
│   ├── persistence
│   └── services
└── acceptance/
    └── controllers
```

```java
// ✅ Unit Test (Domain/Entity)
class BookTest {
    @Test
    void shouldReturnAvailableWhenStatusIsAvailable() {
        Book book = new Book("ISBN", "Title", BookStatus.AVAILABLE);
        assertTrue(book.isAvailable());
    }
}

// ✅ Service Test (Mocked Repo)
@ExtendWith(MockitoExtension.class)
class BookServiceTest {
    @Mock private BookRepository repo;
    @InjectMocks private BookService service;
    
    @Test
    void shouldThrowWhenBookNotFound() {
        when(repo.findByIsbn("INVALID")).thenReturn(Optional.empty());
        
        assertThrows(BookNotFoundException.class, 
            () -> service.getBook("INVALID"));
    }
}

// ✅ Controller Test (SliceTest with MockMvc)
@WebMvcTest(BookController.class)
class BookControllerTest {
    @MockBean private BookService service;
    @Autowired private MockMvc mvc;
    
    @Test
    void shouldReturn200WhenBookFound() throws Exception {
        BookDTO dto = new BookDTO(1L, "Title", "status");
        when(service.getBook(1L)).thenReturn(dto);
        
        mvc.perform(get("/api/books/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.title").value("Title"));
    }
}
```

### 2. Spring Web MVC Frontend

#### Controller Standards

```java
@Controller
@RequestMapping("/books")
@RequiredArgsConstructor  // Constructor Injection
public class BookController {
    
    private final BookService bookService;
    
    // ✅ Nur Views und Redirects
    @GetMapping
    public String listBooks(Model model) {
        List<BookDTO> books = bookService.findAll();
        model.addAttribute("books", books);
        return "books/list";  // Thymeleaf template name
    }
    
    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model) {
        BookDTO book = bookService.getBook(id);
        model.addAttribute("book", book);
        return "books/detail";
    }
    
    @PostMapping
    public String create(@Valid @ModelAttribute CreateBookForm form, 
                         BindingResult errors, 
                         Model model) {
        if (errors.hasErrors()) {
            return "books/form";  // Re-render with errors
        }
        
        BookDTO created = bookService.createBook(form);
        return "redirect:/books/" + created.getId();
    }
}
```

#### Form & Validation

```java
// Form Class (Web Layer)
@Data
public class CreateBookForm {
    @NotBlank(message = "Title is required")
    private String title;
    
    @Email(message = "Valid email required")
    private String authorEmail;
    
    @Min(value = 1, message = "Pages must be > 0")
    private int pages;
}

// Template (Thymeleaf)
<form th:object="${form}" method="post" th:action="@{/books}">
    <div>
        <label for="title">Title</label>
        <input type="text" id="title" th:field="*{title}" />
        <span th:errors="*{title}" class="error" />
    </div>
    
    <div>
        <label for="author">Author Email</label>
        <input type="email" id="author" th:field="*{authorEmail}" />
        <span th:errors="*{authorEmail}" class="error" />
    </div>
    
    <button type="submit">Create</button>
</form>
```

#### Error Handling

```java
// Global Error Handler
@ControllerAdvice
public class WebErrorHandler {
    
    @ExceptionHandler(BookNotFoundException.class)
    public String handleNotFound(BookNotFoundException e, Model model) {
        model.addAttribute("error", e.getMessage());
        return "error/404";
    }
    
    @ExceptionHandler(InvalidBorrowException.class)
    public String handleInvalidBorrow(InvalidBorrowException e, 
                                      RedirectAttributes attrs) {
        attrs.addFlashAttribute("error", e.getMessage());
        return "redirect:/books";
    }
}

// Error Template (error/404.html)
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Book Not Found</title>
</head>
<body>
    <h1>404 – Book Not Found</h1>
    <p th:text="${error}"></p>
    <a href="/books">Back to books</a>
</body>
</html>
```

#### View Principles

```html
<!-- ✅ RICHTIG: Reine Template, keine Logic -->
<div th:each="book : ${books}" class="book-card">
    <h3 th:text="${book.title}"></h3>
    <p th:text="${book.authorEmail}"></p>
    <a th:href="@{/books/{id}(id=${book.id})}">Details</a>
</div>

<!-- ❌ FALSCH: Komplexe Logik im Template -->
<div th:each="book : ${books}">
    <h3 th:text="${book.title.toUpperCase()}"></h3>
    <span th:if="${book.pages > 500}">Long book</span>
</div>
```

### 3. Flutter Admin Frontend

#### Project Structure

```
lib/
├── main.dart
├── presentation/
│   ├── screens/
│   │   ├── book_list_screen.dart
│   │   └── book_detail_screen.dart
│   ├── widgets/
│   │   ├── book_card.dart
│   │   └── error_widget.dart
│   └── state/
│       └── book_provider.dart
├── domain/
│   ├── models/
│   │   └── book.dart
│   └── exceptions/
│       └── api_exception.dart
├── data/
│   ├── datasources/
│   │   └── book_api.dart
│   ├── models/
│   │   └── book_dto.dart
│   └── repositories/
│       └── book_repository.dart
└── config/
    └── api_config.dart
```

#### State Management (Riverpod)

```dart
// Data Model
class BookDTO {
  final int id;
  final String title;
  final String authorEmail;
  final int pages;
  final String status;

  BookDTO({
    required this.id,
    required this.title,
    required this.authorEmail,
    required this.pages,
    required this.status,
  });

  factory BookDTO.fromJson(Map<String, dynamic> json) => BookDTO(
    id: json['id'],
    title: json['title'],
    authorEmail: json['authorEmail'],
    pages: json['pages'],
    status: json['status'],
  );
}

// Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (${statusCode ?? 'unknown'})';
}

// Repository
class BookRepository {
  final http.Client _httpClient;
  final String baseUrl;

  BookRepository(this._httpClient, this.baseUrl);

  Future<List<BookDTO>> fetchBooks() async {
    try {
      final response = await _httpClient.get(Uri.parse('$baseUrl/api/books'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BookDTO.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to fetch books', statusCode: response.statusCode);
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }
}

// State Provider (Riverpod)
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository(http.Client(), 'http://localhost:8080');
});

final booksProvider = FutureProvider<List<BookDTO>>((ref) async {
  final repository = ref.watch(bookRepositoryProvider);
  return repository.fetchBooks();
});

// UI Layer
class BookListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsyncValue = ref.watch(booksProvider);

    return booksAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error', style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(booksProvider),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
      data: (books) => ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) => BookCard(book: books[index]),
      ),
    );
  }
}
```

#### Widget Guidelines

```dart
// ✅ RICHTIG: Stateless + Provider für State
class BookCard extends StatelessWidget {
  final BookDTO book;

  const BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(book.title),
        subtitle: Text(book.authorEmail),
        trailing: Icon(Icons.arrow_forward),
        onTap: () => _navigateToDetail(context),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: book.id)),
    );
  }
}

// ❌ FALSCH: Direkte API-Calls in Widget
class BadBookCard extends StatefulWidget {
  @override
  State<BadBookCard> createState() => _BadBookCardState();
}

class _BadBookCardState extends State<BadBookCard> {
  @override
  void initState() {
    super.initState();
    http.get(Uri.parse('http://localhost:8080/api/books'));  // NO!
  }
}
```

---

## 📋 Error Handling & Logging

### Backend Logging

```java
private static final Logger logger = LoggerFactory.getLogger(BookService.class);

@Service
public class BookService {
    
    public BookDTO getBook(Long id) {
        logger.info("Fetching book with ID: {}", id);
        
        try {
            BookDTO book = repository.findById(id)
                .map(BookMapper::toDTO)
                .orElseThrow(() -> new BookNotFoundException(id));
            logger.debug("Book found: {}", book);
            return book;
        } catch (BookNotFoundException e) {
            logger.warn("Book not found - ID: {}", id);
            throw e;
        } catch (Exception e) {
            logger.error("Unexpected error fetching book", e);
            throw new SystemException("Internal server error");
        }
    }
}
```

### Frontend Error Display

```java
// Spring Web
@ControllerAdvice
public class WebErrorHandler {
    @ExceptionHandler(Exception.class)
    public String handleGenericError(Exception e, Model model) {
        model.addAttribute("error", e.getMessage());
        logger.error("Unexpected error", e);
        return "error/500";
    }
}

// Flutter
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(error.toString()),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 5),
  ),
);
```

---

## 🧪 Testing Mandates

| Layer | Framework | Coverage | Key Test Type |
|-------|-----------|----------|---------------|
| **Domain Entities** | JUnit 5 | 90%+ | Unit Tests |
| **Service Logic** | JUnit 5 + Mockito | 85%+ | Unit + Integration |
| **Controllers (REST)** | MockMvc + WebMvcTest | 80%+ | Integration |
| **Controllers (Web)** | MockMvc + WebMvcTest | 75%+ | Integration |
| **Repositories** | Spring Boot Test + TestContainers | 70%+ | Integration |
| **Flutter Widgets** | Flutter Test | 60%+ | Widget Tests |

### Test Naming Convention

```
<Class>Test.java           (Unit)
<Class>IntegrationTest.java (Integration)
<Class>ControllerTest.java (Web/REST)
<class>_test.dart          (Flutter)
```

---

## 🚀 Development Workflows

### Feature Development (Git Flow)

```bash
# 1. Issue → Ticket
git checkout -b feature/BOOK-123-list-available-books

# 2. Code, Commit, Push
git add .
git commit -m "feat(book-service): implement list available books

- Filter books by status AVAILABLE
- Add pagination (page, size)
- Add sorting by title/date
- Unit tests: 100% coverage
- Integration tests: GET /api/books?status=AVAILABLE"

# 3. PR + Review + Merge
# → Squash & Merge to main
# → Delete branch
```

### Commit Message Format (Conventional Commits)

```
<type>(<scope>): <subject>

<body>

<footer>

---

Types:
- feat: New feature
- fix: Bug fix
- refactor: Code change without new features
- test: Test additions/changes
- docs: Documentation
- chore: Build, deps, config

Example:
feat(book-service): add book availability filter

- Added BookStatus enum
- Implemented filter in repository
- Added service method getAvailableBooks()
- Covered by 3 unit + 2 integration tests

Closes #BOOK-123
```

---

## 🏗️ Clean Architecture Checklist

Vor jedem **Code Commit** durchlaufen:

- [ ] **Domain Layer**: Keine Spring-Annotationen, pure Java Objects
- [ ] **Service Layer**: `@Transactional`, Dependency Injection via Constructor
- [ ] **Controller**: Nur `@GetMapping`, `@PostMapping`, keine Geschäftslogik
- [ ] **DTOs**: Separate Request- und Response-Klassen
- [ ] **Exceptions**: Custom Exception-Hierarchie mit aussagekräftigen Messages
- [ ] **Tests**: Unit + Integration auf jeder Layer
- [ ] **Logging**: INFO (key events), DEBUG (flow), ERROR (failures)
- [ ] **Validierung**: Bean Validation auf DTOs + Form
- [ ] **API-Docs**: OpenAPI-Annotations auf alle REST-Controller

---

## 📖 Dokumentation & Nachricht-Standards

### Code Comments (nur wenn unverzichtbar)

```java
// ❌ ÜBERFLÜSSIG
int count = 0;  // Initialize count to zero

// ✅ NOTWENDIG
// Using LinkedList to maintain insertion order for LRU cache
List<Book> recentBooks = new LinkedList<>();
```

### Git Commit Messages (siehe oben)

### Pull Request Beschreibung

```markdown
## Changes
- Added BookRepository.findAvailable()
- Implemented BookService.getAvailableBooks()
- Added REST endpoint GET /api/books?status=AVAILABLE

## Tests Added
- [ ] Unit test: BookRepositoryTest
- [ ] Integration test: BookServiceTest
- [ ] Controller test: BookControllerTest

## Architecture Review
- [ ] No business logic in controller
- [ ] DTOs used for REST
- [ ] Service layer handles transactions
- [ ] Error handling via GlobalExceptionHandler

## Related Issue
Closes #BOOK-123
```

---

## 🔐 Qualität & Sicherheit

### Security Rules

- **Never** log sensitive data (passwords, emails without masking, PII)
- **Always** validate & sanitize user input
- **Use** Spring Security for authentication
- **Add** CSRF tokens for Web MVC forms
- **Encrypt** database passwords in application.properties

### Code Quality Gates

```
Minimum Standards:
- Test Coverage >= 80%
- No sonarqube CRITICAL issues
- No hardcoded secrets
- No SQL injection vulnerabilities
- Checkstyle: Google Java Style
- Spotbugs: 0 HIGH issues
```

---

## 👥 Team & KI-Rollen

| Rolle | KI-Agent | Verantwortung |
|-------|----------|---------------|
| **Backend Architect** | `backend-clean-architecture.agent.md` | Domain Design, Repository Pattern |
| **Business Logic Eng.** | `business-logic.agent.md` | Service Implementation, Transactions |
| **Web Frontend Eng.** | `spring-web-mvc.agent.md` | Controller, Views, Form Handling |
| **Admin UI Eng.** | `flutter-admin.agent.md` | Flutter Screens, State Management |
| **Project Lead** | `project-manager.agent.md` | User Stories, Refinement, Planning |

---

## 📞 KI-Fragen & Antwortverhalten

### Was KI NICHT tun darf

❌ Pull Request mergen  
❌ Direkten Datenbank-Access ohne Tests  
❌ Production-Secrets in Code schreiben  
❌ API-Breaking Changes ohne Issue  
❌ Tests skippen zur "Effizienz"  

### Was KI TUN soll

✅ Code generieren + begründen  
✅ Tests schreiben (Unit + Integration)  
✅ Pull Request Beschreibung strukturieren  
✅ Architecture Review durchführen  
✅ Abhängigkeiten zu anderen Tickets aufzeigen  

---

## 🔗 Links & Ressourcen

- **Architecture**: [docs/architecture.md](../docs/architecture.md)
- **API Spec**: [openapi/api-spec.yaml](../../openapi/api-spec.yaml)
- **Agents**: [.github/agents/](./agents/)
- **Prompts**: [docs/prompts/workflow-prompts.md](../prompts/workflow-prompts.md)

---

**Fragen? Issues?** → Nutze die spezialisierten Agents in `.github/agents/`
