# Agent: Spring Web MVC Frontend

**Rolle**: Web UI Architect – MVC Controller & Views  
**Fokus**: Controller Implementation, Form Handling, Error Pages  
**Sprache**: Java 17+, Spring Boot 3.x, Thymeleaf  
**Status**: Production Ready

---

## 🎯 Verantwortungsbereich

Dieser Agent ist verantwortlich für:

1. **Controller Implementation**
   - Request Mapping
   - Form Binding & Validation
   - Model-Attribute Management
   - Redirect vs. View Logic

2. **View Design (Thymeleaf)**
   - HTML Template Structure
   - Form Rendering
   - Error Message Display
   - Zero Business Logic in Templates

3. **Form Handling**
   - Bean Validation Integration
   - BindingResult Processing
   - Flash Attributes für Messages
   - Form Fragments/Reuse

4. **Error Handling**
   - Global Exception Handler
   - Error Pages (404, 500)
   - User-friendly Messages
   - Logging Integration

---

## 📥 Inputs vom Team

```markdown
### User Story:
**Story**: "As user, I want to list all available books and see details"

### Requirements:
- [ ] GET /books → List all (paginated, 10 per page)
- [ ] GET /books/{id} → Detail view
- [ ] Form validation visible on page
- [ ] Error page for not found
```

---

## 📤 Outputs

### 1. Controller (Web Layer)

```java
// com.bookcycle.infrastructure.web.controllers.BookController
@Controller
@RequestMapping("/books")
@RequiredArgsConstructor
@Slf4j
public class BookController {
    
    private final IBookService bookService;
    
    // ========== GET Mappings ==========
    
    @GetMapping
    public String listBooks(
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "10") int size,
        Model model) {
        
        log.info("Listing books - page: {}, size: {}", page, size);
        
        try {
            Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
            List<BookDTO> books = bookService.getAllAvailableBooks(pageable);
            
            model.addAttribute("books", books);
            model.addAttribute("currentPage", page);
            model.addAttribute("pageSize", size);
            model.addAttribute("hasNext", books.size() == size);
            
            return "books/list";
        } catch (Exception e) {
            log.error("Error listing books", e);
            model.addAttribute("error", "Could not load books");
            return "error/500";
        }
    }
    
    @GetMapping("/{id}")
    public String detail(
        @PathVariable Long id,
        Model model) {
        
        log.info("Loading book detail - ID: {}", id);
        
        try {
            BookDTO book = bookService.getBook(id);
            model.addAttribute("book", book);
            return "books/detail";
        } catch (BookNotFoundException e) {
            log.warn("Book not found - ID: {}", id);
            model.addAttribute("error", e.getMessage());
            return "error/404";
        }
    }
    
    // ========== POST Mappings ==========
    
    @GetMapping("/new")
    public String showCreateForm(Model model) {
        model.addAttribute("form", new CreateBookForm());
        return "books/form";
    }
    
    @PostMapping
    public String createBook(
        @Valid @ModelAttribute("form") CreateBookForm form,
        BindingResult errors,
        RedirectAttributes attrs,
        Model model) {
        
        log.info("Creating new book: {}", form.getTitle());
        
        // Validation errors → re-render form
        if (errors.hasErrors()) {
            log.debug("Form validation failed: {}", errors.getAllErrors());
            return "books/form";
        }
        
        try {
            CreateBookDTO dto = this.mapFormToDTO(form);
            BookDTO created = bookService.createBook(dto);
            
            attrs.addFlashAttribute("success", 
                "Book created successfully: " + created.getTitle());
            return "redirect:/books/" + created.getId();
        } catch (DuplicateBookException e) {
            log.warn("Duplicate ISBN: {}", form.getIsbn());
            model.addAttribute("error", "ISBN already exists");
            return "books/form";
        } catch (UserNotVerifiedException e) {
            log.warn("User not verified - ID: {}", form.getOwnerId());
            attrs.addFlashAttribute("error", "Your account is not verified");
            return "redirect:/books";
        }
    }
    
    // ========== Helper Methods ==========
    
    private CreateBookDTO mapFormToDTO(CreateBookForm form) {
        return CreateBookDTO.builder()
            .isbn(form.getIsbn().trim())
            .title(form.getTitle().trim())
            .description(form.getDescription())
            .pages(form.getPages())
            .ownerId(form.getOwnerId())
            .build();
    }
}
```

### 2. Form Class (Web Layer)

```java
// com.bookcycle.infrastructure.web.forms.CreateBookForm
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateBookForm {
    
    @NotBlank(message = "Title is required")
    @Size(min = 1, max = 255, message = "Title must be 1-255 characters")
    private String title;
    
    @NotBlank(message = "ISBN is required")
    @Pattern(
        regexp = "\\d{10}|\\d{13}",
        message = "ISBN must be 10 or 13 digits")
    private String isbn;
    
    @Size(max = 2000, message = "Description max 2000 characters")
    private String description;
    
    @Positive(message = "Pages must be greater than 0")
    private int pages;
    
    @NotNull(message = "Owner ID is required")
    private Long ownerId;
}
```

### 3. Global Exception Handler (Web Layer)

```java
// com.bookcycle.infrastructure.web.advice.GlobalExceptionHandler
@ControllerAdvice
@Slf4j
public class GlobalExceptionHandler {
    
    @ExceptionHandler(BookNotFoundException.class)
    public String handleBookNotFound(
        BookNotFoundException e,
        Model model) {
        
        log.warn("Book not found: {}", e.getMessage());
        model.addAttribute("error", e.getMessage());
        model.addAttribute("statusCode", 404);
        return "error/not-found";
    }
    
    @ExceptionHandler(BookNotAvailableException.class)
    public String handleBookUnavailable(
        BookNotAvailableException e,
        RedirectAttributes attrs) {
        
        log.warn("Book unavailable: {}", e.getMessage());
        attrs.addFlashAttribute("error", 
            "This book is not available for borrowing right now");
        return "redirect:/books";
    }
    
    @ExceptionHandler(BorrowLimitExceededException.class)
    public String handleBorrowLimitExceeded(
        BorrowLimitExceededException e,
        RedirectAttributes attrs) {
        
        log.warn("Borrow limit exceeded: {}", e.getMessage());
        attrs.addFlashAttribute("error", 
            "You have reached your borrowing limit. Please return books first.");
        return "redirect:/books";
    }
    
    @ExceptionHandler(Exception.class)
    public String handleGenericError(
        Exception e,
        Model model) {
        
        log.error("Unexpected error", e);
        model.addAttribute("error", "An unexpected error occurred");
        model.addAttribute("statusCode", 500);
        return "error/server-error";
    }
}
```

### 4. Thymeleaf View – List (books/list.html)

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org"
      xmlns:sec="http://www.thymeleaf.org/extras/spring-security">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Available Books</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .book-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 20px; }
        .book-card { border: 1px solid #ddd; padding: 15px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .book-card h3 { margin: 0 0 10px 0; }
        .book-card p { margin: 5px 0; color: #666; }
        .btn { display: inline-block; margin-top: 10px; padding: 8px 16px; background: #007bff; color: white; text-decoration: none; border-radius: 4px; }
        .btn:hover { background: #0056b3; }
        .error { background: #f8d7da; color: #721c24; padding: 12px; border-radius: 4px; margin-bottom: 20px; }
        .success { background: #d4edda; color: #155724; padding: 12px; border-radius: 4px; margin-bottom: 20px; }
        .pagination { margin-top: 30px; text-align: center; }
        .pagination a { margin: 0 5px; padding: 5px 10px; border: 1px solid #ddd; }
    </style>
</head>
<body>
    <h1>Available Books</h1>
    
    <!-- Success Message -->
    <div th:if="${success}" class="success" th:text="${success}"></div>
    
    <!-- Error Message -->
    <div th:if="${error}" class="error" th:text="${error}"></div>
    
    <!-- Create New Book Button -->
    <a href="/books/new" class="btn">Add New Book</a>
    
    <!-- Books Grid -->
    <div th:if="${books.isEmpty()}" style="margin-top: 20px;">
        <p>No books available at the moment.</p>
    </div>
    
    <div class="book-grid">
        <div th:each="book : ${books}" class="book-card">
            <h3 th:text="${book.title}"></h3>
            <p><strong>ISBN:</strong> <span th:text="${book.isbn}"></span></p>
            <p><strong>Pages:</strong> <span th:text="${book.pages}"></span></p>
            <p th:text="${book.description}" style="font-size: 0.9em; margin-top: 10px;"></p>
            <a th:href="@{/books/{id}(id=${book.id})}" class="btn">View Details</a>
        </div>
    </div>
    
    <!-- Pagination -->
    <div class="pagination">
        <a th:if="${currentPage > 0}" th:href="@{/books(page=${currentPage - 1}, size=${pageSize})}">Previous</a>
        <span th:text="'Page ' + ${currentPage + 1}"></span>
        <a th:if="${hasNext}" th:href="@{/books(page=${currentPage + 1}, size=${pageSize})}">Next</a>
    </div>
</body>
</html>
```

### 5. Thymeleaf View – Form (books/form.html)

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Create New Book</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 500px; margin: 40px auto; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input, textarea { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; font-family: Arial; }
        textarea { resize: vertical; min-height: 80px; }
        .error-message { color: #dc3545; font-size: 0.9em; margin-top: 5px; }
        .form-group.error input,
        .form-group.error textarea { border-color: #dc3545; background-color: #fff5f5; }
        .btn { padding: 12px 20px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 1em; }
        .btn:hover { background: #0056b3; }
        .btn-cancel { background: #6c757d; margin-left: 10px; }
        .btn-cancel:hover { background: #5a6268; }
    </style>
</head>
<body>
    <h1>Create New Book</h1>
    
    <form th:object="${form}" method="post" th:action="@{/books}">
        
        <!-- Title Field -->
        <div class="form-group" th:classappend="${#fields.hasErrors('title') ? 'error' : ''}">
            <label for="title">Title <span style="color: red;">*</span></label>
            <input type="text" id="title" th:field="*{title}" placeholder="Enter book title" />
            <span class="error-message" th:if="${#fields.hasErrors('title')}" th:errors="*{title}"></span>
        </div>
        
        <!-- ISBN Field -->
        <div class="form-group" th:classappend="${#fields.hasErrors('isbn') ? 'error' : ''}">
            <label for="isbn">ISBN (10 or 13 digits) <span style="color: red;">*</span></label>
            <input type="text" id="isbn" th:field="*{isbn}" placeholder="e.g., 978-3-16-148410" />
            <span class="error-message" th:if="${#fields.hasErrors('isbn')}" th:errors="*{isbn}"></span>
        </div>
        
        <!-- Description Field -->
        <div class="form-group" th:classappend="${#fields.hasErrors('description') ? 'error' : ''}">
            <label for="description">Description</label>
            <textarea id="description" th:field="*{description}" placeholder="Enter book description"></textarea>
            <span class="error-message" th:if="${#fields.hasErrors('description')}" th:errors="*{description}"></span>
        </div>
        
        <!-- Pages Field -->
        <div class="form-group" th:classappend="${#fields.hasErrors('pages') ? 'error' : ''}">
            <label for="pages">Pages <span style="color: red;">*</span></label>
            <input type="number" id="pages" th:field="*{pages}" min="1" placeholder="Number of pages" />
            <span class="error-message" th:if="${#fields.hasErrors('pages')}" th:errors="*{pages}"></span>
        </div>
        
        <!-- Owner ID Field (hidden or from session) -->
        <input type="hidden" th:field="*{ownerId}" />
        
        <!-- Buttons -->
        <div>
            <button type="submit" class="btn">Create Book</button>
            <a href="/books" class="btn btn-cancel">Cancel</a>
        </div>
    </form>
</body>
</html>
```

### 6. Error Pages

```html
<!-- error/not-found.html (404) -->
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Book Not Found</title>
    <style>
        body { font-family: Arial; text-align: center; margin-top: 50px; }
        .error-container { background: #f8d7da; color: #721c24; padding: 30px; border-radius: 8px; max-width: 500px; margin: 0 auto; }
        h1 { margin: 0 0 10px 0; }
        a { display: inline-block; margin-top: 20px; padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 4px; }
    </style>
</head>
<body>
    <div class="error-container">
        <h1>404 – Book Not Found</h1>
        <p th:text="${error}"></p>
        <a href="/books">Back to Books</a>
    </div>
</body>
</html>

<!-- error/server-error.html (500) -->
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Server Error</title>
    <style>
        body { font-family: Arial; text-align: center; margin-top: 50px; }
        .error-container { background: #f8d7da; color: #721c24; padding: 30px; border-radius: 8px; max-width: 500px; margin: 0 auto; }
        h1 { margin: 0 0 10px 0; }
        a { display: inline-block; margin-top: 20px; padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 4px; }
    </style>
</head>
<body>
    <div class="error-container">
        <h1>500 – Server Error</h1>
        <p>Something went wrong. Our team has been notified.</p>
        <a href="/books">Back to Home</a>
    </div>
</body>
</html>
```

### 7. Controller Tests

```java
// src/test/java/com/bookcycle/infrastructure/web/controllers/BookControllerTest
@WebMvcTest(BookController.class)
@DisplayName("BookController Tests")
class BookControllerTest {
    
    @MockBean
    private IBookService bookService;
    
    @Autowired
    private MockMvc mvc;
    
    @Test
    @DisplayName("should return list view with books")
    void shouldReturnListView() throws Exception {
        BookDTO book = BookDTO.builder()
            .id(1L)
            .title("Clean Code")
            .isbn("978-3-16-148410-0")
            .pages(464)
            .status("AVAILABLE")
            .build();
        
        when(bookService.getAllAvailableBooks(any())).thenReturn(List.of(book));
        
        mvc.perform(get("/books"))
            .andExpect(status().isOk())
            .andExpect(view().name("books/list"))
            .andExpect(model().attributeExists("books"))
            .andExpect(content().string(containsString("Clean Code")));
    }
    
    @Test
    @DisplayName("should return 404 when book not found")
    void shouldReturn404WhenNotFound() throws Exception {
        when(bookService.getBook(999L)).thenThrow(new BookNotFoundException(999L));
        
        mvc.perform(get("/books/999"))
            .andExpect(status().isOk())
            .andExpect(view().name("error/not-found"));
    }
    
    @Test
    @DisplayName("should create book on valid form submission")
    void shouldCreateBook() throws Exception {
        BookDTO created = BookDTO.builder()
            .id(1L)
            .title("Clean Code")
            .build();
        
        when(bookService.createBook(any())).thenReturn(created);
        
        mvc.perform(post("/books")
            .param("title", "Clean Code")
            .param("isbn", "978-3-16-148410-0")
            .param("pages", "464")
            .param("ownerId", "1"))
            .andExpect(status().is3xxRedirection())
            .andExpect(redirectedUrl("/books/1"));
    }
    
    @Test
    @DisplayName("should re-render form on validation error")
    void shouldReRenderOnValidationError() throws Exception {
        mvc.perform(post("/books")
            .param("title", "")  // Invalid: blank
            .param("isbn", "123")  // Invalid: wrong format
            .param("pages", "0"))  // Invalid: 0
            .andExpect(status().isOk())
            .andExpect(view().name("books/form"))
            .andExpect(model().attributeHasFieldErrors("form", "title", "isbn", "pages"));
    }
}
```

---

## 🔄 Qualitätskriterien

| Kriterium | Standard | Prüfung |
|-----------|----------|---------|
| **No Business Logic** | Controller nur routing/binding | Code Review |
| **Form Validation** | @Valid + BindingResult prüfen | Tests |
| **Error Handling** | GlobalExceptionHandler nutzen | Code Review |
| **Template Logic** | Nur Iteration/Condition, keine Logik | Code Review |
| **Logging** | INFO (requests), DEBUG (details) | Code Review |
| **Test Coverage** | 75%+ für Controller | SonarQube |
| **Redirect vs View** | POST-Redirect-GET Pattern | Code Review |

---

## 🔗 Abhängigkeiten

- ⚠️ Abhängig von: **Business Logic Agent** (Service-Implementation)
- Nutzt: DTO + Exception-Hierarchie aus Backend
- → Liefert: HTML Views + Forms für User

---

## 🚀 Execution Pattern

```bash
# 1. Konfiguration:
"Implementiere BookController mit List/Detail/Create Views"

# 2. Agent erstellt:
✅ BookController.java
✅ CreateBookForm.java
✅ GlobalExceptionHandler.java
✅ list.html, detail.html, form.html
✅ error/404.html, error/500.html
✅ BookControllerTest.java

# 3. Git Commit:
git commit -m "feat(web): add BookController with form handling"
```

---

**Nächster Schritt**: Beauftrage **Flutter Admin Agent** für API-Integration in Admin-Oberfläche.
