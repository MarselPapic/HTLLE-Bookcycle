# Agent: Business Logic & Services

**Rolle**: Service Layer Architect – Use Cases & Transactions  
**Fokus**: Service Implementation, Business Rules, Transactional Boundaries  
**Sprache**: Java 17+, Spring Boot 3.x  
**Status**: Production Ready

---

## 🎯 Verantwortungsbereich

Dieser Agent ist verantwortlich für:

1. **Service Interface & Implementation**
   - Geschäftslogik-Kapselung
   - Transactional Boundaries
   - Dependency Injection (Constructor-based)

2. **Use Case Implementation**
   - Multi-Step Operations
   - Data Transformation (Entity → DTO)
   - Error Handling & Validation

3. **Business Rules & Validations**
   - Custom Validations (beyond Bean Validation)
   - Business Exception Hierarchie
   - Logging & Audit Trails

4. **Repository Orchestration**
   - Efficient Query Execution
   - Pagination & Sorting
   - Batch Operations

---

## 📥 Inputs vom Team

```markdown
### User Story:
**Story**: "As user, I want to borrow an available book"

### Requirements:
- [ ] Book must be AVAILABLE status
- [ ] User must be verified (not suspended)
- [ ] Max 5 concurrent borrows per user
- [ ] Borrow duration: 30 days
- [ ] Auto-generate BorrowRecord with dates
```

---

## 📤 Outputs

### 1. Service Interface (Application Layer)

```java
// com.bookcycle.application.services.IBookService
public interface IBookService {
    
    BookDTO getBook(Long id);
    
    List<BookDTO> getAllAvailableBooks(Pageable page);
    
    BookDTO createBook(CreateBookDTO dto);
    
    BorrowDTO borrowBook(Long bookId, Long userId);
    
    void returnBook(Long borrowId);
}
```

### 2. Service Implementation (Application Layer)

```java
// com.bookcycle.application.services.BookService
@Service
@RequiredArgsConstructor
@Slf4j
public class BookService implements IBookService {
    
    private final BookRepository bookRepository;
    private final UserRepository userRepository;
    private final BorrowRecordRepository borrowRepository;
    private final BookMapper bookMapper;
    
    @Override
    @Transactional(readOnly = true)
    public BookDTO getBook(Long id) {
        log.info("Fetching book with ID: {}", id);
        
        return bookRepository.findById(id)
            .map(bookMapper::toDTO)
            .orElseThrow(() -> {
                log.warn("Book not found - ID: {}", id);
                return new BookNotFoundException(id);
            });
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<BookDTO> getAllAvailableBooks(Pageable page) {
        log.debug("Fetching available books - page: {}", page.getPageNumber());
        
        return bookRepository
            .findByStatus(BookStatus.AVAILABLE, page)
            .stream()
            .map(bookMapper::toDTO)
            .collect(Collectors.toList());
    }
    
    @Override
    @Transactional
    public BookDTO createBook(CreateBookDTO dto) {
        log.info("Creating new book: {}", dto.getTitle());
        
        // Validations
        if (bookRepository.findByIsbn(dto.getIsbn()).isPresent()) {
            throw new DuplicateBookException(dto.getIsbn());
        }
        
        User owner = userRepository.findById(dto.getOwnerId())
            .orElseThrow(() -> new UserNotFoundException(dto.getOwnerId()));
        
        if (!owner.isVerified()) {
            throw new UserNotVerifiedException(owner.getId());
        }
        
        // Create & Save
        Book book = bookMapper.toDomain(dto);
        book.setOwner(owner);
        book.setStatus(BookStatus.AVAILABLE);
        
        Book saved = bookRepository.save(book);
        log.info("Book created successfully - ID: {}, ISBN: {}", saved.getId(), saved.getIsbn());
        
        return bookMapper.toDTO(saved);
    }
    
    @Override
    @Transactional
    public BorrowDTO borrowBook(Long bookId, Long userId) {
        log.info("User {} attempting to borrow book {}", userId, bookId);
        
        // Load entities
        Book book = bookRepository.findById(bookId)
            .orElseThrow(() -> new BookNotFoundException(bookId));
        
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new UserNotFoundException(userId));
        
        // Business validations
        this.validateBorrow(book, user);
        
        // Create BorrowRecord
        BorrowRecord record = BorrowRecord.builder()
            .book(book)
            .borrower(user)
            .borrowedAt(LocalDateTime.now())
            .dueDate(LocalDateTime.now().plusDays(30))
            .status(BorrowStatus.ACTIVE)
            .build();
        
        BorrowRecord saved = borrowRepository.save(record);
        
        // Update book status
        book.setStatus(BookStatus.BORROWED);
        bookRepository.save(book);
        
        log.info("Book borrowed successfully - ID: {}, User: {}", bookId, userId);
        return new BorrowMapper().toDTO(saved);
    }
    
    @Override
    @Transactional
    public void returnBook(Long borrowId) {
        log.info("Returning borrow record: {}", borrowId);
        
        BorrowRecord record = borrowRepository.findById(borrowId)
            .orElseThrow(() -> new BorrowRecordNotFoundException(borrowId));
        
        if (record.getStatus() == BorrowStatus.RETURNED) {
            throw new AlreadyReturnedException(borrowId);
        }
        
        // Update record
        record.setStatus(BorrowStatus.RETURNED);
        record.setReturnedAt(LocalDateTime.now());
        borrowRepository.save(record);
        
        // Update book
        Book book = record.getBook();
        book.setStatus(BookStatus.AVAILABLE);
        bookRepository.save(book);
        
        log.info("Book returned successfully - ID: {}", record.getBook().getId());
    }
    
    // Private validation method
    private void validateBorrow(Book book, User user) {
        // Check book availability
        if (book.getStatus() != BookStatus.AVAILABLE) {
            throw new BookNotAvailableException(book.getId(), book.getStatus());
        }
        
        // Check user verified
        if (!user.isVerified()) {
            throw new UserNotVerifiedException(user.getId());
        }
        
        // Check max concurrent borrows
        long activeBorrows = borrowRepository
            .countByBorrowerIdAndStatus(user.getId(), BorrowStatus.ACTIVE);
        
        if (activeBorrows >= 5) {
            throw new BorrowLimitExceededException(user.getId(), 5);
        }
        
        // Check no duplicate active borrows
        if (borrowRepository.existsByBookIdAndStatusAndBorrowerId(
            book.getId(), BorrowStatus.ACTIVE, user.getId())) {
            throw new AlreadyBorrowedException(book.getId(), user.getId());
        }
    }
}
```

### 3. Custom Exceptions (Domain Layer)

```java
// com.bookcycle.domain.exceptions.*Exception

public class BookNotFoundException extends RuntimeException {
    public BookNotFoundException(Long id) {
        super(String.format("Book not found: %d", id));
    }
}

public class BookNotAvailableException extends RuntimeException {
    public BookNotAvailableException(Long bookId, BookStatus status) {
        super(String.format("Book %d is not available (status: %s)", bookId, status));
    }
}

public class BorrowLimitExceededException extends RuntimeException {
    public BorrowLimitExceededException(Long userId, int maxBorrows) {
        super(String.format("User %d has reached max borrow limit: %d", userId, maxBorrows));
    }
}

public class UserNotVerifiedException extends RuntimeException {
    public UserNotVerifiedException(Long userId) {
        super(String.format("User %d is not verified", userId));
    }
}
```

### 4. Service Tests

```java
// src/test/java/com/bookcycle/application/services/BookServiceTest
@ExtendWith(MockitoExtension.class)
@DisplayName("BookService Tests")
class BookServiceTest {
    
    @Mock
    private BookRepository bookRepository;
    
    @Mock
    private UserRepository userRepository;
    
    @Mock
    private BorrowRecordRepository borrowRepository;
    
    @Mock
    private BookMapper bookMapper;
    
    @InjectMocks
    private BookService service;
    
    private Book testBook;
    private User testUser;
    
    @BeforeEach
    void setUp() {
        testBook = Book.builder()
            .id(1L)
            .isbn("978-3-16-148410-0")
            .title("Clean Code")
            .status(BookStatus.AVAILABLE)
            .build();
        
        testUser = User.builder()
            .id(1L)
            .email("user@example.com")
            .verified(true)
            .build();
    }
    
    @Test
    @DisplayName("should throw when book not found")
    void shouldThrowWhenBookNotFound() {
        when(bookRepository.findById(999L)).thenReturn(Optional.empty());
        
        assertThrows(BookNotFoundException.class, 
            () -> service.getBook(999L));
    }
    
    @Test
    @DisplayName("should return book DTO when found")
    void shouldReturnDTOWhenFound() {
        BookDTO expected = new BookDTO(1L, "Clean Code", "978-3-16-148410-0", 
            "AVAILABLE", LocalDateTime.now(), LocalDateTime.now());
        
        when(bookRepository.findById(1L)).thenReturn(Optional.of(testBook));
        when(bookMapper.toDTO(testBook)).thenReturn(expected);
        
        BookDTO result = service.getBook(1L);
        
        assertThat(result)
            .isNotNull()
            .extracting("title")
            .isEqualTo("Clean Code");
    }
    
    @Test
    @DisplayName("should throw when borrowing unavailable book")
    void shouldThrowWhenBookUnavailable() {
        testBook.setStatus(BookStatus.BORROWED);
        
        when(bookRepository.findById(1L)).thenReturn(Optional.of(testBook));
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        
        assertThrows(BookNotAvailableException.class,
            () -> service.borrowBook(1L, 1L));
    }
    
    @Test
    @DisplayName("should create borrow record successfully")
    void shouldCreateBorrowRecord() {
        BorrowRecord record = BorrowRecord.builder()
            .id(1L)
            .book(testBook)
            .borrower(testUser)
            .status(BorrowStatus.ACTIVE)
            .build();
        
        when(bookRepository.findById(1L)).thenReturn(Optional.of(testBook));
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(borrowRepository.countByBorrowerIdAndStatus(1L, BorrowStatus.ACTIVE))
            .thenReturn(0L);
        when(borrowRepository.existsByBookIdAndStatusAndBorrowerId(1L, BorrowStatus.ACTIVE, 1L))
            .thenReturn(false);
        when(borrowRepository.save(any())).thenReturn(record);
        
        BorrowDTO result = service.borrowBook(1L, 1L);
        
        assertThat(result).isNotNull();
        verify(bookRepository).save(testBook);
    }
}

// Integration Test
@SpringBootTest
@Transactional
class BookServiceIntegrationTest {
    
    @Autowired
    private BookService service;
    
    @Autowired
    private BookRepository bookRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    private User testUser;
    
    @BeforeEach
    void setUp() {
        testUser = User.builder()
            .email("user@example.com")
            .verified(true)
            .build();
        userRepository.save(testUser);
    }
    
    @Test
    @DisplayName("should create book and retrieve successfully")
    void shouldCreateAndRetrieveBook() {
        CreateBookDTO dto = new CreateBookDTO();
        dto.setIsbn("978-3-16-148410-0");
        dto.setTitle("Clean Code");
        dto.setPages(464);
        dto.setOwnerId(testUser.getId());
        
        BookDTO created = service.createBook(dto);
        
        assertThat(created)
            .isNotNull()
            .extracting("title")
            .isEqualTo("Clean Code");
    }
}
```

---

## 🔄 Qualitätskriterien

| Kriterium | Standard | Prüfung |
|-----------|----------|---------|
| **@Transactional** | Nur auf Service-Methoden | Code Review |
| **Validations** | Business Rules vor DB-Zugriff | Tests |
| **Error Handling** | Custom Exceptions + Logging | Code Review |
| **Logging** | INFO (events), DEBUG (flow), ERROR (failure) | Code Review |
| **Dependency Injection** | Constructor-based nur | Code Review |
| **Test Coverage** | 85%+ für Service-Layer | SonarQube |
| **Performance** | N+1 Queries vermeiden | Review |

---

## 🔗 Abhängigkeiten

- ⚠️ Abhängig von: **Backend Clean Architecture Agent** (Entities, Repositories)
- → Liefert an: **Spring Web MVC Agent** (für Controller)
- → Liefert an: **REST Controller** (über DTOs)

---

## 🚀 Execution Pattern

```bash
# 1. Konfiguration:
"Implementiere BookService mit Borrow-Logik und 30-Tage-Limit"

# 2. Agent erstellt:
✅ IBookService.java (Interface)
✅ BookService.java (Implementation)
✅ Custom Exceptions
✅ BookServiceTest.java (Unit + Integration)

# 3. Git Commit:
git commit -m "feat(service): add BookService with borrow logic"

# 4. Nächster: Spring Web MVC Agent
```

---

**Nächster Schritt**: Beauftrage **Spring Web MVC Agent** für Web-UI Implementierung.
