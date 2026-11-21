import 'package:design_system/src/components/navigation/app_bottom_navigation_bar.dart';
import 'package:design_system/src/components/navigation/app_breadcrumb.dart';
import 'package:design_system/src/components/navigation/app_navigation_bar.dart';
import 'package:design_system/src/components/navigation/app_navigation_item.dart';
import 'package:design_system/src/components/navigation/app_navigation_rail.dart';
import 'package:design_system/src/components/navigation/app_tab_bar.dart';
import 'package:design_system/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final items = [
    const AppNavigationItem(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    const AppNavigationItem(
      label: 'Search',
      icon: Icons.search,
    ),
    const AppNavigationItem(
      label: 'Profile',
      icon: Icons.person_outline,
    ),
  ];

  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(locale: const Locale('en')),
      home: Scaffold(body: child),
    );
  }

  group('AppBottomNavigationBar', () {
    testWidgets('renders all navigation labels', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppBottomNavigationBar(
            items: items,
            selectedIndex: 0,
            onItemSelected: (_) {},
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('renders selected icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppBottomNavigationBar(
            items: items,
            selectedIndex: 0,
            onItemSelected: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('calls callback with selected index', (tester) async {
      int? selectedIndex;

      await tester.pumpWidget(
        buildTestWidget(
          AppBottomNavigationBar(
            items: items,
            selectedIndex: 0,
            onItemSelected: (index) => selectedIndex = index,
          ),
        ),
      );

      await tester.tap(find.text('Search'));
      expect(selectedIndex, 1);
    });

    testWidgets('can hide labels', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppBottomNavigationBar(
            items: items,
            selectedIndex: 0,
            onItemSelected: (_) {},
            showLabels: false,
          ),
        ),
      );

      expect(find.text('Home'), findsNothing);
    });
  });

  group('AppNavigationBar', () {
    testWidgets('renders all destinations', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppNavigationBar(
            items: items,
            selectedIndex: 0,
            onItemSelected: (_) {},
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('calls callback when destination is selected', (
        tester,
        ) async {
      int? selectedIndex;

      await tester.pumpWidget(
        buildTestWidget(
          AppNavigationBar(
            items: items,
            selectedIndex: 0,
            onItemSelected: (index) => selectedIndex = index,
          ),
        ),
      );

      await tester.tap(find.text('Search'));
      expect(selectedIndex, 1);
    });

    testWidgets('renders selected icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppNavigationBar(
            items: items,
            selectedIndex: 0,
            onItemSelected: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
    });
  });

  group('AppNavigationRail', () {
    testWidgets('renders all destinations', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          Row(
            children: [
              AppNavigationRail(
                items: items,
                selectedIndex: 0,
                onItemSelected: (_) {},
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('calls callback when destination is selected', (
        tester,
        ) async {
      int? selectedIndex;

      await tester.pumpWidget(
        buildTestWidget(
          Row(
            children: [
              AppNavigationRail(
                items: items,
                selectedIndex: 0,
                onItemSelected: (index) => selectedIndex = index,
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Search'));
      expect(selectedIndex, 1);
    });

    testWidgets('supports extended mode', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          Row(
            children: [
              AppNavigationRail(
                items: items,
                selectedIndex: 0,
                onItemSelected: (_) {},
                extended: true,
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );

      final rail = tester.widget<NavigationRail>(
        find.byType(NavigationRail),
      );

      expect(rail.extended, isTrue);
    });
  });

  group('AppTabBar', () {
    testWidgets('renders all tabs', (tester) async {
      late TabController controller;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(locale: const Locale('en')),
          home: DefaultTabController(
            length: 2,
            child: Builder(
              builder: (context) {
                controller = DefaultTabController.of(context);

                return Scaffold(
                  appBar: AppBar(
                    bottom: AppTabBar(
                      controller: controller,
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Details'),
                      ],
                    ),
                  ),
                  body: const TabBarView(
                    children: [
                      Text('Overview content'),
                      Text('Details content'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets('changes tab when tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(locale: const Locale('en')),
          home: DefaultTabController(
            length: 2,
            child: Builder(
              builder: (context) {
                final controller = DefaultTabController.of(context);

                return Scaffold(
                  appBar: AppBar(
                    bottom: AppTabBar(
                      controller: controller,
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Details'),
                      ],
                    ),
                  ),
                  body: const TabBarView(
                    children: [
                      Text('Overview content'),
                      Text('Details content'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();

      expect(find.text('Details content'), findsOneWidget);
    });
  });

  group('AppBreadcrumb', () {
    testWidgets('renders all breadcrumb labels', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
           AppBreadcrumb(
            items: [
              AppBreadcrumbItem(label: 'Home'),
              AppBreadcrumbItem(label: 'Users'),
              AppBreadcrumbItem(label: 'Details'),
            ],
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Users'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets('calls onTap for previous item', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          AppBreadcrumb(
            items: [
              AppBreadcrumbItem(
                label: 'Home',
                onTap: () => tapped = true,
              ),
              const AppBreadcrumbItem(label: 'Details'),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Home'));
      expect(tapped, isTrue);
    });

    testWidgets('does not make last item clickable', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          AppBreadcrumb(
            items: [
              const AppBreadcrumbItem(label: 'Home'),
              AppBreadcrumbItem(
                label: 'Details',
                onTap: () => tapped = true,
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Details'));
      expect(tapped, isFalse);
    });

    testWidgets('supports RTL direction', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(locale: const Locale('ar')),
          home:  Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: AppBreadcrumb(
                items: [
                  AppBreadcrumbItem(label: 'الرئيسية'),
                  AppBreadcrumbItem(label: 'المستخدمون'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('المستخدمون'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    });
  });
}