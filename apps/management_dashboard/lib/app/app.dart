import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import 'package:management_dashboard/core/di/injection.dart';
import 'package:management_dashboard/core/routing/app_router.dart';
import 'package:management_dashboard/l10n/app_localizations.dart';

class FushaManagementDashboardApp extends StatelessWidget {
  const FushaManagementDashboardApp({super.key});

  static const Locale defaultLocale = Locale('ar');

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fusha Management',
      debugShowCheckedModeBanner: false,
      locale: defaultLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      theme: AppTheme.light(locale: defaultLocale),
      darkTheme: AppTheme.dark(locale: defaultLocale),
      themeMode: ThemeMode.system,
      routerConfig: getIt<DashboardRouter>().router,
    );
  }
}
