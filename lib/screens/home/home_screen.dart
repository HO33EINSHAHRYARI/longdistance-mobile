import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../create_post/create_post_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';
import '../notifications/notifications_screen.dart';
import '../auth/auth_screen.dart';
import 'feed_tab_view.dart';

class HomeScreen extends StatefulWidget {
  final int currentUserId;

  const HomeScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<FeedTabViewState> _latestKey = GlobalKey();
  final GlobalKey<FeedTabViewState> _followingKey = GlobalKey();
  final GlobalKey<FeedTabViewState> _hotKey = GlobalKey();
  final GlobalKey<FeedTabViewState> _savedKey = GlobalKey();

  int _unreadNotifs = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkUnreadNotifs();
  }

  Future<void> _checkUnreadNotifs() async {
    try {
      final res = await ApiClient.get(ApiEndpoints.notifications);
      if (res['success'] == true) {
        final List notifs = res['notifications'] ?? [];
        final unread = notifs.where((n) => n['is_read'] == 0 || n['is_read'] == false).length;
        if (mounted) setState(() => _unreadNotifs = unread);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: const Center(
                  child: Text('💜', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'لانگ‌دیستنس',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          actions: [
            // Search
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SearchScreen(currentUserId: widget.currentUserId)),
                );
              },
            ),

            // Notifications with badge
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    );
                    _checkUnreadNotifs();
                  },
                ),
                if (_unreadNotifs > 0)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        _unreadNotifs > 99 ? '99+' : '$_unreadNotifs',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),

            // Profile
            IconButton(
              icon: const Icon(Icons.person_outline_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      userId: widget.currentUserId,
                      currentUserId: widget.currentUserId,
                    ),
                  ),
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 1)),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '🕒 تازه‌ها'),
                  Tab(text: '👥 دوستانم'),
                  Tab(text: '🔥 داغ‌ترین‌ها'),
                  Tab(text: '🔖 ذخیره‌ها'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            FeedTabView(key: _latestKey, filter: 'latest', currentUserId: widget.currentUserId),
            FeedTabView(key: _followingKey, filter: 'following', currentUserId: widget.currentUserId),
            FeedTabView(key: _hotKey, filter: 'hot24', currentUserId: widget.currentUserId),
            FeedTabView(key: _savedKey, filter: 'saved', currentUserId: widget.currentUserId),
          ],
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.45),
                blurRadius: 18,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0,
            onPressed: () async {
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const CreatePostScreen()),
              );
              if (created == true) {
                _latestKey.currentState?.refresh();
                _tabController.animateTo(0);
              }
            },
            child: const Icon(Icons.edit_outlined, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}
