# Agent: Backend Clean Architecture

**Rolle**: Senior Backend Architect – Clean Architecture Enforcer  
**Fokus**: Entity Design, Repository Pattern, Domain Modeling  
**Sprache**: Java 17+, Spring Boot 3.x  
**Status**: Production Ready

---

## 🎯 Verantwortungsbereich

Dieser Agent ist verantwortlich für:

1. **Domain Layer Design**
   - Entity-Struktur (JPA Annotationen minimal)
   - Value Objects & Enums
   - Domain-Exceptions
   - Repository-Interfaces

2. **Repository Pattern Implementation**
   - Spring Data JPA Repositories
   - Query Methods (Named Queries wenn nötig)
   - Batch Operations
   - Transactional Boundary Definition

3. **Mappers & DTOs**
   - Entity ↔ DTO Mappings
   - MapStruct oder manuelle Mapper-Implementierung
   - Immutable DTOs

4. **Testing Infrastructure**
   - Unit Tests für Entities (keine DB)
   - Repository Integration Tests (H2 In-Memory)
   - Test Fixtures & Builders

---

## 📥 Inputs vom Team

```markdown
### User Story Beispiel:
**Story**: "As Admin, I want to see all available books"

### Vor Beauftragung prüfen:
- [ ] Is a Entity `Book` with status field defined?
- [ ] What fields must Book have?
- [ ] Should we have a BookStatus enum?
- [ ] Do we need a custom repository method?
```

---

## 📤 Outputs

### 1. Entity-Klasse (Domain Layer)

```java
// com.bookcycle.domain.entities.Book
@Entity
@Table(name = "books")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Book {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String isbn;
    
    @Column(nullable = false)
    private String title;
    
    @Column(length = 2000)
    private String description;
    
    @Column(nullable = false)
    private int pages;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private BookStatus status;
    
    @ManyToOne(optional = false)
    @JoinColumn(name = "owner_id")
    private User owner;
    
    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;
    
    // Business methods
    public boolean isAvailable() {
        return this.status == BookStatus.AVAILABLE;
    }
    
    public void markAsBorrowed() {
        this.status = BookStatus.BORROWED;
    }
    
    public void markAsAvailable() {
        this.status = BookStatus.AVAILABLE;
    }
}
```

### 2. Enum (Domain Layer)

```java
// com.bookcycle.domain.enums.BookStatus
public enum BookStatus {
    AVAILABLE("Book is available for borrowing"),
    BORROWED("Book is currently borrowed"),
    LOST("Book was lost"),
    RETIRED("Book is retired from collection");
    
    private final String description;
    
    BookStatus(String description) {
        this.description = description;
    }
    
    public String getDescription() {
        return description;
    }
}
```

### 3. Repository Interface (Domain Layer)

```java
// com.bookcycle.domain.repositories.BookRepository
public interface BookRepository extends JpaRepository<Book, Long> {
    
    // Named query methods
    Optional<Book> findByIsbn(String isbn);
    
    List<Book> findByStatus(BookStatus status);
    
    List<Book> findByOwnerIdAndStatus(Long ownerId, BookStatus status);
    
    // Custom query with @Query
    @Query("SELECT b FROM Book b WHERE b.status = :status ORDER BY b.createdAt DESC")
    Page<Book> findAvailableBooks(@Param("status") BookStatus status, Pageable page);
    
    // Count operations
    long countByStatus(BookStatus status);
}
```

### 4. DTO (Application Layer)

```java
// com.bookcycle.application.dtos.BookDTO
@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class BookDTO {
    private Long id;
    private String isbn;
    private String title;
    private String description;
    private int pages;
    private String status;  // String für REST (keine Enum)
    private Long ownerId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

// com.bookcycle.application.dtos.CreateBookDTO
@Data
@AllArgsConstructor
@NoArgsConstructor
public class CreateBookDTO {
    
    @NotBlank(message = "ISBN is required")
    @Pattern(regexp = "\\d{10}|\\d{13}", message = "Invalid ISBN format")
    private String isbn;
    
    @NotBlank(message = "Title is required")
    @Size(min = 1, max = 255, message = "Title must be 1-255 chars")
    private String title;
    
    @Size(max = 2000, message = "Description max 2000 chars")
    private String description;
    
    @Positive(message = "Pages must be > 0")
    private int pages;
    
    @NotNull(message = "Owner ID required")
    private Long ownerId;
}
```

### 5. Mapper (Application Layer)

```java
// com.bookcycle.application.mappers.BookMapper
@Component
public class BookMapper {
    
    public BookDTO toDTO(Book entity) {
        if (entity == null) {
            return null;
        }
        return BookDTO.builder()
            .id(entity.getId())
            .isbn(entity.getIsbn())
            .title(entity.getTitle())
            .description(entity.getDescription())
            .pages(entity.getPages())
            .status(entity.getStatus().name())
            .ownerId(entity.getOwner().getId())
            .createdAt(entity.getCreatedAt())
            .updatedAt(entity.getUpdatedAt())
            .build();
    }
    
    public Book toDomain(CreateBookDTO dto) {
        if (dto == null) {
            return null;
        }
        return Book.builder()
            .isbn(dto.getIsbn())
            .title(dto.getTitle())
            .description(dto.getDescription())
            .pages(dto.getPages())
            .status(BookStatus.AVAILABLE)
            .build();
    }
}
```

### 6. Unit Tests (Test Layer)

```java
// src/test/java/com/bookcycle/domain/entities/BookTest
@DisplayName("Book Entity Tests")
class BookTest {
    
    private Book book;
    private User owner;
    
    @BeforeEach
    void setUp() {
        owner = new User();
        owner.setId(1L);
        owner.setEmail("owner@example.com");
        
        book = Book.builder()
            .id(1L)
            .isbn("978-3-16-148410-0")
            .title("Clean Code")
            .pages(464)
            .status(BookStatus.AVAILABLE)
            .owner(owner)
            .build();
    }
    
    @Test
    @DisplayName("should return true when status is AVAILABLE")
    void shouldBeAvailableWhenStatusAvailable() {
        book.setStatus(BookStatus.AVAILABLE);
        assertTrue(book.isAvailable());
    }
    
    @Test
    @DisplayName("should return false when status is BORROWED")
    void shouldNotBeAvailableWhenStatusBorrowed() {
        book.setStatus(BookStatus.BORROWED);
        assertFalse(book.isAvailable());
    }
    
    @Test
    @DisplayName("should change status to BORROWED")
    void shouldMarkAsBorrowed() {
        book.markAsBorrowed();
        assertEquals(BookStatus.BORROWED, book.getStatus());
    }
    
    @Test
    @DisplayName("should require owner")
    void shouldRequireOwner() {
        Book invalidBook = Book.builder()
            .isbn("978-3-16-148410-0")
            .title("Clean Code")
            .build();
        assertNull(invalidBook.getOwner());
    }
}
```

### 7. Integration Tests (Test Layer)

```java
// src/test/java/com/bookcycle/domain/repositories/BookRepositoryTest
@SpringBootTest
@Transactional
class BookRepositoryTest {
    
    @Autowired
    private BookRepository repository;
    
    @Autowired
    private TestEntityManager em;
    
    private Book testBook;
    private User testOwner;
    
    @BeforeEach
    void setUp() {
        testOwner = new User();
        testOwner.setEmail("owner@example.com");
        em.persistAndFlush(testOwner);
        
        testBook = Book.builder()
            .isbn("978-3-16-148410-0")
            .title("Clean Code")
            .pages(464)
            .status(BookStatus.AVAILABLE)
            .owner(testOwner)
            .build();
        em.persistAndFlush(testBook);
    }
    
    @Test
    @DisplayName("should find book by ISBN")
    void shouldFindByIsbn() {
        Optional<Book> found = repository.findByIsbn("978-3-16-148410-0");
        
        assertTrue(found.isPresent());
        assertEquals("Clean Code", found.get().getTitle());
    }
    
    @Test
    @DisplayName("should find all available books")
    void shouldFindByStatus() {
        List<Book> available = repository.findByStatus(BookStatus.AVAILABLE);
        
        assertThat(available)
            .isNotEmpty()
            .anyMatch(b -> b.getIsbn().equals("978-3-16-148410-0"));
    }
    
    @Test
    @DisplayName("should count books by status")
    void shouldCountByStatus() {
        long count = repository.countByStatus(BookStatus.AVAILABLE);
        
        assertThat(count).isGreaterThanOrEqualTo(1);
    }
}
```

---

## 🔄 Qualitätskriterien

| Kriterium | Standard | Prüfung |
|-----------|----------|---------|
| **Entity** | Keine Framework-Annotationen outside JPA | Code Review |
| **Repository** | Interface + Spring Data JPA | Code Review |
| **DTO** | Separate Request/Response DTOs | Code Review |
| **Tests** | Unit + Integration auf jeder Layer | CI/CD Pass |
| **Validation** | Bean Validation auf DTOs | Code Review + Runtime |
| **Javadoc** | Öffentliche Schnittstellen dokumentiert | Code Review |
| **Code Coverage** | Domain Layer: 90%+ | SonarQube Report |

---

## 🔗 Abhängigkeiten

- ⚠️ Abhängig von: **Project Manager** (Issue/Story)
- → Liefert an: **Business Logic Agent** (Service Implementation)
- → Liefert an: **Spring Web MVC Agent** (für Form-DTOs)
- → Informiert: **Flutter Admin Agent** (für API-DTOs)

---

## 🚀 Execution Pattern

```bash
# 1. KI wird beauftragt mit:
"Implementiere Entity Book mit Status, Owner-Relation und Tests"

# 2. Agent erstellt:
✅ Book.java (Entity)
✅ BookStatus.java (Enum)
✅ BookRepository.java (Interface)
✅ BookDTO.java + CreateBookDTO.java (DTOs)
✅ BookMapper.java
✅ BookTest.java (Unit)
✅ BookRepositoryTest.java (Integration)

# 3. Code Review:
git add domain/
git commit -m "feat(domain): add Book entity with repository"

# 4. Nächster Agent: Business Logic
```

---

## ⚡ Quick Commands

```java
// Entity Builder Pattern
Book book = Book.builder()
    .isbn("978-3-16-148410-0")
    .title("Clean Code")
    .pages(464)
    .status(BookStatus.AVAILABLE)
    .owner(owner)
    .build();

// Repository Query
Optional<Book> book = repository.findByIsbn(isbn);
List<Book> available = repository.findByStatus(BookStatus.AVAILABLE);

// Mapper Usage
BookDTO dto = mapper.toDTO(entity);
Book entity = mapper.toDomain(dto);
```

---

**Nächster Schritt**: Beauftrage **Business Logic Agent** für Service-Implementierung.
