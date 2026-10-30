import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/network/api_client.dart';
import '../../models/user_model.dart';
import '../../models/post_model.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/post_card.dart';
import '../post_detail/post_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  final int currentUserId;

  const ProfileScreen({
    Key? key,
    required this.userId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  final List<PostModel> _userPosts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await ApiClient.get(
        ApiEndpoints.profile,
        queryParams: {'user_id': widget.userId},
      );

      if (res['user'] != null) {
        final userModel = UserModel.fromJson({
          ...res['user'],
          'followersCount': res['followersCount'],
          'followingCount': res['followingCount'],
          'is_following': res['is_following'],
          'is_blocked': res['is_blocked'],
          'is_blocked_by_them': res['is_blocked_by_them'],
          'points': res['points'],
        });

        final List rawPosts = res['posts'] ?? [];
        final posts = rawPosts.map((p) => PostModel.fromJson(p)).toList();

        setState(() {
          _user = userModel;
          _userPosts.clear();
          _userPosts.addAll(posts);
        });
      } else {
        setState(() {
          _errorMessage = res['error'] ?? 'کاربر یافت نشد';
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

  Future<void> _toggleFollow() async {
    if (_user == null) return;
    final isFollowing = _user!.isFollowing;

    setState(() {
      _user = UserModel(
        id: _user!.id,
        username: _user!.username,
        displayName: _user!.displayName,
        bio: _user!.bio,
        avatar: _user!.avatar,
        verified: _user!.verified,
        badgeColor: _user!.badgeColor,
        followersCount: isFollowing ? _user!.followersCount - 1 : _user!.followersCount + 1,
        followingCount: _user!.followingCount,
        isFollowing: !isFollowing,
        isBlocked: _user!.isBlocked,
        isBlockedByThem: _user!.isBlockedByThem,
        points: _user!.points,
      );
    });

    try {
      if (isFollowing) {
        await ApiClient.post('${ApiEndpoints.follow}?userId=${_user!.id}');
      } else {
        await ApiClient.post('${ApiEndpoints.follow}?userId=${_user!.id}');
      }
    } catch (_) {
      _fetchProfile();
    }
  }

  Future<void> _unblockUser() async {
    try {
      await ApiClient.post(ApiEndpoints.unblockUser, body: {'blocked_user_id': widget.userId});
      _fetchProfile();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا: $e', textAlign: TextAlign.right), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwnProfile = widget.userId == widget.currentUserId;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(_user?.displayName ?? 'پروفایل کاربر'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.textSecondary)))
                : RefreshIndicator(
                    onRefresh: _fetchProfile,
                    color: AppColors.primary,
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 40),
                      children: [
                        // Cover with Avatar
                        _buildCoverSection(),

                        // Blocked banner if blocked by them
                        if (_user!.isBlockedByThem) ...[
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.dangerSurface,
                              border: Border.all(color: AppColors.danger.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: const [
                                Icon(Icons.shield_outlined, size: 38, color: AppColors.danger),
                                SizedBox(height: 10),
                                Text(
                                  'دسترسی به این پروفایل محدود شده است',
                                  style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 14.5),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'شما توسط این کاربر مسدود شده‌اید.',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ] else if (_user!.isBlocked) ...[
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.dangerSurface,
                              border: Border.all(color: AppColors.danger.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  '🚫 شما این کاربر را مسدود کرده‌اید',
                                  style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 14.5),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: _unblockUser,
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                  icon: const Icon(Icons.lock_open_rounded, size: 18),
                                  label: const Text('رفع مسدودیت'),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Normal Profile Details
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                Text(
                                  _user!.displayName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '@${_user!.username}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                if (_user!.bio != null && _user!.bio!.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    _user!.bio!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 18),

                                // Stats row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildStatItem('پست', _userPosts.length),
                                    _buildDivider(),
                                    _buildStatItem('دنبال‌کننده', _user!.followersCount),
                                    _buildDivider(),
                                    _buildStatItem('دنبال‌شونده', _user!.followingCount),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                // Action Buttons
                                if (!isOwnProfile) ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _toggleFollow,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _user!.isFollowing ? AppColors.surfaceLight : AppColors.primary,
                                          ),
                                          icon: Icon(
                                            _user!.isFollowing ? Icons.person_remove_outlined : Icons.person_add_outlined,
                                            size: 18,
                                          ),
                                          label: Text(_user!.isFollowing ? 'لغو دنبال کردن' : 'دنبال کردن'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Posts Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.grid_view_rounded, size: 18, color: AppColors.primaryLight),
                                const SizedBox(width: 8),
                                Text(
                                  'پست‌های ${_user!.displayName}',
                                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ),

                          if (_userPosts.isEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              alignment: Alignment.center,
                              child: const Text('هنوز پستی ثبت نشده است', style: TextStyle(color: AppColors.textMuted)),
                            ),
                          ] else ...[
                            ..._userPosts.map((post) {
                              return PostCard(
                                post: post,
                                isOwnPost: isOwnProfile,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PostDetailScreen(
                                        postId: post.id,
                                        currentUserId: widget.currentUserId,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          ],
                        ],
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildCoverSection() {
    return SizedBox(
      height: 160,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Background Gradient Cover
          Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E1065), Color(0xFF1E1B4B), Color(0xFF0A0A0F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Overlapping Avatar
          Positioned(
            bottom: 0,
            child: UserAvatar(
              avatarUrl: _user?.avatar,
              displayName: _user?.displayName ?? '',
              isVerified: _user?.verified ?? false,
              badgeColor: _user?.badgeColor,
              radius: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            DateFormatter.toPersianDigits(count),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: AppColors.cardBorder,
    );
  }
}
