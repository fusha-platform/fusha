
import 'package:design_system/src/components/text_fields/app_text_field.dart';
import 'package:design_system/src/components/text_fields/app_text_field_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTextField', () {
    testWidgets('renders label and hint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              label: 'Email',
              hintText: 'Enter your email',
            ),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? value;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              onChanged: (text) => value = text,
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField),
        'test@example.com',
      );

      expect(value, 'test@example.com');
    });

    testWidgets('supports email keyboard type', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              type: AppTextFieldType.email,
            ),
          ),
        ),
      );

      final field = tester.widget<TextField>(
        find.byType(TextField),
      );

      expect(field.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('supports multiline input', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              type: AppTextFieldType.multiline,
            ),
          ),
        ),
      );

      final field = tester.widget<TextField>(
        find.byType(TextField),
      );

      expect(field.maxLines, isNull);
      expect(field.minLines, 3);
    });

    testWidgets('supports obscure text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              obscureText: true,
            ),
          ),
        ),
      );

      final field = tester.widget<TextField>(
        find.byType(TextField),
      );

      expect(field.obscureText, isTrue);
    });

    testWidgets('does not obscure text by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(),
          ),
        ),
      );

      final field = tester.widget<TextField>(
        find.byType(TextField),
      );

      expect(field.obscureText, isFalse);
    });

    testWidgets('can be disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
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
