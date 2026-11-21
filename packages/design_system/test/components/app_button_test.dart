
import 'package:design_system/src/components/buttons/app_button.dart';
import 'package:design_system/src/components/buttons/app_button_size.dart';
import 'package:design_system/src/components/buttons/app_button_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppButton', () {
    testWidgets('renders label correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Sign in',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Continue',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Continue'));

      expect(tapped, isTrue);
    });

    testWidgets('does not call onPressed when disabled', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Disabled'));

      expect(tapped, isFalse);
    });

    testWidgets('shows loading indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Loading',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('supports all button types', (tester) async {
      for (final type in AppButtonType.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: 'Action',
                type: type,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Action'), findsOneWidget);
      }
    });

    testWidgets('supports all button sizes', (tester) async {
      for (final size in AppButtonSize.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: 'Action',
                size: size,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Action'), findsOneWidget);
      }
    });
  });
}
