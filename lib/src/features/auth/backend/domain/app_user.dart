class AppUser {
  final String id;
  final String email;

  const AppUser({
    required this.id,
    required this.email,
  });

  // A helper method to create an AppUser from a Supabase User object
  // Since we haven't imported Supabase here to keep Domain clean, we'll map it in the repository.
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      email: map['email'] as String,
    );
  }
}
