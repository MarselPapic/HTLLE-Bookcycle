# 📦 UI-Component-Instructions für Flutter

## 1. Atomic Design Prinzipien

Flutter Components folgen dem **Atomic Design Pattern** für wartbare, wiederverwendbare UI-Bausteine.

### Komponenten-Hierarchie

```
Atoms (kleinste Bausteine)
├── PrimaryButton.dart
├── InputField.dart
├── Badge.dart
└── Icon.dart

Molecules (Kombinationen aus Atoms)
├── SearchBar.dart (InputField + Icon)
├── BookCard.dart (Image + Title + Badge)
└── UserProfile.dart (Avatar + Name + Status)

Organisms (Seiten-Komponenten)
├── BookListView.dart (Liste von BookCards)
├── BorrowHistory.dart (Molecule-Liste)
└── Navigation.dart (Bottom Nav + Drawer)

Templates (Page-Layouts)
├── AdminTemplate.dart (Layout mit Nav)
└── DetailTemplate.dart (Header + Content)

Pages (Komplette Screens)
├── BooksScreen.dart
├── BorrowScreen.dart
└── AdminPanel.dart
```

---

## 2. Isolierte Widget-Entwicklung (Storybook-Ansatz)

### Struktur für Widget-Tests

```dart
// lib/widgets/atoms/primary_button.dart
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}
```

### Widget Test Beispiel

```dart
// test/widgets/atoms/primary_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookcycle/widgets/atoms/primary_button.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('renders with label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Click Me',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('shows loading spinner when isLoading=true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Click Me',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Click Me'), findsNothing);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Click Me',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Click Me'));
      expect(pressed, true);
    });
  });
}
```

---

## 3. Barrierefreiheit & Responsive Design

### Accessibility Checklist

```dart
// ✅ Semantik & Screen Reader Support
Semantics(
  label: 'Buch-Titeltext',
  button: true,
  enabled: true,
  child: GestureDetector(
    onTap: onTap,
    child: Text(title),
  ),
)

// ✅ Contrast Ratio (WCAG AA: 4.5:1)
// Nutze Material Design 3 Color System
Color darkText = Color(0xFF212121);  // 21% Luminance
Color lightBg = Color(0xFFFFFFFF);   // Contrast: 21:1 ✓

// ✅ Touch Target Size (48x48dp minimum)
SizedBox(
  width: 48,
  height: 48,
  child: IconButton(
    icon: Icon(Icons.favorite),
    onPressed: toggleFavorite,
  ),
)

// ✅ Responsive Layout
LayoutBuilder(
  builder: (context, constraints) {
    bool isWide = constraints.maxWidth > 600;
    return isWide ? WideLayout() : NarrowLayout();
  },
)
```

### Material Design Guidelines
- **Button Height**: Minimum 48dp
- **Padding**: 16dp horizontal, 8dp vertical
- **Font Size**: Body 14sp, Headline 24sp+
- **Colors**: Use Material 3 color tokens (Material.useMaterial3 = true)

---

## 4. State Management mit Riverpod

### Component State Pattern

```dart
// ❌ FALSCH: State im Widget
class BookCardWidget extends StatefulWidget {
  @override
  State<BookCardWidget> createState() => _BookCardWidgetState();
}

// ✅ RICHTIG: State in Riverpod Provider

// lib/providers/book_provider.dart
import 'package:riverpod/riverpod.dart';
import 'package:bookcycle/models/book.dart';

final bookDetailsProvider = FutureProvider.family<Book, int>((ref, bookId) async {
  final api = ref.watch(bookApiProvider);
  return api.getBook(bookId);
});

final favoriteBookProvider = StateNotifierProvider<FavoriteBooksNotifier, List<int>>((ref) {
  return FavoriteBooksNotifier([]);
});

// lib/widgets/molecules/book_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookCard extends ConsumerWidget {
  final int bookId;

  const BookCard({required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(bookDetailsProvider(bookId));
    final favorites = ref.watch(favoriteBookProvider);

    return bookAsync.when(
      data: (book) => GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/book/${book.id}'),
        child: Card(
          child: Column(
            children: [
              Image.network(book.coverUrl),
              Text(book.title),
              IconButton(
                icon: Icon(
                  favorites.contains(bookId) ? Icons.favorite : Icons.favorite_border,
                ),
                onPressed: () {
                  ref.read(favoriteBookProvider.notifier).toggleFavorite(bookId);
                },
              ),
            ],
          ),
        ),
      ),
      loading: () => Skeleton(), // Placeholder
      error: (err, stack) => ErrorWidget(error: err),
    );
  }
}
```

### Riverpod Best Practices

```dart
// ✅ FutureProvider für Datenladung
final userProvider = FutureProvider<User>((ref) async {
  return api.fetchUser();
});

// ✅ StateNotifierProvider für Zustandsänderungen
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier(0);
});

// ✅ Dependency Injection
final apiProvider = Provider<BookAPI>((ref) {
  return BookAPI(baseUrl: 'http://localhost:8080');
});

// ❌ FALSCH: Globale Variablen
BookAPI api = BookAPI();  // NO!

// ❌ FALSCH: Riverpod außerhalb von ConsumerWidget
class MyWidget extends StatelessWidget {
  Widget build(context) {
    // Cannot use ref here!
  }
}
```

---

## 5. Mock-Integration für API-Testing

### Integration gegen API-Mocks

```dart
// test/widgets/molecules/book_card_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockBookAPI extends Mock implements BookAPI {}

void main() {
  group('BookCard', () {
    testWidgets('displays book details', (WidgetTester tester) async {
      final mockApi = MockBookAPI();
      
      // Mock API Response
      when(mockApi.getBook(1)).thenAnswer((_) async => Book(
        id: 1,
        title: 'Clean Code',
        author: 'Robert C. Martin',
        coverUrl: 'https://example.com/cover.jpg',
      ));

      // Override provider mit Mock
      await tester.pumpWidget(
        ProviderContainer(
          overrides: [
            bookApiProvider.overrideWithValue(mockApi),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BookCard(bookId: 1),
            ),
          ),
        ).listen(ProviderContainer).build(context),
      );

      expect(find.text('Clean Code'), findsOneWidget);
      expect(find.text('Robert C. Martin'), findsOneWidget);
    });

    testWidgets('shows loading state', (WidgetTester tester) async {
      final mockApi = MockBookAPI();
      
      // Simulate loading delay
      when(mockApi.getBook(1)).thenAnswer((_) => 
        Future.delayed(Duration(seconds: 2), () => Book(...))
      );

      await tester.pumpWidget(...);
      
      // Before data loaded
      expect(find.byType(Skeleton), findsOneWidget);
      
      // After data loaded
      await tester.pumpAndSettle();
      expect(find.text('Clean Code'), findsOneWidget);
    });

    testWidgets('shows error state on API failure', (WidgetTester tester) async {
      final mockApi = MockBookAPI();
      
      when(mockApi.getBook(1)).thenThrow(Exception('API Error'));

      await tester.pumpWidget(...);
      await tester.pumpAndSettle();
      
      expect(find.byType(ErrorWidget), findsOneWidget);
    });
  });
}
```

### Vorbereitung für Codegenerierung aus OpenAPI

```dart
// lib/models/book.dart (wird von OpenAPI Generator erstellt)
import 'package:freezed_annotation/freezed_annotation.dart';

part 'book.freezed.dart';
part 'book.g.dart';

@freezed
class Book with _$Book {
  const factory Book({
    required int id,
    required String title,
    required String author,
    required String isbn,
    required String coverUrl,
    required int pages,
    @Default(BookStatus.AVAILABLE) BookStatus status,
  }) = _Book;

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
}

enum BookStatus {
  @JsonValue('AVAILABLE')
  AVAILABLE,
  @JsonValue('BORROWED')
  BORROWED,
  @JsonValue('RETIRED')
  RETIRED,
}
```

---

## 6. Component Library Organisation

### Dateistruktur

```
lib/
├── widgets/
│   ├── atoms/
│   │   ├── primary_button.dart
│   │   ├── input_field.dart
│   │   ├── badge.dart
│   │   └── atoms.dart (export all)
│   │
│   ├── molecules/
│   │   ├── book_card.dart
│   │   ├── search_bar.dart
│   │   ├── user_profile.dart
│   │   └── molecules.dart (export all)
│   │
│   ├── organisms/
│   │   ├── book_list_view.dart
│   │   ├── navigation_bar.dart
│   │   └── organisms.dart (export all)
│   │
│   └── templates/
│       ├── admin_template.dart
│       └── templates.dart
│
├── screens/
│   ├── books_screen.dart
│   ├── borrow_screen.dart
│   └── admin_screen.dart
│
└── theme/
    ├── colors.dart
    ├── typography.dart
    └── theme.dart
```

### Zentrales Export-System

```dart
// lib/widgets/atoms/atoms.dart
export 'primary_button.dart';
export 'input_field.dart';
export 'badge.dart';

// lib/widgets/molecules/molecules.dart
export 'book_card.dart';
export 'search_bar.dart';
export 'user_profile.dart';

// lib/widgets/widgets.dart
export 'atoms/atoms.dart';
export 'molecules/molecules.dart';
export 'organisms/organisms.dart';
export 'templates/templates.dart';

// In screens: nur ein Import!
import 'package:bookcycle/widgets/widgets.dart';
```

---

## 7. Design Tokens Integration

```dart
// lib/theme/design_tokens.dart
import 'package:flutter/material.dart';

class DesignTokens {
  // Spacing
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;

  // Colors (aus docs/shared-resources/design-tokens/)
  static const primary = Color(0xFF2196F3);
  static const secondary = Color(0xFF03DAC6);
  static const error = Color(0xFFB00020);
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);

  // Typography
  static const headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  );

  // Border Radius
  static const borderRadius = 8.0;
  static const borderRadiusLarge = 12.0;

  // Shadows
  static const elevation1 = BoxShadow(
    color: Colors.black12,
    blurRadius: 2,
    offset: Offset(0, 1),
  );
}

// Verwendung in Widgets
class PrimaryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignTokens.primary,
        padding: EdgeInsets.all(DesignTokens.md),
      ),
      child: Text(
        'Submit',
        style: DesignTokens.body,
      ),
    );
  }
}
```

---

## 8. Testing Checklist

Vor jeden Component-Merge in `main`:

- [ ] **Widget-Struktur**: Component rendert ohne Fehler
- [ ] **Styling**: Layout entspricht Design Tokens
- [ ] **Interaktivität**: Alle Buttons/Eingaben funktionieren
- [ ] **Barrierefreiheit**: Semantik + Touch-Targets vorhanden
- [ ] **Responsive**: Layout passt sich an (Portrait/Landscape)
- [ ] **Error States**: Loading/Error/Empty States funktionieren
- [ ] **API Integration**: Mock-Daten laden korrekt
- [ ] **Performance**: Keine jank, <16ms frame time
- [ ] **Code Coverage**: Min. 80% für Atoms, 70% für Molecules

```bash
# Local testing vor Push
flutter test test/widgets/ --coverage
lcov --summary coverage/lcov.info

# Check coverage
coverage_badge=$(cat coverage/lcov.info | grep "end_of_record" -c)
if [ "$coverage_badge" -lt 80 ]; then
  echo "Coverage zu niedrig!"
  exit 1
fi
```

---

## 9. Component Documentation

Jede Komponente benötigt README:

```markdown
# BookCard

## Purpose
Zeigt Buch-Info als wiederverwendbare Card in Listen/Grids.

## Props
- `bookId` (int, required): ID für API-Fetch
- `onTap` (VoidCallback): Handler beim Tappen

## States
- **Loading**: Skeleton während API-Fetch
- **Data**: Card mit Buch-Details + Favorite-Button
- **Error**: Error-Message mit Retry-Button

## Example
```dart
BookCard(bookId: 1, onTap: () => navigate())
```

## Testing
Siehe `test/widgets/molecules/book_card_test.dart` für:
- Data-State
- Loading-State
- Error-State
- Interaction

---

## 10. CI/CD für Flutter Components

Im `.github/workflows/ci.yml` bereits integriert:

```yaml
- name: Flutter Analyze
  run: flutter analyze lib/widgets/
  
- name: Flutter Test
  run: flutter test test/widgets/ --coverage
  
- name: Check Coverage
  run: |
    coverage=$(lcov --summary coverage/lcov.info | grep "lines" | awk '{print $NF}')
    if (( $(echo "$coverage < 80" | bc -l) )); then
      echo "Coverage $coverage% < 80%"
      exit 1
    fi
```

---

**Wichtig**: Alle Components sind isoliert testbar und folgen OpenAPI-DTOs für Datenstrukturen!

