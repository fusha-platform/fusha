import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:design_system/src/components/bottom_sheets/app_action_bottom_sheet.dart';
import 'package:design_system/src/components/bottom_sheets/app_bottom_sheet.dart';
import 'package:design_system/src/components/bottom_sheets/app_bottom_sheet_header.dart';
import 'package:design_system/src/components/bottom_sheets/app_selection_bottom_sheet.dart';
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
  group('AppBottomSheet', () {
    testWidgets('renders title and description', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const AppBottomSheet(
            title: 'Sheet title',
            description: 'Sheet description',
            child: Text('Sheet content'),
          ),
        ),
      );

      expect(find.text('Sheet title'), findsOneWidget);
      expect(find.text('Sheet description'), findsOneWidget);
      expect(find.text('Sheet content'), findsOneWidget);
    });

    testWidgets('renders drag handle by default', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const AppBottomSheet(
            child: Text('Content'),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('app_bottom_sheet_drag_handle')),
        findsOneWidget,
      );
    });

    testWidgets('can hide drag handle', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const AppBottomSheet(
            showDragHandle: false,
            child: Text('Content'),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('app_bottom_sheet_drag_handle')),
        findsNothing,
      );
    });
    testWidgets('can hide drag handle', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const AppBottomSheet(
            showDragHandle: false,
            child: Text('Content'),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
              (widget) =>
          widget is Container &&
              widget.constraints?.maxWidth == 36 &&
              widget.constraints?.maxHeight == 4,
        ),
        findsNothing,
      );
    });

    testWidgets('renders custom header', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: AppBottomSheet(
            header: const AppBottomSheetHeader(
              title: 'Custom header',
              showCloseButton: false,
            ),
            child: const Text('Content'),
          ),
        ),
      );

      expect(find.text('Custom header'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('opens and closes using show helper', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AppBottomSheet.show<void>(
                    context: context,
                    builder: (_) => const AppBottomSheet(
                      title: 'Opened sheet',
                      child: Text('Sheet body'),
                    ),
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

      expect(find.text('Opened sheet'), findsOneWidget);
      expect(find.text('Sheet body'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Opened sheet'), findsNothing);
    });
  });

  group('AppBottomSheetHeader', () {
    testWidgets('renders title and description', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const AppBottomSheetHeader(
            title: 'Header title',
            description: 'Header description',
          ),
        ),
      );

      expect(find.text('Header title'), findsOneWidget);
      expect(find.text('Header description'), findsOneWidget);
    });

    testWidgets('can hide close button', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const AppBottomSheetHeader(
            title: 'Header title',
            showCloseButton: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });
  });

  group('AppActionBottomSheet', () {
    testWidgets('renders action items', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: AppActionBottomSheet(
            title: 'Actions',
            actions: [
              AppBottomSheetAction(
                title: 'Edit profile',
                icon: Icons.edit_rounded,
                onPressed: () {},
              ),
              AppBottomSheetAction(
                title: 'Delete account',
                icon: Icons.delete_outline_rounded,
                onPressed: () {},
                isDestructive: true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Actions'), findsOneWidget);
      expect(find.text('Edit profile'), findsOneWidget);
      expect(find.text('Delete account'), findsOneWidget);
    });

    testWidgets('calls action callback when tapped', (tester) async {
      var isPressed = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AppActionBottomSheet.show(
                    context: context,
                    title: 'Actions',
                    actions: [
                      AppBottomSheetAction(
                        title: 'Edit profile',
                        icon: Icons.edit_rounded,
                        onPressed: () => isPressed = true,
                      ),
                    ],
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

      await tester.tap(find.text('Edit profile'));
      await tester.pumpAndSettle();

      expect(isPressed, isTrue);
      expect(find.text('Actions'), findsNothing);
    });
  });

  group('AppSelectionBottomSheet', () {
    testWidgets('renders selection options', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: AppSelectionBottomSheet<String>(
            title: 'Choose city',
            options: const [
              AppBottomSheetOption(
                value: 'tulkarm',
                label: 'Tulkarm',
              ),
              AppBottomSheetOption(
                value: 'nablus',
                label: 'Nablus',
              ),
            ],
            onSelected: (_) {},
          ),
        ),
      );

      expect(find.text('Choose city'), findsOneWidget);
      expect(find.text('Tulkarm'), findsOneWidget);
      expect(find.text('Nablus'), findsOneWidget);
    });

    testWidgets('shows selected option indicator', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: AppSelectionBottomSheet<String>(
            title: 'Choose city',
            selectedValue: 'tulkarm',
            options: const [
              AppBottomSheetOption(
                value: 'tulkarm',
                label: 'Tulkarm',
              ),
              AppBottomSheetOption(
                value: 'nablus',
                label: 'Nablus',
              ),
            ],
            onSelected: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('calls onSelected with selected value', (tester) async {
      String? selectedCity;

      await tester.pumpWidget(
        _buildTestApp(
          child: AppSelectionBottomSheet<String>(
            title: 'Choose city',
            options: const [
              AppBottomSheetOption(
                value: 'tulkarm',
                label: 'Tulkarm',
              ),
              AppBottomSheetOption(
                value: 'nablus',
                label: 'Nablus',
              ),
            ],
            onSelected: (value) => selectedCity = value,
          ),
        ),
      );

      await tester.tap(find.text('Nablus'));
      await tester.pump();

      expect(selectedCity, 'nablus');
    });

    testWidgets('show helper returns selected value', (tester) async {
      String? result;

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await AppSelectionBottomSheet.show<String>(
                    context: context,
                    title: 'Choose city',
                    options: const [
                      AppBottomSheetOption(
                        value: 'tulkarm',
                        label: 'Tulkarm',
                      ),
                      AppBottomSheetOption(
                        value: 'nablus',
                        label: 'Nablus',
                      ),
                    ],
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

      await tester.tap(find.text('Nablus'));
      await tester.pumpAndSettle();

      expect(result, 'nablus');
    });
  });
}