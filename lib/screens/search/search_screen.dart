import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../models/user_model.dart';
import '../../widgets/user_avatar.dart';
import '../profile/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  final int currentUserId;

  const SearchScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final List<UserModel> _results = [];
  Timer? _debounce;
  bool _isLoading = false;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.length < 2) {
      setState(() => _results.clear());
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ApiClient.get(
        ApiEndpoints.searchUsers,
        queryParams: {'q': query},
      );

      final List rawUsers = res['users'] ?? [];
      setState(() {
        _results.clear();
        _results.addAll(rawUsers.map((u) => UserModel.fromJson(u)));
      });
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
            decoration: const InputDecoration(
              hintText: 'جستجوی نام کاربری یا دوستان...',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          actions: [
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear_rounded, size: 20),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _results.clear());
                },
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _results.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'نام یا نام کاربری شخص مورد نظر را بنویسید'
                          : 'هیچ کاربری با این مشخصات یافت نشد',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
                    ),
                  )
                : ListView.builder(
                    itemCount: _results.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final user = _results[index];
                      return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileScreen(
                                userId: user.id,
                                currentUserId: widget.currentUserId,
                              ),
                            ),
                          );
                        },
                        leading: UserAvatar(
                          avatarUrl: user.avatar,
                          displayName: user.displayName,
                          isVerified: user.verified,
                          badgeColor: user.badgeColor,
                          radius: 20,
                        ),
                        title: Text(
                          user.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                        ),
                        subtitle: Text(
                          '@${user.username}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                      );
                    },
                  ),
      ),
    );
  }
}
