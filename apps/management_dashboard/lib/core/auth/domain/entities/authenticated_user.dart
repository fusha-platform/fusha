class AuthenticatedUser {
  const AuthenticatedUser({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
  });

  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;
}
