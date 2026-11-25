import 'package:go_router/go_router.dart';

import '../../features/home/presentation/pages/home_page.dart';

class AppRouter {
  AppRouter()
    : router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
        ],
      );

  final GoRouter router;

  void dispose() {
    router.dispose();
  }
}
