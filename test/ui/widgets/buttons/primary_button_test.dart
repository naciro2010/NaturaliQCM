import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturaliqcm/ui/widgets/buttons/primary_button.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('renders with label', (WidgetTester tester) async {
      const label = 'Test Button';
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(label: label, onPressed: () => pressed = true),
          ),
        ),
      );

      expect(find.text(label), findsOneWidget);
      expect(pressed, isFalse);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(label: 'Test', onPressed: () => pressed = true),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isTrue);
    });

    testWidgets('shows loading indicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Test',
              onPressed: null,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('disables button when isLoading is true', (
      WidgetTester tester,
    ) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Test',
              onPressed: () => pressed = true,
              isLoading: true,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      expect(pressed, isFalse);
    });

    testWidgets('renders with icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Test',
              onPressed: () {},
              icon: Icons.check,
            ),
          ),
        ),
      );

      // Find the Icon widget within the button
      final iconFinder = find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.byType(Icon),
      );
      expect(iconFinder, findsOneWidget);

      // Verify the icon data
      final Icon iconWidget = tester.widget(iconFinder);
      expect(iconWidget.icon, equals(Icons.check));
    });

    testWidgets('respects fullWidth parameter', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PrimaryButton(
                  label: 'Full Width',
                  onPressed: () {},
                  fullWidth: true,
                ),
                PrimaryButton(
                  label: 'Not Full Width',
                  onPressed: () {},
                  fullWidth: false,
                ),
              ],
            ),
          ),
        ),
      );

      final fullWidthContainer = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.text('Full Width'),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(fullWidthContainer.width, equals(double.infinity));

      // The non-full-width button should not be wrapped in a SizedBox with infinite width
      expect(
        find.ancestor(
          of: find.text('Not Full Width'),
          matching: find.byWidgetPredicate(
            (widget) => widget is SizedBox && widget.width == double.infinity,
          ),
        ),
        findsNothing,
      );
    });
  });
}
