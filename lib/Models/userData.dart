class UserData {
  final String name;
  final String studentId;
  final String? yearGroup;
  final String email;
  Set<String> favorites;
  UserData({
    required this.name,
    required this.studentId,
    required this.yearGroup,
    required this.email,
    Set<String>? favorites,
  }) : favorites = favorites ?? {};
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'studentId': studentId,
      'yearGroup': yearGroup,
      'email': email,
      'favorites': favorites.toList(),
    };
  }
  factory UserData.fromMap(Map<dynamic, dynamic> map) {
    return UserData(
      name: map['name'] ?? '',
      studentId: map['studentId'] ?? '',
      yearGroup: map['yearGroup'],
      email: map['email'] ?? '',
      favorites: map['favorites'] != null ? Set<String>.from(map['favorites']) : {},
    );
  }
}
