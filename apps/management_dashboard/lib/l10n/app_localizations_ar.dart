// ignore_for_file: deprecated_member_use

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'إدارة فسحة';

  @override
  String get foundationWelcome => 'مرحبا بك في لوحة إدارة فسحة';

  @override
  String get foundationDescription =>
      'مساحة موحدة لإدارة خدمات فسحة وعمليات المنصة.';
}
