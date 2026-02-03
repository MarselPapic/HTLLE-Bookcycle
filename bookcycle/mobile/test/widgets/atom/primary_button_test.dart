import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookcycle_mobile/widgets/atom/primary_button.dart';

void main() {
  testWidgets('PrimaryButton shows label and triggers onPressed', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            label: 'Submit',
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Submit'), findsOneWidget);
    await tester.tap(find.text('Submit'));
    expect(pressed, true);
  });
}

