import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/api_endpoints.dart';
import '../core/utils/date_formatter.dart';
import '../core/network/api_client.dart';
import '../models/post_model.dart';
import 'user_avatar.dart';
import 'action_bottom_sheet.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final bool isOwnPost;
  final VoidCallback? onTap;
  final VoidCallback? onPostDeleted;
  final VoidCallback? onAuthorBlocked;
  final Function(int userId)? onAuthorTap;

  const PostCard({
    Key? key,
    required this.post,
    this.isOwnPost = false,
    this.onTap,
    this.onPostDeleted,
    this.onAuthorBlocked,
    this.onAuthorTap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimController;
  late Animation<double> _likeScaleAnim;

  @override
  void initState() {
    super.initState();
    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _likeScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(_likeAnimController);
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    super.dispose();
  }

  void _handleLike() async {
    setState(() {
      widget.post.toggleLike();
    });
    _likeAnimController.forward(from: 0.0);

    try {
      await ApiClient.post(ApiEndpoints.like, body: {'id': widget.post.id});
    } catch (_) {
      setState(() {
        widget.post.toggleLike();
      });
    }
  }

  void _handleSave() async {
    setState(() {
      widget.post.toggleSave();
    });

    try {
      await ApiClient.post(ApiEndpoints.savePost, body: {'id': widget.post.id});
    } catch (_) {
      setState(() {
        widget.post.toggleSave();
      });
    }
  }

  List<String> _extractImages(String text) {
    final regex = RegExp(r'(https?://[^\s]+\.(?:jpg|jpeg|png|webp|gif))', caseSensitive: false);
    return regex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  String _cleanText(String text, List<String> images) {
    String clean = text;
    for (var img in images) {
      clean = clean.replaceAll(img, '');
    }
    return clean.trim();
  }

  @override
  Widget build(BuildContext context) {
    final images = _extractImages(widget.post.content);
    final text = _cleanText(widget.post.content, images);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.brandPurple.withOpacity(0.04),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Exact Web .post-header)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => widget.onAuthorTap?.call(widget.post.userId),
                      child: UserAvatar(
                        avatarUrl: widget.post.avatar,
                        displayName: widget.post.displayName,
                        isVerified: widget.post.verified,
                        badgeColor: widget.post.badgeColor,
                        radius: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onAuthorTap?.call(widget.post.userId),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Exact Web .author-name-card
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0x0DFFFFFF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    widget.post.displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (widget.post.edited) ...[
                                  const SizedBox(width: 6),
                                  const Text(
                                    '(ویرایش‌شده)',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Exact Web .post-time
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0x08FFFFFF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                DateFormatter.formatRelative(widget.post.createdAt),
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Exact Web 3-Dot Action Menu Button
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0x0DFFFFFF),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.more_horiz_rounded, size: 18),
                        color: AppColors.textSecondary,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          ActionBottomSheet.show(
                            context: context,
                            postId: widget.post.id,
                            authorId: widget.post.userId,
                            authorName: widget.post.displayName,
                            content: widget.post.content,
                            isOwnPost: widget.isOwnPost,
                            onPostDeleted: () => widget.onPostDeleted?.call(),
                            onAuthorBlocked: () => widget.onAuthorBlocked?.call(),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // Content Text
                if (text.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.65,
                      color: Color(0xDEFFFFFF),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],

                // Attached Images
                if (images.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: images.first,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 200,
                        color: AppColors.surfaceLight,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                      ),
                      errorWidget: (context, url, error) => const SizedBox.shrink(),
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // Post Divider
                Container(
                  height: 1,
                  color: const Color(0x0DFFFFFF),
                  margin: const EdgeInsets.only(bottom: 10),
                ),

                // Actions Footer (Exact Web .post-footer Pill Buttons)
                Row(
                  children: [
                    // Like Pill Button
                    ScaleTransition(
                      scale: _likeScaleAnim,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _handleLike,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: widget.post.isLiked
                                  ? const Color(0x2BEE395B)
                                  : const Color(0x0DFFFFFF),
                              border: Border.all(
                                color: widget.post.isLiked
                                    ? const Color(0x66EE395B)
                                    : Colors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  widget.post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: widget.post.isLiked ? const Color(0xFFEF4444) : AppColors.textSecondary,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormatter.toPersianDigits(widget.post.likeCount),
                                  style: TextStyle(
                                    color: widget.post.isLiked ? const Color(0xFFEF4444) : AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Comment Pill Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onTap,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0x0DFFFFFF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: AppColors.textSecondary,
                                size: 15,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                DateFormatter.toPersianDigits(widget.post.commentCount),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Save / Bookmark Pill Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleSave,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.post.isSaved
                                ? const Color(0x2BC084FC)
                                : const Color(0x0DFFFFFF),
                            border: Border.all(
                              color: widget.post.isSaved
                                  ? const Color(0x66C084FC)
                                  : Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            widget.post.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            color: widget.post.isSaved ? AppColors.brandPurple : AppColors.textSecondary,
                            size: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
