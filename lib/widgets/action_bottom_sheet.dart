import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';

class ActionBottomSheet {
  static void show({
    required BuildContext context,
    required int postId,
    required int authorId,
    required String authorName,
    required String content,
    required bool isOwnPost,
    required VoidCallback onPostDeleted,
    required VoidCallback onAuthorBlocked,
  }) => showPostMenu(
    context: context,
    postId: postId,
    authorId: authorId,
    authorName: authorName,
    content: content,
    isOwnPost: isOwnPost,
    onPostDeleted: onPostDeleted,
    onAuthorBlocked: onAuthorBlocked,
  );

  static void showPostMenu({
    required BuildContext context,
    required int postId,
    required int authorId,
    required String authorName,
    required String content,
    required bool isOwnPost,
    required VoidCallback onPostDeleted,
    required VoidCallback onAuthorBlocked,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppColors.cardBorder, width: 1.5),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grab handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Copy Action
              _buildMenuItem(
                icon: Icons.copy_rounded,
                title: 'کپی متن پست',
                onTap: () {
                  Clipboard.setData(ClipboardData(text: content));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('متن پست در حافظه کپی شد', textAlign: TextAlign.right),
                      backgroundColor: AppColors.surfaceLight,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),

              if (isOwnPost) ...[
                // Delete Action
                _buildMenuItem(
                  icon: Icons.delete_outline_rounded,
                  title: 'حذف این پست',
                  isDanger: true,
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmDelete(context, postId, onPostDeleted);
                  },
                ),
              ] else ...[
                // Report Action
                _buildMenuItem(
                  icon: Icons.flag_outlined,
                  title: 'گزارش تخلف پست',
                  onTap: () {
                    Navigator.pop(ctx);
                    _showReportDialog(context, postId);
                  },
                ),

                // Block Action
                _buildMenuItem(
                  icon: Icons.block_rounded,
                  title: 'مسدود کردن «$authorName»',
                  isDanger: true,
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmBlock(context, authorId, authorName, onAuthorBlocked);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final color = isDanger ? AppColors.danger : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 14.5,
                fontWeight: isDanger ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showReportDialog(BuildContext context, int postId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('گزارش تخلف', textAlign: TextAlign.right, style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'علت گزارش این محتوا را بنویسید (اسپم، توهین، نقض حریم خصوصی و...):',
              textAlign: TextAlign.right,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              maxLines: 3,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(hintText: 'دلیل گزارش...'),
            ),
          ],
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
                final res = await ApiClient.post(ApiEndpoints.reportPost, body: {
                  'post_id': postId,
                  'reason': reason,
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res['message'] ?? 'گزارش شما با موفقیت ثبت شد', textAlign: TextAlign.right),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطا: $e', textAlign: TextAlign.right), backgroundColor: AppColors.danger),
                  );
                }
              }
            },
            child: const Text('ارسال گزارش'),
          ),
        ],
      ),
    );
  }

  static void _confirmBlock(BuildContext context, int userId, String name, VoidCallback onBlocked) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('مسدود کردن $name', textAlign: TextAlign.right, style: const TextStyle(color: AppColors.danger)),
        content: Text(
          'آیا از مسدود کردن «$name» مطمئن هستید؟ تمام پست‌ها و نظرات این کاربر از دید شما پنهان شده و او امکان تعامل با شما را نخواهد داشت.',
          textAlign: TextAlign.right,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.5),
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
                onBlocked();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('کاربر مسدود شد و تمامی محتوای او پنهان گردید', textAlign: TextAlign.right),
                      backgroundColor: AppColors.danger,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطا: $e', textAlign: TextAlign.right), backgroundColor: AppColors.danger),
                  );
                }
              }
            },
            child: const Text('بله، مسدود کن'),
          ),
        ],
      ),
    );
  }

  static void _confirmDelete(BuildContext context, int postId, VoidCallback onDeleted) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف پست', textAlign: TextAlign.right, style: TextStyle(color: AppColors.danger)),
        content: const Text(
          'آیا از حذف دائمی این پست اطمینان دارید؟',
          textAlign: TextAlign.right,
          style: TextStyle(color: AppColors.textSecondary),
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
                await ApiClient.post(ApiEndpoints.deletePost, body: {'post_id': postId});
                onDeleted();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('پست با موفقیت حذف شد', textAlign: TextAlign.right),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطا: $e', textAlign: TextAlign.right), backgroundColor: AppColors.danger),
                  );
                }
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
