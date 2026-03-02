import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/identity/data/user_repository.dart';
import 'features/marketplace/data/listing_repository.dart';
import 'features/marketplace/presentation/listing_providers.dart';
import 'features/communication/data/chat_repository.dart';
import 'features/communication/presentation/chat_providers.dart';
import 'features/trading/data/purchase_repository.dart';
import 'features/trading/presentation/purchase_providers.dart';
import 'features/moderation/data/report_repository.dart';
import 'features/moderation/presentation/report_providers.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/listing_detail_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/password_reset_screen.dart';
import 'screens/report_screen.dart';
import 'shared/providers.dart';
import 'theme/design_tokens.dart';

const bool useMockData =
    bool.fromEnvironment('BOOKCYCLE_MOCK_MODE', defaultValue: false);

void main() {
  final overrides = <Override>[
    userRepositoryProvider.overrideWithValue(
      useMockData
          ? MockUserRepository()
          : ApiUserRepository(baseUrl: 'http://localhost:8080/api/v1'),
    ),
    listingRepositoryProvider.overrideWithValue(
      useMockData
          ? MockListingRepository()
          : ApiListingRepository(baseUrl: 'http://localhost:8080/api/v1'),
    ),
    chatRepositoryProvider.overrideWithValue(
      useMockData
          ? MockChatRepository()
          : ApiChatRepository(baseUrl: 'http://localhost:8080/api/v1'),
    ),
    purchaseRepositoryProvider.overrideWithValue(
      useMockData
          ? MockPurchaseRepository()
          : ApiPurchaseRepository(baseUrl: 'http://localhost:8080/api/v1'),
    ),
    reportRepositoryProvider.overrideWithValue(
      useMockData
          ? MockReportRepository()
          : ApiReportRepository(baseUrl: 'http://localhost:8080/api/v1'),
    ),
  ];

  runApp(ProviderScope(overrides: overrides, child: const BookcycleApp()));
}

class BookcycleApp extends ConsumerWidget {
  const BookcycleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return MaterialApp(
      title: 'Bookcycle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: DesignTokens.primary,
          primary: DesignTokens.primary,
          surface: DesignTokens.surface,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: DesignTokens.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: DesignTokens.background,
          foregroundColor: DesignTokens.textPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: DesignTokens.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radius),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.md,
            vertical: 14,
          ),
          hintStyle: const TextStyle(color: DesignTokens.textMuted),
        ),
      ),
      home: userAsync.when(
        data: (user) => user != null ? const HomeScreen() : LoginScreen(),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => Scaffold(
          body: Center(child: Text('Error: $err')),
        ),
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/listing':
            return MaterialPageRoute(
                builder: (_) => const ListingDetailScreen(),
                settings: settings);
          case '/checkout':
            return MaterialPageRoute(
                builder: (_) => const CheckoutScreen(), settings: settings);
          case '/password-reset':
            return MaterialPageRoute(
                builder: (_) => PasswordResetScreen(), settings: settings);
          case '/create-account':
            return MaterialPageRoute(
                builder: (_) => const CreateAccountScreen(),
                settings: settings);
          case '/report':
            final args = settings.arguments as Map<String, String>;
            return MaterialPageRoute(
              builder: (_) => ReportScreen(
                targetId: args['targetId']!,
                targetType: args['targetType']!,
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}
