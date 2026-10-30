class ApiEndpoints {
  static const String baseUrl = 'https://longdistance.ir/api';
  
  // Auth
  static const String login = '$baseUrl/login.php';
  static const String register = '$baseUrl/register.php';
  static const String authCheck = '$baseUrl/auth_check.php';
  
  // Feed & Posts
  static const String posts = '$baseUrl/posts.php';
  static const String hotPosts = '$baseUrl/hot_posts.php';
  static const String postDetail = '$baseUrl/get_post.php';
  static const String createPost = '$baseUrl/create_post.php';
  static const String deletePost = '$baseUrl/delete_post.php';
  static const String editPost = '$baseUrl/edit_post.php';
  static const String like = '$baseUrl/like.php';
  static const String savePost = '$baseUrl/save_post.php';
  
  // Comments
  static const String addComment = '$baseUrl/add_comment.php';
  static const String deleteComment = '$baseUrl/delete_comment.php';
  
  // Moderation & Social Shield
  static const String blockUser = '$baseUrl/block_user.php';
  static const String unblockUser = '$baseUrl/unblock_user.php';
  static const String getBlockedUsers = '$baseUrl/get_blocked_users.php';
  static const String reportPost = '$baseUrl/report_post.php';
  static const String reportComment = '$baseUrl/report_comment.php';
  
  // User & Social
  static const String profile = '$baseUrl/get_profile_full.php';
  static const String userPosts = '$baseUrl/user_posts.php';
  static const String follow = '$baseUrl/follow.php';
  static const String searchUsers = '$baseUrl/search_users.php';
  static const String notifications = '$baseUrl/get_notifications.php';
  static const String markAllRead = '$baseUrl/mark_all_read.php';
  static const String stats = '$baseUrl/stats.php';
}
