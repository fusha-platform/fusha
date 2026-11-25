import 'provider_membership.dart';

class AuthorizationContext {
  const AuthorizationContext({
    required this.platformRoles,
    required this.providerMemberships,
    required this.accountStatus,
  });

  /// Backend-authoritative platform role identifiers.
  final Set<String> platformRoles;

  /// Backend-authoritative provider memberships.
  final List<ProviderMembership> providerMemberships;

  /// Backend-defined account status.
  final String accountStatus;
}
