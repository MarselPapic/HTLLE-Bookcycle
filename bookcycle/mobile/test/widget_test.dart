import 'package:bookcycle_mobile/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders login screen in mock mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BookcycleApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Log In'), findsOneWidget);
  });
}
