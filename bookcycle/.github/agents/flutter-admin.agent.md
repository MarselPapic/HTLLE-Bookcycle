# Agent: Flutter Admin Frontend

**Rolle**: Mobile/Admin UI Architect – Flutter State & API  
**Fokus**: REST Integration, State Management, Widget Architecture  
**Sprache**: Dart/Flutter 3.x  
**State Framework**: Riverpod  
**Status**: Production Ready

---

## 🎯 Verantwortungsbereich

Dieser Agent ist verantwortlich für:

1. **REST API Integration**
   - HTTP-Client Wrapper
   - Error Handling & Retries
   - Request/Response Mapping
   - Timeout Management

2. **State Management (Riverpod)**
   - FutureProvider für async data
   - StateNotifier für mutable state
   - Dependency Injection via Providers
   - Refresh & Invalidation

3. **Widget Architecture**
   - Separation of Concerns (UI/State/Data)
   - Error/Loading/Success States
   - Form Handling
   - Navigation

4. **Data Models (DTOs)**
   - Backend-Alignment
   - Serialization/Deserialization
   - Null Safety
   - Immutability (freezed/built_value)

---

## 📥 Inputs vom Team

```markdown
### User Story:
**Story**: "As admin, I want to see a list of all books and filter by status"

### Requirements:
- [ ] GET /api/books (with pagination)
- [ ] GET /api/books?status=AVAILABLE
- [ ] Display loading state
- [ ] Handle errors with retry
- [ ] Paginate with next/prev buttons
```

---

## 📤 Outputs

### 1. Data Model (DTO)

```dart
// lib/data/models/book_dto.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_dto.freezed.dart';
part 'book_dto.g.dart';

@freezed
class BookDTO with _$BookDTO {
  const factory BookDTO({
    required int id,
    required String isbn,
    required String title,
    String? description,
    required int pages,
    required String status,
    required int ownerId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _BookDTO;

  factory BookDTO.fromJson(Map<String, dynamic> json) =>
      _$BookDTOFromJson(json);
}

@freezed
class CreateBookDTO with _$CreateBookDTO {
  const factory CreateBookDTO({
    required String isbn,
    required String title,
    String? description,
    required int pages,
    required int ownerId,
  }) = _CreateBookDTO;

  Map<String, dynamic> toJson() => _$CreateBookDTOToJson(this);
}

// lib/domain/models/book.dart
enum BookStatus {
  available('AVAILABLE', 'Available'),
  borrowed('BORROWED', 'Borrowed'),
  lost('LOST', 'Lost'),
  retired('RETIRED', 'Retired');

  final String code;
  final String label;

  const BookStatus(this.code, this.label);

  factory BookStatus.fromCode(String code) =>
      values.firstWhere((e) => e.code == code);
}
```

### 2. API Datasource

```dart
// lib/data/datasources/book_api.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (${statusCode ?? 'unknown'})';
}

class BookAPI {
  final http.Client httpClient;
  final String baseUrl;

  BookAPI({
    required this.httpClient,
    required this.baseUrl,
  });

  Future<List<BookDTO>> fetchBooks({
    int page = 0,
    int size = 10,
    String? status,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/books')
          .replace(queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
        if (status != null) 'status': status,
      });

      final response = await httpClient.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw ApiException('Request timeout'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BookDTO.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw ApiException('Books not found', statusCode: 404);
      } else {
        throw ApiException(
          'Failed to fetch books',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<BookDTO> fetchBook(int id) async {
    try {
      final response = await httpClient
          .get(Uri.parse('$baseUrl/api/books/$id'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return BookDTO.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw ApiException('Book not found', statusCode: 404);
      } else {
        throw ApiException('Failed to fetch book',
            statusCode: response.statusCode);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<BookDTO> createBook(CreateBookDTO dto) async {
    try {
      final response = await httpClient
          .post(
            Uri.parse('$baseUrl/api/books'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(dto.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return BookDTO.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException('Failed to create book',
            statusCode: response.statusCode);
      }
    } catch (e) {
      rethrow;
    }
  }
}
```

### 3. Repository

```dart
// lib/data/repositories/book_repository.dart
class BookRepository {
  final BookAPI api;

  BookRepository({required this.api});

  Future<List<BookDTO>> getBooks({
    int page = 0,
    int size = 10,
    String? status,
  }) =>
      api.fetchBooks(page: page, size: size, status: status);

  Future<BookDTO> getBook(int id) => api.fetchBook(id);

  Future<BookDTO> createBook(CreateBookDTO dto) => api.createBook(dto);
}
```

### 4. State Management (Riverpod)

```dart
// lib/presentation/state/book_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// API Provider
final bookAPIProvider = Provider<BookAPI>((ref) {
  return BookAPI(
    httpClient: http.Client(),
    baseUrl: 'http://localhost:8080',
  );
});

// Repository Provider
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository(api: ref.watch(bookAPIProvider));
});

// List State Management
final currentPageProvider = StateProvider<int>((ref) => 0);
final pageSizeProvider = StateProvider<int>((ref) => 10);
final bookStatusFilterProvider = StateProvider<String?>((ref) => null);

// Books List FutureProvider
final booksProvider = FutureProvider<List<BookDTO>>((ref) async {
  final repo = ref.watch(bookRepositoryProvider);
  final page = ref.watch(currentPageProvider);
  final size = ref.watch(pageSizeProvider);
  final status = ref.watch(bookStatusFilterProvider);

  return repo.getBooks(page: page, size: size, status: status);
});

// Single Book Detail Provider
final bookDetailProvider = FutureProvider.family<BookDTO, int>((ref, id) async {
  final repo = ref.watch(bookRepositoryProvider);
  return repo.getBook(id);
});

// Create Book State
class CreateBookState {
  final bool isLoading;
  final String? error;
  final BookDTO? created;

  CreateBookState({
    this.isLoading = false,
    this.error,
    this.created,
  });

  CreateBookState copyWith({
    bool? isLoading,
    String? error,
    BookDTO? created,
  }) =>
      CreateBookState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        created: created ?? this.created,
      );
}

final createBookProvider =
    StateNotifierProvider<CreateBookNotifier, CreateBookState>((ref) {
  return CreateBookNotifier(ref.watch(bookRepositoryProvider));
});

class CreateBookNotifier extends StateNotifier<CreateBookState> {
  final BookRepository _repo;

  CreateBookNotifier(this._repo) : super(CreateBookState());

  Future<void> createBook(CreateBookDTO dto) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final created = await _repo.createBook(dto);
      state = state.copyWith(isLoading: false, created: created);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
```

### 5. Widget Screens

```dart
// lib/presentation/screens/book_list_screen.dart
class BookListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsyncValue = ref.watch(booksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(booksProvider),
          ),
        ],
      ),
      body: booksAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(context, error, ref),
        data: (books) => _buildBooksList(books, context, ref),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreate(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, Object error, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(booksProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksList(
    List<BookDTO> books,
    BuildContext context,
    WidgetRef ref,
  ) {
    return books.isEmpty
        ? const Center(
            child: Text('No books available'),
          )
        : ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) => BookCard(
              book: books[index],
              onTap: () => _navigateToDetail(context, books[index].id),
            ),
          );
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateBookScreen()),
    );
  }

  void _navigateToDetail(BuildContext context, int id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: id)),
    );
  }
}

// lib/presentation/widgets/book_card.dart
class BookCard extends StatelessWidget {
  final BookDTO book;
  final VoidCallback onTap;

  const BookCard({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(book.title),
        subtitle: Text('ISBN: ${book.isbn}'),
        trailing: Chip(
          label: Text(book.status),
          backgroundColor: _getStatusColor(book.status),
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getStatusColor(String status) {
    return switch (status) {
      'AVAILABLE' => Colors.green,
      'BORROWED' => Colors.orange,
      'LOST' => Colors.red,
      'RETIRED' => Colors.grey,
      _ => Colors.blue,
    };
  }
}

// lib/presentation/screens/create_book_screen.dart
class CreateBookScreen extends ConsumerStatefulWidget {
  const CreateBookScreen();

  @override
  ConsumerState<CreateBookScreen> createState() => _CreateBookScreenState();
}

class _CreateBookScreenState extends ConsumerState<CreateBookScreen> {
  late TextEditingController titleController;
  late TextEditingController isbnController;
  late TextEditingController pagesController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    isbnController = TextEditingController();
    pagesController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    isbnController.dispose();
    pagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createBookProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: isbnController,
              decoration: const InputDecoration(
                labelText: 'ISBN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pagesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Pages',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            if (createState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Error: ${createState.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton.icon(
              onPressed: createState.isLoading ? null : _createBook,
              icon: createState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(createState.isLoading ? 'Creating...' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBook() async {
    final dto = CreateBookDTO(
      isbn: isbnController.text,
      title: titleController.text,
      pages: int.tryParse(pagesController.text) ?? 0,
      ownerId: 1, // From authenticated user
    );

    await ref.read(createBookProvider.notifier).createBook(dto);

    if (mounted && ref.read(createBookProvider).created != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book created successfully')),
      );
      Navigator.pop(context);
      ref.refresh(booksProvider);
    }
  }
}
```

### 6. Widget Tests

```dart
// test/presentation/screens/book_list_screen_test.dart
void main() {
  group('BookListScreen', () {
    testWidgets('should display loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          overrides: [
            booksProvider.overrideWith((ref) async {
              await Future.delayed(const Duration(seconds: 1));
              return [];
            }),
          ],
          child: MaterialApp(home: BookListScreen()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display books list', (WidgetTester tester) async {
      final books = [
        BookDTO(
          id: 1,
          isbn: '978-3-16-148410-0',
          title: 'Clean Code',
          pages: 464,
          status: 'AVAILABLE',
          ownerId: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderContainer(
          overrides: [
            booksProvider.overrideWithValue(AsyncValue.data(books)),
          ],
          child: MaterialApp(home: BookListScreen()),
        ),
      );

      expect(find.text('Clean Code'), findsOneWidget);
      expect(find.byType(BookCard), findsWidgets);
    });

    testWidgets('should display error state with retry', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          overrides: [
            booksProvider.overrideWithValue(
              AsyncValue.error(ApiException('Network error'), StackTrace.current),
            ),
          ],
          child: MaterialApp(home: BookListScreen()),
        ),
      );

      expect(find.byType(Icon), findsWidgets); // Error icon
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
```

### 7. pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  
  # HTTP & Serialization
  http: ^1.1.0
  json_serializable: ^6.7.0
  freezed_annotation: ^2.4.0
  
  # UI
  material_design_icons_flutter: ^7.0.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
```

---

## 🔄 Qualitätskriterien

| Kriterium | Standard | Prüfung |
|-----------|----------|---------|
| **No API Calls in UI** | Nur über Providers | Code Review |
| **Error States** | Loading/Error/Success explizit | Code Review |
| **DTOs Aligned** | Exakt mit Backend-DTOs | Code Review |
| **Immutability** | freezed oder final fields | Code Review |
| **Test Coverage** | 60%+ für Widgets | CI/CD |
| **Null Safety** | 100% null-safe code | Analyzer |
| **Performance** | Keine rebuilds von ganzen Trees | Code Review |

---

## 🔗 Abhängigkeiten

- ⚠️ Abhängig von: **Spring Boot REST API** (Backend)
- Nutzt: DTO-Struktur + Exception-Handling von Backend
- → Unabhängig von: Web Frontend (parallele Entwicklung möglich)

---

## 🚀 Execution Pattern

```bash
# 1. Konfiguration:
"Implementiere Flutter Admin UI für Book Management"

# 2. Agent erstellt:
✅ book_dto.dart (mit freezed)
✅ book_api.dart (REST-Client)
✅ book_repository.dart
✅ book_provider.dart (Riverpod State)
✅ book_list_screen.dart
✅ create_book_screen.dart
✅ book_card.dart Widget
✅ book_list_screen_test.dart

# 3. pubspec.yaml aktualisieren
# 4. flutter pub get

# 5. Git Commit:
git commit -m "feat(admin): add Flutter book management screens"
```

---

**Nächster Schritt**: Beauftrage **Project Manager Agent** für User Story Refinement.
