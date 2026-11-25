import 'package:go_router/go_router.dart';

import 'package:management_dashboard/features/foundation/presentation/pages/foundation_page.dart';

class DashboardRouter {
  DashboardRouter()
    : router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            name: 'foundation',
            builder: (context, state) => const FoundationPage(),
          ),
        ],
      );

  final GoRouter router;

  void dispose() {
    router.dispose();
  }
}
