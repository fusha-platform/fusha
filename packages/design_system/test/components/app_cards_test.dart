import 'package:design_system/src/components/cards/app_action_card.dart';
import 'package:design_system/src/components/cards/app_card.dart';
import 'package:design_system/src/components/cards/app_card_footer.dart';
import 'package:design_system/src/components/cards/app_card_header.dart';
import 'package:design_system/src/components/cards/app_card_type.dart';
import 'package:design_system/src/components/cards/app_info_card.dart';
import 'package:design_system/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(
      locale: const Locale('en'),
    ),
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  group('AppCard', () {
    testWidgets('renders child correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppCard(
            child: Text('Card Content'),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          AppCard(
            onTap: () => tapped = true,
            child: const Text('Tap Card'),
          ),
        ),
      );

      await tester.tap(find.text('Tap Card'));

      expect(tapped, isTrue);
    });

    testWidgets('does not respond when onTap is null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppCard(
            child: Text('Static Card'),
          ),
        ),
      );

      await tester.tap(find.text('Static Card'));

      expect(tester.takeException(), isNull);
    });

    testWidgets('supports outlined type', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppCard(
            type: AppCardType.outlined,
            child: Text('Outlined Card'),
          ),
        ),
      );

      expect(find.text('Outlined Card'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('supports elevated type', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppCard(
            type: AppCardType.elevated,
            child: Text('Elevated Card'),
          ),
        ),
      );

      expect(find.text('Elevated Card'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('supports custom padding', (tester) async {
      const padding = EdgeInsets.all(24);

      await tester.pumpWidget(
        buildTestWidget(
          const AppCard(
            padding: padding,
            child: Text('Custom Padding'),
          ),
        ),
      );

      final paddingWidget = tester.widget<Padding>(
        find.ancestor(
          of: find.text('Custom Padding'),
          matching: find.byType(Padding),
        ).first,
      );

      expect(paddingWidget.padding, padding);
    });
  });

  group('AppCardHeader', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppCardHeader(
            title: 'Users',
            subtitle: 'Manage application users',
          ),
        ),
      );

      expect(find.text('Users'), findsOneWidget);
      expect(find.text('Manage application users'), findsOneWidget);
    });

    testWidgets('renders icon and trailing widget', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppCardHeader(
            title: 'Users',
            icon: Icons.people,
            trailing: Icon(Icons.more_horiz),
          ),
        ),
      );

      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    });
  });

  group('AppCardFooter', () {
    testWidgets('renders footer content', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppCardFooter(
            child: Text('View Details'),
          ),
        ),
      );

      expect(find.text('View Details'), findsOneWidget);
    });
  });

  group('AppInfoCard', () {
    testWidgets('renders information correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppInfoCard(
            title: 'Total Users',
            value: '1,250',
            subtitle: '+12% this month',
            icon: Icons.people,
          ),
        ),
      );

      expect(find.text('Total Users'), findsOneWidget);
      expect(find.text('1,250'), findsOneWidget);
      expect(find.text('+12% this month'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('supports custom value color', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppInfoCard(
            title: 'Total Users',
            value: '1,250',
            valueColor: Colors.green,
          ),
        ),
      );

      final valueText = tester.widget<Text>(
        find.text('1,250'),
      );

      expect(valueText.style?.color, Colors.green);
    });
  });

  group('AppActionCard', () {
    testWidgets('renders title, description and icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppActionCard(
            title: 'Manage Users',
            description: 'View and manage accounts',
            icon: Icons.people,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Manage Users'), findsOneWidget);
      expect(find.text('View and manage accounts'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          AppActionCard(
            title: 'Manage Users',
            icon: Icons.people,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Manage Users'));

      expect(tapped, isTrue);
    });

    testWidgets('supports custom trailing widget', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppActionCard(
            title: 'Manage Users',
            icon: Icons.people,
            onTap: () {},
            trailing: const Icon(Icons.check_circle),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}