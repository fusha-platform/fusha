import 'package:app_core/app_core.dart';

import '../entities/authorization_context.dart';

/// Implement only when the backend API contract is approved.
/// Do not replace this with speculative callable names or direct Firestore reads.
abstract interface class AuthorizationRepository {
  Future<Result<AuthorizationContext>> loadAccessContext();
}
