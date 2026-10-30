import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../create_post/create_post_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';
import '../notifications/notifications_screen.dart';
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
  String _displayName = 'کاربر';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _checkUnreadNotifs();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final res = await ApiClient.get(ApiEndpoints.profile, queryParams: {'id': widget.currentUserId.toString()});
      if (res['success'] == true && res['user'] != null) {
        if (mounted) {
          setState(() {
            _displayName = res['user']['name'] ?? res['user']['username'] ?? 'کاربر';
          });
        }
      }
    } catch (_) {}
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

  void _refreshCurrentTab() {
    switch (_tabController.index) {
      case 0:
        _latestKey.currentState?.refresh();
        break;
      case 1:
        _followingKey.currentState?.refresh();
        break;
      case 2:
        _hotKey.currentState?.refresh();
        break;
      case 3:
        _savedKey.currentState?.refresh();
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildHeaderButton({
    required Widget icon,
    required VoidCallback onTap,
    Widget? badge,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: AppColors.headerBtnGradient,
                border: Border.all(color: AppColors.headerBtnBorder, width: 1),
                shape: BoxShape.circle,
              ),
              child: Center(child: icon),
            ),
          ),
        ),
        if (badge != null) badge,
      ],
    );
  }

  Widget _buildTabItem(String title, int index) {
    final bool isActive = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive ? AppColors.tabActiveGradient : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isActive ? AppColors.tabActiveBorder : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.brandPurple : const Color(0x80FFFFFF),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Exact Web .main-header
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0A0A0F), Color(0xFF12121A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  border: const Border(
                    bottom: BorderSide(color: Color(0x0DFFFFFF), width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    // Top User Info & Buttons Row (Exact Web .user-info)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Welcome text
                        Row(
                          children: [
                            const Text(
                              'سلام، خوش اومدی ',
                              style: TextStyle(
                                color: Color(0x99FFFFFF),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _displayName,
                              style: const TextStyle(
                                color: AppColors.brandPurple,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(' 👋', style: TextStyle(fontSize: 14)),
                          ],
                        ),

                        // Header action buttons
                        Row(
                          children: [
                            // 🌀 Refresh
                            _buildHeaderButton(
                              icon: const Icon(Icons.refresh_rounded, color: AppColors.brandPurple, size: 20),
                              onTap: _refreshCurrentTab,
                            ),
                            const SizedBox(width: 8),

                            // 🔍 Search
                            _buildHeaderButton(
                              icon: const Icon(Icons.search_rounded, color: AppColors.brandPurple, size: 19),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => SearchScreen(currentUserId: widget.currentUserId)),
                                );
                              },
                            ),
                            const SizedBox(width: 8),

                            // 🔔 Notifications with red badge
                            _buildHeaderButton(
                              icon: const Icon(Icons.notifications_none_rounded, color: AppColors.brandPurple, size: 19),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                                );
                                _checkUnreadNotifs();
                              },
                              badge: _unreadNotifs > 0
                                  ? Positioned(
                                      top: -4,
                                      right: -4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          gradient: AppColors.dangerGradient,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppColors.background, width: 2),
                                        ),
                                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                        child: Text(
                                          _unreadNotifs > 99 ? '99+' : '$_unreadNotifs',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),

                            // 👤 Profile Drawer
                            _buildHeaderButton(
                              icon: const Icon(Icons.person_outline_rounded, color: AppColors.brandPurple, size: 20),
                              onTap: () {
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
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Exact Web .tabs-header (Segmented Pill Bar)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.tabsHeaderBg,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0x0DFFFFFF), width: 1),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Center(child: _buildTabItem('جدیدترین', 0))),
                          Expanded(child: Center(child: _buildTabItem('دنبال‌شده‌ها', 1))),
                          Expanded(child: Center(child: _buildTabItem('🔥 داغ ۲۴ ساعت', 2))),
                          Expanded(child: Center(child: _buildTabItem('ذخیره‌شده‌ها', 3))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Feed Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    FeedTabView(key: _latestKey, filter: 'latest', currentUserId: widget.currentUserId),
                    FeedTabView(key: _followingKey, filter: 'following', currentUserId: widget.currentUserId),
                    FeedTabView(key: _hotKey, filter: 'hot24', currentUserId: widget.currentUserId),
                    FeedTabView(key: _savedKey, filter: 'saved', currentUserId: widget.currentUserId),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Exact Web .new-post-btn Floating Action Button with Glow
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.brandPurple.withOpacity(0.4),
                blurRadius: 20,
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
            child: const Icon(Icons.edit_outlined, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}
