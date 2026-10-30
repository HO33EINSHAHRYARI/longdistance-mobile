import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/network/api_client.dart';
import '../../widgets/user_avatar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient.get(ApiEndpoints.notifications);
      if (res['success'] == true) {
        setState(() {
          _notifications.clear();
          _notifications.addAll(res['notifications'] ?? []);
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _markAllRead() async {
    try {
      await ApiClient.post(ApiEndpoints.markAllRead);
      setState(() {
        for (var n in _notifications) {
          n['is_read'] = 1;
        }
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('اعلان‌ها'),
          actions: [
            if (_notifications.isNotEmpty)
              TextButton(
                onPressed: _markAllRead,
                child: const Text('خوانده شد', style: TextStyle(color: AppColors.primaryLight, fontSize: 13)),
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('🔔', style: TextStyle(fontSize: 36)),
                        SizedBox(height: 12),
                        Text(
                          'هیچ اعلان جدیدی وجود ندارد',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchNotifications,
                    color: AppColors.primary,
                    child: ListView.builder(
                      itemCount: _notifications.length,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemBuilder: (context, index) {
                        final notif = _notifications[index];
                        final isRead = notif['is_read'] == 1 || notif['is_read'] == true;
                        final type = notif['type'] ?? '';

                        IconData icon;
                        Color iconColor;
                        String text;

                        if (type == 'like') {
                          icon = Icons.favorite_rounded;
                          iconColor = AppColors.accent;
                          text = 'پست شما را پسندید.';
                        } else if (type == 'comment') {
                          icon = Icons.chat_bubble_rounded;
                          iconColor = AppColors.secondary;
                          text = 'برای پست شما نظر گذاشت.';
                        } else if (type == 'reply') {
                          icon = Icons.reply_rounded;
                          iconColor = AppColors.primary;
                          text = 'به نظر شما پاسخ داد.';
                        } else {
                          icon = Icons.person_add_rounded;
                          iconColor = AppColors.success;
                          text = 'شما را دنبال کرد.';
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isRead ? AppColors.surface : AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isRead ? AppColors.cardBorder.withOpacity(0.3) : AppColors.primary.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              UserAvatar(
                                avatarUrl: notif['from_user_avatar'],
                                displayName: notif['from_user_name'] ?? 'کاربر',
                                radius: 18,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
                                        children: [
                                          TextSpan(
                                            text: notif['from_user_name'] ?? 'کاربر',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(text: ' $text'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      DateFormatter.timeAgo(notif['created_at']),
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(icon, color: iconColor, size: 20),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
