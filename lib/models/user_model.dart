class UserModel {
  final int id;
  final String username;
  final String displayName;
  final String? bio;
  final String? avatar;
  final bool verified;
  final String? badgeColor;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final bool isBlocked;
  final bool isBlockedByThem;
  final int points;

  UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    this.bio,
    this.avatar,
    this.verified = false,
    this.badgeColor,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
    this.isBlocked = false,
    this.isBlockedByThem = false,
    this.points = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      username: json['username'] ?? '',
      displayName: json['display_name'] ?? json['username'] ?? '',
      bio: json['bio'],
      avatar: json['avatar'],
      verified: json['verified'] == true || json['verified'] == 1 || json['verified'] == '1',
      badgeColor: json['badge_color'],
      followersCount: json['followersCount'] is int ? json['followersCount'] : int.tryParse(json['followersCount']?.toString() ?? '0') ?? 0,
      followingCount: json['followingCount'] is int ? json['followingCount'] : int.tryParse(json['followingCount']?.toString() ?? '0') ?? 0,
      isFollowing: json['is_following'] == true,
      isBlocked: json['is_blocked'] == true,
      isBlockedByThem: json['is_blocked_by_them'] == true,
      points: json['points'] is int ? json['points'] : int.tryParse(json['points']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'bio': bio,
      'avatar': avatar,
      'verified': verified,
      'badge_color': badgeColor,
    };
  }
}
