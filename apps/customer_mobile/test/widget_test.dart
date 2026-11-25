import 'package:customer_mobile/core/di/injection.dart';
import 'package:customer_mobile/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    configureDependencies();
  });

  testWidgets('Customer app starts with the Arabic home screen', (
    tester,
  ) async {
    await tester.pumpWidget(const FushaCustomerApp());
    await tester.pumpAndSettle();

    expect(find.text('فسحة'), findsOneWidget);
    expect(find.text('اكتشف تجارب جديدة'), findsOneWidget);
  });
}
