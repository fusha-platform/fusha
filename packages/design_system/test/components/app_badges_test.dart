import 'package:design_system/src/components/badges/app_badge.dart';
import 'package:design_system/src/components/badges/app_badge_type.dart';
import 'package:design_system/src/components/badges/app_notification_badge.dart';
import 'package:design_system/src/components/badges/app_status_badge.dart';
import 'package:design_system/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(locale: const Locale('en')),
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  group('AppBadge', () {
    testWidgets('renders label correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const AppBadge(label: 'New')),
      );

      expect(find.text('New'), findsOneWidget);
    });

    testWidgets('renders optional icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppBadge(
            label: 'Verified',
            icon: Icons.check_circle,
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('supports all badge types', (tester) async {
      for (final type in AppBadgeType.values) {
        await tester.pumpWidget(
          buildTestWidget(
            AppBadge(
              label: type.name,
              type: type,
            ),
          ),
        );

        expect(find.text(type.name), findsOneWidget);
      }
    });

    testWidgets('supports custom colors', (tester) async {
      const background = Colors.black;
      const foreground = Colors.white;

      await tester.pumpWidget(
        buildTestWidget(
          const AppBadge(
            label: 'Custom',
            backgroundColor: background,
            foregroundColor: foreground,
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppBadge),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration! as BoxDecoration;

      expect(decoration.color, background);

      final text = tester.widget<Text>(find.text('Custom'));
      expect(text.style?.color, foreground);
    });

    testWidgets('uses neutral type by default', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const AppBadge(label: 'Default')),
      );

      expect(find.text('Default'), findsOneWidget);
    });
  });

  group('AppStatusBadge', () {
    testWidgets('renders status label', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppStatusBadge(
            label: 'Active',
            status: AppStatus.active,
          ),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('supports all status types', (tester) async {
      for (final status in AppStatus.values) {
        await tester.pumpWidget(
          buildTestWidget(
            AppStatusBadge(
              label: status.name,
              status: status,
            ),
          ),
        );

        expect(find.text(status.name), findsOneWidget);
      }
    });

    testWidgets('renders optional icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppStatusBadge(
            label: 'Completed',
            status: AppStatus.completed,
            icon: Icons.done,
          ),
        ),
      );

      expect(find.byIcon(Icons.done), findsOneWidget);
    });
  });

  group('AppNotificationBadge', () {
    testWidgets('renders child correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppNotificationBadge(
            count: 3,
            child: Icon(Icons.notifications),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('renders notification count', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppNotificationBadge(
            count: 5,
            child: Icon(Icons.notifications),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('hides badge when count is zero', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppNotificationBadge(
            count: 0,
            child: Icon(Icons.notifications),
          ),
        ),
      );

      expect(find.text('0'), findsNothing);
    });

    testWidgets('shows zero when showZero is true', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppNotificationBadge(
            count: 0,
            showZero: true,
            child: Icon(Icons.notifications),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('limits count to maxCount', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppNotificationBadge(
            count: 120,
            maxCount: 99,
            child: Icon(Icons.notifications),
          ),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('supports custom maxCount', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppNotificationBadge(
            count: 15,
            maxCount: 9,
            child: Icon(Icons.notifications),
          ),
        ),
      );

      expect(find.text('9+'), findsOneWidget);
    });
  });
}