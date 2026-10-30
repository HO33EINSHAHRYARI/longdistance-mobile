class CommentModel {
  final int id;
  final int postId;
  final int userId;
  final int? parentId;
  final String username;
  final String displayName;
  final String? avatar;
  final bool verified;
  final String? badgeColor;
  final String? parentUsername;
  final String content;
  final String createdAt;
  final bool edited;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentId,
    required this.username,
    required this.displayName,
    this.avatar,
    this.verified = false,
    this.badgeColor,
    this.parentUsername,
    required this.content,
    required this.createdAt,
    this.edited = false,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      postId: json['post_id'] is int ? json['post_id'] : int.tryParse(json['post_id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      parentId: json['parent_id'] != null ? int.tryParse(json['parent_id'].toString()) : null,
      username: json['username'] ?? '',
      displayName: json['display_name'] ?? json['username'] ?? '',
      avatar: json['avatar'],
      verified: json['verified'] == true || json['verified'] == 1 || json['verified'] == '1',
      badgeColor: json['badge_color'],
      parentUsername: json['parent_username'],
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? '',
      edited: json['edited'] == true,
    );
  }
}
