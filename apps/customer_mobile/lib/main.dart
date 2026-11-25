import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'core/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const FushaCustomerApp());
}
