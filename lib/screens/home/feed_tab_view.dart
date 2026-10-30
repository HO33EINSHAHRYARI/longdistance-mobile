import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../models/post_model.dart';
import '../../widgets/post_card.dart';
import '../post_detail/post_detail_screen.dart';
import '../profile/profile_screen.dart';

class FeedTabView extends StatefulWidget {
  final String filter;
  final int currentUserId;

  const FeedTabView({
    Key? key,
    required this.filter,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<FeedTabView> createState() => FeedTabViewState();
}

class FeedTabViewState extends State<FeedTabView> with AutomaticKeepAliveClientMixin {
  final List<PostModel> _posts = [];
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  String? _errorMessage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchPosts(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      if (!_isLoadingMore && _hasMore && !_isLoading) {
        _fetchPosts(reset: false);
      }
    }
  }

  Future<void> refresh() => _fetchPosts(reset: true);

  Future<void> _fetchPosts({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _page = 1;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final res = await ApiClient.get(
        ApiEndpoints.posts,
        queryParams: {
          'filter': widget.filter,
          'page': _page,
          'limit': 20,
        },
      );

      if (res['success'] == true) {
        final List rawPosts = res['posts'] ?? [];
        final List<PostModel> fetched = rawPosts.map((p) => PostModel.fromJson(p)).toList();

        setState(() {
          if (reset) {
            _posts.clear();
          }
          _posts.addAll(fetched);
          _hasMore = res['hasMore'] == true;
          _page++;
        });
      } else {
        setState(() {
          _errorMessage = res['error'] ?? 'خطا در بارگذاری پست‌ها';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void removePost(int postId) {
    setState(() {
      _posts.removeWhere((p) => p.id == postId);
    });
  }

  void removeAuthorPosts(int authorId) {
    setState(() {
      _posts.removeWhere((p) => p.userId == authorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading && _posts.isEmpty) {
      return _buildShimmerLoading();
    }

    if (_errorMessage != null && _posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () => _fetchPosts(reset: true),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('تلاش دوباره'),
              ),
            ],
          ),
        ),
      );
    }

    if (_posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _fetchPosts(reset: true),
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Column(
                children: const [
                  Text('✨', style: TextStyle(fontSize: 42)),
                  SizedBox(height: 14),
                  Text(
                    'هنوز پستی در این بخش نیست',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'اولین نفری باش که احساساتت را به اشتراک می‌گذاری!',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchPosts(reset: true),
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.only(top: 8, bottom: 90),
        itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            );
          }

          final post = _posts[index];
          final isOwn = post.userId == widget.currentUserId;

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: PostCard(
              key: ValueKey(post.id),
              post: post,
              isOwnPost: isOwn,
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
              onPostDeleted: () => removePost(post.id),
              onAuthorBlocked: () => removeAuthorPosts(post.userId),
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
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 4,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.surface,
        highlightColor: AppColors.surfaceLight,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
