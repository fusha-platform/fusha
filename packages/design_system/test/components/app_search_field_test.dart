
import 'package:design_system/src/components/text_fields/app_search_field.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSearchField', () {
    testWidgets('renders search icon and hint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppSearchField(
              hintText: 'Search users...',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Search users...'), findsOneWidget);
    });

    testWidgets('shows clear button when text is entered', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppSearchField(),
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField),
        'Flutter',
      );

      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('clears text when clear button is tapped', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSearchField(
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField),
        'Flutter',
      );

      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      final field = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );

      expect(field.controller?.text, isEmpty);
      expect(changedValue, isEmpty);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('uses external controller', (tester) async {
      final controller = TextEditingController(text: 'Initial query');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSearchField(
              controller: controller,
            ),
          ),
        ),
      );

      expect(
        find.text('Initial query'),
        findsOneWidget,
      );

      expect(controller.text, 'Initial query');

      await tester.pumpWidget(const SizedBox());

      controller.dispose();
    });
  });
}
