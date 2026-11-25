import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import 'package:customer_mobile/core/di/injection.dart';
import 'package:customer_mobile/core/routing/app_router.dart';
import 'package:customer_mobile/l10n/app_localizations.dart';

class FushaCustomerApp extends StatelessWidget {
  const FushaCustomerApp({super.key});

  static const Locale defaultLocale = Locale('ar');

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fusha',
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
      routerConfig: getIt<AppRouter>().router,
    );
  }
}
