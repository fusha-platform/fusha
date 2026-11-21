
import 'package:design_system/src/components/text_fields/app_password_field.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppPasswordField', () {
    testWidgets('hides password by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppPasswordField(),
          ),
        ),
      );

      final field = tester.widget<TextField>(
        find.byType(TextField),
      );

      expect(field.obscureText, isTrue);
      expect(
        find.byIcon(Icons.visibility_outlined),
        findsOneWidget,
      );
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppPasswordField(),
          ),
        ),
      );

      // Show password.
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      var field = tester.widget<TextField>(
        find.byType(TextField),
      );

      expect(field.obscureText, isFalse);
      expect(
        find.byIcon(Icons.visibility_off_outlined),
        findsOneWidget,
      );

      // Hide password again.
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      field = tester.widget<TextField>(
        find.byType(TextField),
      );

      expect(field.obscureText, isTrue);
      expect(
        find.byIcon(Icons.visibility_outlined),
        findsOneWidget,
      );
    });

    testWidgets('calls onChanged when password changes', (tester) async {
      String? value;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPasswordField(
              onChanged: (text) => value = text,
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField),
        'password123',
      );

      expect(value, 'password123');
    });

    testWidgets('renders custom label and hint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppPasswordField(
              label: 'كلمة المرور',
              hintText: 'أدخل كلمة المرور',
            ),
          ),
        ),
      );

      expect(find.text('كلمة المرور'), findsOneWidget);
      expect(find.text('أدخل كلمة المرور'), findsOneWidget);
    });

    testWidgets('respects enabled property', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppPasswordField(
              enabled: false,
            ),
          ),
        ),
      );

      final field = tester.widget<TextField>(
        find.byType(TextField),
      );

      expect(field.enabled, isFalse);
    });
  });
}
