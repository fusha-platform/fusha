// ignore_for_file: deprecated_member_use

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fusha Management';

  @override
  String get foundationWelcome => 'Welcome to Fusha Management';

  @override
  String get foundationDescription =>
      'A unified workspace for managing Fusha services and platform operations.';
}
