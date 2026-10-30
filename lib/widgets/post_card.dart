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
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
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
      // Revert if error
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

    return Card(
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
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
                              Flexible(
                                child: Text(
                                  widget.post.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.5,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.post.edited) ...[
                                const SizedBox(width: 6),
                                const Text(
                                  '(ویرایش‌شده)',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '@${widget.post.username} • ${DateFormatter.timeAgo(widget.post.createdAt)}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary),
                    onPressed: () {
                      ActionBottomSheet.showPostMenu(
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
                ],
              ),

              // Content Text
              if (text.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.65,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],

              // Attached Images
              if (images.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: images.first,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 180,
                      color: AppColors.surfaceLight,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                    ),
                    errorWidget: (context, url, error) => const SizedBox.shrink(),
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Actions Footer
              Row(
                children: [
                  // Like Button
                  ScaleTransition(
                    scale: _likeScaleAnim,
                    child: InkWell(
                      onTap: _handleLike,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              widget.post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: widget.post.isLiked ? AppColors.accent : AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateFormatter.toPersianDigits(widget.post.likeCount),
                              style: TextStyle(
                                color: widget.post.isLiked ? AppColors.accent : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Comment Button
                  InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: AppColors.textSecondary,
                            size: 19,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormatter.toPersianDigits(widget.post.commentCount),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Save Bookmark Button
                  IconButton(
                    icon: Icon(
                      widget.post.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: widget.post.isSaved ? AppColors.primary : AppColors.textSecondary,
                      size: 21,
                    ),
                    onPressed: _handleSave,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
