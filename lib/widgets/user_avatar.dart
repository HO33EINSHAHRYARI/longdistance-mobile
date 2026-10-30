import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String displayName;
  final bool isVerified;
  final String? badgeColor;
  final double radius;

  const UserAvatar({
    Key? key,
    this.avatarUrl,
    required this.displayName,
    this.isVerified = false,
    this.badgeColor,
    this.radius = 22,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color ringColor = AppColors.primary;
    if (badgeColor != null && badgeColor!.isNotEmpty) {
      try {
        String hex = badgeColor!.replaceAll('#', '');
        if (hex.length == 6) hex = 'FF$hex';
        ringColor = Color(int.parse('0x$hex'));
      } catch (_) {}
    }

    final fullUrl = (avatarUrl != null && avatarUrl!.isNotEmpty)
        ? (avatarUrl!.startsWith('http') ? avatarUrl! : 'https://longdistance.ir/$avatarUrl')
        : null;

    final initial = displayName.isNotEmpty ? displayName.characters.first : '؟';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                ringColor,
                AppColors.accent,
                AppColors.secondary,
                ringColor,
              ],
            ),
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.surface,
            child: fullUrl != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: fullUrl,
                      width: radius * 2,
                      height: radius * 2,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceLight,
                        child: const Center(
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildFallback(initial),
                    ),
                  )
                : _buildFallback(initial),
          ),
        ),
        if (isVerified)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified,
                color: AppColors.secondary,
                size: 15,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFallback(String initial) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF2E1065), Color(0xFF4C1D95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: AppColors.primaryLight,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.9,
          ),
        ),
      ),
    );
  }
}
