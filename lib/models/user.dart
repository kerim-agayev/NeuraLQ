class User {
  final String id;
  final String email;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String role;
  final int? age;
  final String? country;
  final String? city;
  final String language;
  final String? school;
  final String themePreference;
  final int neuralCoins;
  final int brainPoints;
  final int currentStreak;
  final int longestStreak;
  final String authProvider;
  final String? googleId;
  final String? appleId;
  final bool emailVerified;
  final String createdAt;
  final String updatedAt;
  final List<Badge> badges;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.displayName,
    this.avatarUrl,
    required this.role,
    this.age,
    this.country,
    this.city,
    required this.language,
    this.school,
    required this.themePreference,
    required this.neuralCoins,
    required this.brainPoints,
    required this.currentStreak,
    required this.longestStreak,
    required this.authProvider,
    this.googleId,
    this.appleId,
    required this.emailVerified,
    required this.createdAt,
    required this.updatedAt,
    required this.badges,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      role: json['role'] ?? 'USER',
      age: json['age'],
      country: json['country'],
      city: json['city'],
      language: json['language'] ?? 'en',
      school: json['school'],
      themePreference: json['themePreference'] ?? 'cyberpunk',
      neuralCoins: json['neuralCoins'] ?? 0,
      brainPoints: json['brainPoints'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      authProvider: json['authProvider'] ?? 'LOCAL',
      googleId: json['googleId'],
      appleId: json['appleId'],
      emailVerified: json['emailVerified'] ?? false,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      badges: (json['badges'] as List?)
              ?.map((b) => b is Map<String, dynamic>
                  ? Badge.fromJson(b)
                  : Badge(
                      id: b.toString(),
                      name: b.toString(),
                      awardedAt: ''))
              .toList() ??
          [],
    );
  }
}

class Badge {
  final String id;
  final String name;
  final String awardedAt;

  Badge({
    required this.id,
    required this.name,
    required this.awardedAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      awardedAt: json['awardedAt'] ?? '',
    );
  }
}

class AuthResponse {
  final User user;
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
