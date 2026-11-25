import 'package:flutter_test/flutter_test.dart';
import 'package:management_dashboard/app/app.dart';
import 'package:management_dashboard/core/di/injection.dart';

void main() {
  setUp(() {
    configureDependencies();
  });

  testWidgets('shows the Arabic management dashboard foundation', (
    tester,
  ) async {
    await tester.pumpWidget(const FushaManagementDashboardApp());
    await tester.pumpAndSettle();

    expect(find.text('إدارة فسحة'), findsOneWidget);
    expect(find.text('مرحبا بك في لوحة إدارة فسحة'), findsOneWidget);
    expect(
      find.text('مساحة موحدة لإدارة خدمات فسحة وعمليات المنصة.'),
      findsOneWidget,
    );
  });
}
