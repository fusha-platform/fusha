import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:design_system/src/components/dialogs/app_alert_dialog.dart';
import 'package:design_system/src/components/dialogs/app_confirm_dialog.dart';
import 'package:design_system/src/components/dialogs/app_dialog.dart';
import 'package:design_system/src/components/dialogs/app_dialog_actions.dart';
import 'package:design_system/src/components/dialogs/app_dialog_type.dart';
import 'package:design_system/src/theme/app_theme.dart';

Widget _buildTestApp({
  required Widget child,
}) {
  return MaterialApp(
    theme: AppTheme.light(locale: const Locale('en')),
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

void main() {
  group('AppDialog', () {
    testWidgets('renders title and description', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const AppDialog(
            title: 'Dialog title',
            description: 'Dialog description',
          ),
        ),
      );

      expect(find.text('Dialog title'), findsOneWidget);
      expect(find.text('Dialog description'), findsOneWidget);
    });

    testWidgets('renders the close button when enabled', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const AppDialog(
            title: 'Dialog title',
            showCloseButton: true,
          ),
        ),
      );

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('renders content and actions', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: AppDialog(
            title: 'Dialog title',
            content: const Text('Custom content'),
            actions: const Text('Custom actions'),
          ),
        ),
      );

      expect(find.text('Custom content'), findsOneWidget);
      expect(find.text('Custom actions'), findsOneWidget);
    });

    testWidgets('renders different dialog types', (tester) async {
      for (final type in AppDialogType.values) {
        await tester.pumpWidget(
          _buildTestApp(
            child: AppDialog(
              title: 'Dialog title',
              type: type,
            ),
          ),
        );

        expect(find.text('Dialog title'), findsOneWidget);
      }
    });
  });

  group('AppDialogActions', () {
    testWidgets('renders primary action', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: AppDialogActions(
            primaryLabel: 'Continue',
            onPrimaryPressed: () {},
          ),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('renders primary and secondary actions', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: AppDialogActions(
            primaryLabel: 'Confirm',
            secondaryLabel: 'Cancel',
            onPrimaryPressed: () {},
            onSecondaryPressed: () {},
          ),
        ),
      );

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('calls primary callback when tapped', (tester) async {
      var isPressed = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: AppDialogActions(
            primaryLabel: 'Confirm',
            onPrimaryPressed: () => isPressed = true,
          ),
        ),
      );

      await tester.tap(find.text('Confirm'));
      await tester.pump();

      expect(isPressed, isTrue);
    });

    testWidgets('calls secondary callback when tapped', (tester) async {
      var isPressed = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: AppDialogActions(
            primaryLabel: 'Confirm',
            secondaryLabel: 'Cancel',
            onPrimaryPressed: () {},
            onSecondaryPressed: () => isPressed = true,
          ),
        ),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(isPressed, isTrue);
    });
  });

  group('AppAlertDialog', () {
    testWidgets('shows alert and returns true on confirmation', (
        tester,
        ) async {
      bool? result;

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await AppAlertDialog.show(
                    context: context,
                    title: 'Success',
                    message: 'Your changes were saved.',
                    type: AppDialogType.success,
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Your changes were saved.'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });
  });

  group('AppConfirmDialog', () {
    testWidgets('returns true when confirmed', (tester) async {
      bool? result;

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await AppConfirmDialog.show(
                    context: context,
                    title: 'Delete item?',
                    message: 'This action cannot be undone.',
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Delete item?'), findsOneWidget);
      expect(find.text('This action cannot be undone.'), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('returns false when cancelled', (tester) async {
      bool? result;

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await AppConfirmDialog.show(
                    context: context,
                    title: 'Confirm action',
                    message: 'Are you sure?',
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('renders destructive confirmation', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AppConfirmDialog.show(
                    context: context,
                    title: 'Delete account',
                    message: 'Are you sure?',
                    isDestructive: true,
                    type: AppDialogType.error,
                    confirmLabel: 'Delete',
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Delete account'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
  });
}