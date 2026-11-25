enum ProviderType { business, organizer }

class ProviderMembership {
  const ProviderMembership({
    required this.providerType,
    required this.providerId,
    required this.role,
    required this.status,
    this.permissions = const <String>{},
  });

  final ProviderType providerType;
  final String providerId;

  /// Backend-defined value. Kept as String until the API contract defines enums.
  final String role;

  /// Backend-defined value (for example: Pending, Active, Suspended, Revoked).
  final String status;

  /// Explicit permissions returned by the trusted backend.
  final Set<String> permissions;
}
