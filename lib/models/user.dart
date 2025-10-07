class User {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String avatarUrl;
  final String bio;
  final List<String> interests;
  final bool isOnline;

  User({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.avatarUrl,
    required this.bio,
    required this.interests,
    this.isOnline = false,
  });
}