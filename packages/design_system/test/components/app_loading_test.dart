import 'package:design_system/src/components/loading/app_circular_progress.dart';
import 'package:design_system/src/components/loading/app_linear_progress.dart';
import 'package:design_system/src/components/loading/app_loading.dart';
import 'package:design_system/src/components/loading/app_loading_overlay.dart';
import 'package:design_system/src/components/loading/app_shimmer.dart';
import 'package:design_system/src/components/loading/app_skeleton.dart';
import 'package:design_system/src/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(
        locale: const Locale('en'),
      ).copyWith(splashFactory: NoSplash.splashFactory),
      home: Scaffold(body: child),
    );
  }

  group('AppCircularProgress', () {
    testWidgets('renders circular progress indicator', (tester) async {
      await tester.pumpWidget(buildTestWidget(const AppCircularProgress()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('supports all sizes', (tester) async {
      for (final size in AppProgressSize.values) {
        await tester.pumpWidget(
          buildTestWidget(AppCircularProgress(size: size)),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      }
    });

    testWidgets('supports determinate progress', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const AppCircularProgress(value: 0.5)),
      );

      final progress = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      expect(progress.value, 0.5);
    });

    testWidgets('supports custom stroke width', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const AppCircularProgress(strokeWidth: 5)),
      );

      final progress = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      expect(progress.strokeWidth, 5);
    });
  });

  group('AppLinearProgress', () {
    testWidgets('renders linear progress indicator', (tester) async {
      await tester.pumpWidget(buildTestWidget(const AppLinearProgress()));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('supports determinate progress', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const AppLinearProgress(value: 0.75)),
      );

      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      expect(progress.value, 0.75);
    });

    testWidgets('supports custom height', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const AppLinearProgress(minHeight: 8)),
      );

      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      expect(progress.minHeight, 8);
    });
  });

  group('AppLoading', () {
    testWidgets('renders progress indicator', (tester) async {
      await tester.pumpWidget(buildTestWidget(const AppLoading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders optional message', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const AppLoading(message: 'Loading data...')),
      );

      expect(find.text('Loading data...'), findsOneWidget);
    });

    testWidgets('does not render message when omitted', (tester) async {
      await tester.pumpWidget(buildTestWidget(const AppLoading()));

      expect(find.text('Loading'), findsNothing);
    });
  });

  group('AppSkeleton', () {
    testWidgets('renders skeleton with default properties', (tester) async {
      await tester.pumpWidget(buildTestWidget(const AppSkeleton(width: 120)));

      expect(find.byType(AppSkeleton), findsOneWidget);
      expect(find.byType(AppShimmer), findsOneWidget);
    });

    testWidgets('supports rectangle shape', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppSkeleton(
            width: 100,
            height: 40,
            shape: AppSkeletonShape.rectangle,
            animate: false,
          ),
        ),
      );

      final decoratedBox = tester.widget<DecoratedBox>(
        find.byType(DecoratedBox),
      );

      final decoration = decoratedBox.decoration as BoxDecoration;

      expect(decoration.shape, BoxShape.rectangle);
      expect(decoration.borderRadius, isNull);
    });

    testWidgets('supports circle shape', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppSkeleton(
            width: 48,
            height: 48,
            shape: AppSkeletonShape.circle,
            animate: false,
          ),
        ),
      );

      final decoratedBox = tester.widget<DecoratedBox>(
        find.byType(DecoratedBox),
      );

      final decoration = decoratedBox.decoration as BoxDecoration;

      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('supports disabling animation', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const AppSkeleton(width: 120, animate: false)),
      );

      expect(find.byType(AppShimmer), findsNothing);
    });

    testWidgets('supports custom dimensions', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppSkeleton(width: 150, height: 32, animate: false),
        ),
      );

      final skeleton = tester.widget<SizedBox>(find.byType(SizedBox).first);

      expect(skeleton.width, 150);
      expect(skeleton.height, 32);
    });
  });

  group('AppShimmer', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const AppShimmer(child: Text('Shimmer content'))),
      );

      expect(find.text('Shimmer content'), findsOneWidget);
    });

    testWidgets('supports custom duration', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppShimmer(
            duration: Duration(seconds: 2),
            child: Text('Content'),
          ),
        ),
      );

      expect(find.byType(AppShimmer), findsOneWidget);
    });

    testWidgets('renders without animation when reduced motion is enabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(
            locale: const Locale('en'),
          ).copyWith(splashFactory: NoSplash.splashFactory),
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: AppShimmer(child: const Text('Static content')),
            ),
          ),
        ),
      );

      expect(find.text('Static content'), findsOneWidget);
      expect(find.byType(ShaderMask), findsNothing);
    });
  });

  group('AppLoadingOverlay', () {
    testWidgets('renders child when not loading', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppLoadingOverlay(
            isLoading: false,
            child: Text('Page content'),
          ),
        ),
      );

      expect(find.text('Page content'), findsOneWidget);
      expect(find.byType(AppLoading), findsNothing);
    });

    testWidgets('renders loading indicator when loading', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppLoadingOverlay(isLoading: true, child: Text('Page content')),
        ),
      );

      expect(find.text('Page content'), findsOneWidget);
      expect(find.byType(AppLoading), findsOneWidget);
    });

    testWidgets('renders optional loading message', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppLoadingOverlay(
            isLoading: true,
            message: 'Saving...',
            child: Text('Page content'),
          ),
        ),
      );

      expect(find.text('Saving...'), findsOneWidget);
    });

    testWidgets('blocks interaction while loading', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          AppLoadingOverlay(
            isLoading: true,
            child: TextButton(
              onPressed: () => tapped = true,
              child: const Text('Submit'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Submit'), warnIfMissed: false);

      expect(tapped, isFalse);
    });

    testWidgets('allows interaction when barrier is dismissible', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          AppLoadingOverlay(
            isLoading: true,
            barrierDismissible: true,
            child: TextButton(
              onPressed: () => tapped = true,
              child: const Text('Submit'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Submit'));

      expect(tapped, isTrue);
    });
  });
}
