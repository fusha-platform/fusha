import 'package:design_system/src/components/chips/app_chip.dart';
import 'package:design_system/src/components/chips/app_chip_type.dart';
import 'package:design_system/src/components/chips/app_choice_chip.dart';
import 'package:design_system/src/components/chips/app_filter_chip.dart';
import 'package:design_system/src/components/chips/app_input_chip.dart';
import 'package:design_system/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(
      locale: const Locale('en'),
    ),
    home: Scaffold(
      body: Center(
        child: child,
      ),
    ),
  );
}

void main() {
  group('AppChip', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppChip(label: 'Active'),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('renders optional icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppChip(
            label: 'Active',
            icon: Icons.check_circle,
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('supports all chip types', (tester) async {
      for (final type in AppChipType.values) {
        await tester.pumpWidget(
          buildTestWidget(
            AppChip(
              label: 'Status',
              type: type,
            ),
          ),
        );

        expect(find.text('Status'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('supports custom colors', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppChip(
            label: 'Custom',
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
        ),
      );

      expect(find.text('Custom'), findsOneWidget);
    });
  });

  group('AppFilterChip', () {
    testWidgets('renders unselected chip', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppFilterChip(
            label: 'Active',
            selected: false,
          ),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('calls onSelected when tapped', (tester) async {
      bool? selectedValue;

      await tester.pumpWidget(
        buildTestWidget(
          AppFilterChip(
            label: 'Active',
            selected: false,
            onSelected: (value) => selectedValue = value,
          ),
        ),
      );

      await tester.tap(find.byType(FilterChip));

      expect(selectedValue, isTrue);
    });

    testWidgets('does not respond when disabled', (tester) async {
      bool? selectedValue;

      await tester.pumpWidget(
        buildTestWidget(
          AppFilterChip(
            label: 'Active',
            selected: false,
            enabled: false,
            onSelected: (value) => selectedValue = value,
          ),
        ),
      );

      await tester.tap(find.byType(FilterChip));

      expect(selectedValue, isNull);
    });

    testWidgets('renders optional icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppFilterChip(
            label: 'Active',
            selected: true,
            icon: Icons.check,
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('AppChoiceChip', () {
    testWidgets('renders selected state', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppChoiceChip<String>(
            label: 'Student',
            value: 'student',
            selectedValue: 'student',
            onSelected: null,
          ),
        ),
      );

      final chip = tester.widget<ChoiceChip>(
        find.byType(ChoiceChip),
      );

      expect(chip.selected, isTrue);
    });

    testWidgets('calls onSelected with selected value', (tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        buildTestWidget(
          AppChoiceChip<String>(
            label: 'Trainer',
            value: 'trainer',
            selectedValue: 'student',
            onSelected: (value) => selectedValue = value,
          ),
        ),
      );

      await tester.tap(find.byType(ChoiceChip));

      expect(selectedValue, 'trainer');
    });

    testWidgets('renders optional icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppChoiceChip<String>(
            label: 'Student',
            value: 'student',
            selectedValue: 'student',
            onSelected: (_) {},
            icon: Icons.school,
          ),
        ),
      );

      expect(find.byIcon(Icons.school), findsOneWidget);
    });

    testWidgets('does not respond when disabled', (tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        buildTestWidget(
          AppChoiceChip<String>(
            label: 'Student',
            value: 'student',
            selectedValue: 'trainer',
            enabled: false,
            onSelected: (value) => selectedValue = value,
          ),
        ),
      );

      await tester.tap(find.byType(ChoiceChip));

      expect(selectedValue, isNull);
    });
  });

  group('AppInputChip', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppInputChip(
            label: 'Flutter',
          ),
        ),
      );

      expect(find.text('Flutter'), findsOneWidget);
    });

    testWidgets('calls onDeleted when delete is tapped', (tester) async {
      var deleted = false;

      await tester.pumpWidget(
        buildTestWidget(
          AppInputChip(
            label: 'Flutter',
            onDeleted: () => deleted = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close_rounded));

      expect(deleted, isTrue);
    });

    testWidgets('does not delete when disabled', (tester) async {
      var deleted = false;

      await tester.pumpWidget(
        buildTestWidget(
          AppInputChip(
            label: 'Flutter',
            enabled: false,
            onDeleted: () => deleted = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.close_rounded), findsNothing);
      expect(deleted, isFalse);
    });

    testWidgets('supports avatar', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppInputChip(
            label: 'Flutter',
            avatar: CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });
}