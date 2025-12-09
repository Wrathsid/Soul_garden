class UserProfile {
  final String id;
  final String? displayName;
  final int xp;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    this.displayName,
    required this.xp,
    this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      xp: json['xp'] as int? ?? 0,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'xp': xp,
      'avatar_url': avatarUrl,
    };
  }
}
