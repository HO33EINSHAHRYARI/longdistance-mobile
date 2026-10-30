import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/network/api_client.dart';
import '../../models/post_model.dart';
import '../../models/comment_model.dart';
import '../../widgets/post_card.dart';
import '../../widgets/user_avatar.dart';
import '../profile/profile_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;
  final int currentUserId;

  const PostDetailScreen({
    Key? key,
    required this.postId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  PostModel? _post;
  final List<CommentModel> _comments = [];
  final TextEditingController _commentInputController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmittingComment = false;
  String? _errorMessage;

  int? _replyToCommentId;
  String? _replyToUsername;

  @override
  void initState() {
    super.initState();
    _fetchPostDetail();
  }

  @override
  void dispose() {
    _commentInputController.dispose();
    super.dispose();
  }

  Future<void> _fetchPostDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await ApiClient.get(
        ApiEndpoints.postDetail,
        queryParams: {'id': widget.postId},
      );

      if (res['success'] == true) {
        final postJson = res['post'];
        final List rawComments = res['comments'] ?? [];

        setState(() {
          _post = PostModel.fromJson(postJson);
          _comments.clear();
          _comments.addAll(rawComments.map((c) => CommentModel.fromJson(c)));
        });
      } else {
        setState(() {
          _errorMessage = res['error'] ?? 'خطا در بارگذاری پست';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitComment() async {
    final text = _commentInputController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmittingComment = true);

    try {
      final body = <String, dynamic>{
        'post_id': widget.postId,
        'content': text,
      };
      if (_replyToCommentId != null) {
        body['parent_id'] = _replyToCommentId;
      }

      final res = await ApiClient.post(ApiEndpoints.addComment, body: body);

      if (res['success'] == true) {
        _commentInputController.clear();
        setState(() {
          _replyToCommentId = null;
          _replyToUsername = null;
        });
        _fetchPostDetail();
      } else {
        _showToast(res['error'] ?? 'خطا در ارسال نظر', isError: true);
      }
    } catch (e) {
      _showToast(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isSubmittingComment = false);
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _blockCommenter(int userId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('مسدود کردن $name', textAlign: TextAlign.right, style: const TextStyle(color: AppColors.danger)),
        content: Text(
          'آیا از مسدود کردن «$name» مطمئن هستید؟ تمامی نظرات این کاربر پنهان خواهند شد.',
          textAlign: TextAlign.right,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiClient.post(ApiEndpoints.blockUser, body: {'blocked_user_id': userId});
                setState(() {
                  _comments.removeWhere((c) => c.userId == userId);
                });
                _showToast('کاربر مسدود شد و نظراتش حذف گردید');
              } catch (e) {
                _showToast('خطا: $e', isError: true);
              }
            },
            child: const Text('مسدود کن'),
          ),
        ],
      ),
    );
  }

  void _reportComment(int commentId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('گزارش نظر', textAlign: TextAlign.right, style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(hintText: 'دلیل گزارش...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              final reason = controller.text.trim();
              if (reason.isEmpty) return;
              Navigator.pop(ctx);
              try {
                final res = await ApiClient.post(ApiEndpoints.reportComment, body: {
                  'comment_id': commentId,
                  'reason': reason,
                });
                _showToast(res['message'] ?? 'گزارش ثبت شد');
              } catch (e) {
                _showToast('خطا: $e', isError: true);
              }
            },
            child: const Text('ارسال'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('مشاهده پست و گفتگو'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield_outlined, size: 48, color: AppColors.danger),
                          const SizedBox(height: 14),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('بازگشت'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 24),
                          children: [
                            if (_post != null) ...[
                              PostCard(
                                post: _post!,
                                isOwnPost: _post!.userId == widget.currentUserId,
                                onPostDeleted: () => Navigator.pop(context),
                                onAuthorBlocked: () => Navigator.pop(context),
                                onAuthorTap: (uid) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProfileScreen(
                                        userId: uid,
                                        currentUserId: widget.currentUserId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],

                            // Comments Section Header
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.forum_outlined, size: 18, color: AppColors.primaryLight),
                                  const SizedBox(width: 8),
                                  Text(
                                    'نظرات کاربران (${DateFormatter.toPersianDigits(_comments.length)})',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (_comments.isEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                alignment: Alignment.center,
                                child: Column(
                                  children: const [
                                    Text('💬✨', style: TextStyle(fontSize: 32)),
                                    SizedBox(height: 10),
                                    Text(
                                      'هنوز نظری ثبت نشده است',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'اولین نفر باش که نظرت رو می‌نویسی!',
                                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              ..._comments.map((comment) => _buildCommentItem(comment)),
                            ],
                          ],
                        ),
                      ),

                      // Bottom Reply / Input Bar
                      _buildBottomInputBar(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    final isOwn = comment.userId == widget.currentUserId;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Author header
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(
                        userId: comment.userId,
                        currentUserId: widget.currentUserId,
                      ),
                    ),
                  );
                },
                child: UserAvatar(
                  avatarUrl: comment.avatar,
                  displayName: comment.displayName,
                  isVerified: comment.verified,
                  badgeColor: comment.badgeColor,
                  radius: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      DateFormatter.timeAgo(comment.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons on comment
              if (!isOwn) ...[
                IconButton(
                  icon: const Icon(Icons.flag_outlined, size: 17, color: AppColors.textMuted),
                  tooltip: 'گزارش',
                  onPressed: () => _reportComment(comment.id),
                ),
                IconButton(
                  icon: const Icon(Icons.block_rounded, size: 17, color: AppColors.danger),
                  tooltip: 'مسدودسازی',
                  onPressed: () => _blockCommenter(comment.userId, comment.displayName),
                ),
              ],
            ],
          ),

          if (comment.parentUsername != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '💬 در پاسخ به @${comment.parentUsername}',
                style: const TextStyle(color: AppColors.primaryLight, fontSize: 11.5),
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Content
          Text(
            comment.content,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          // Reply trigger
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                setState(() {
                  _replyToCommentId = comment.id;
                  _replyToUsername = comment.username;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'پاسخ',
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1.5)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyToUsername != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.reply_rounded, color: AppColors.primaryLight, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'در پاسخ به @$_replyToUsername',
                      style: const TextStyle(color: AppColors.primaryLight, fontSize: 12),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() {
                        _replyToCommentId = null;
                        _replyToUsername = null;
                      }),
                      child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentInputController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'نظرت رو با احترام بنویس...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isSubmittingComment ? null : _submitComment,
                  icon: _isSubmittingComment
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        )
                      : Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
