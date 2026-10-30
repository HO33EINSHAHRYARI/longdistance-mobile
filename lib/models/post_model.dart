class PostModel {
  final int id;
  final int userId;
  final String username;
  final String displayName;
  final String? avatar;
  final bool verified;
  final String? badgeColor;
  final String content;
  final String createdAt;
  final String? updatedAt;
  final bool edited;
  int likeCount;
  final int commentCount;
  bool isLiked;
  bool isSaved;
  final List<int> likes;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatar,
    this.verified = false,
    this.badgeColor,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.edited = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.likes = const [],
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    List<int> parsedLikes = [];
    if (json['likes'] is List) {
      parsedLikes = (json['likes'] as List).map((e) => int.tryParse(e.toString()) ?? 0).toList();
    }

    return PostModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      username: json['username'] ?? '',
      displayName: json['display_name'] ?? json['username'] ?? '',
      avatar: json['avatar'],
      verified: json['verified'] == true || json['verified'] == 1 || json['verified'] == '1',
      badgeColor: json['badge_color'],
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
      edited: json['edited'] == true,
      likeCount: json['like_count'] is int ? json['like_count'] : int.tryParse(json['like_count']?.toString() ?? '0') ?? 0,
      commentCount: json['comment_count'] is int ? json['comment_count'] : int.tryParse(json['comment_count']?.toString() ?? '0') ?? 0,
      isLiked: json['is_liked'] == true || json['is_liked'] == 1,
      isSaved: json['is_saved'] == true || json['is_saved'] == 1,
      likes: parsedLikes,
    );
  }

  // Toggle like locally
  void toggleLike() {
    isLiked = !isLiked;
    if (isLiked) {
      likeCount++;
    } else {
      likeCount = likeCount > 0 ? likeCount - 1 : 0;
    }
  }

  // Toggle save locally
  void toggleSave() {
    isSaved = !isSaved;
  }
}
