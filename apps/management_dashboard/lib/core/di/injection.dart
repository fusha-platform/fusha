import 'package:get_it/get_it.dart';

import '../routing/app_router.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  if (!getIt.isRegistered<DashboardRouter>()) {
    getIt.registerLazySingleton<DashboardRouter>(DashboardRouter.new);
  }
}
