import 'package:flutter/material.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';

import '../models/community.dart';
import '../pages/community_detail_page.dart';
import '../pages/community_chat_page.dart';
import '../services/community_service.dart';

class MyCommunityCard extends StatelessWidget {
  final CommunityEntry community;
  final VoidCallback onLeave;

  const MyCommunityCard({
    super.key,
    required this.community,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    // PENTING: Pakai proxy untuk load gambar
    final proxiedImageUrl = CommunityService.getProxiedImageUrl(
      community.profileImageUrl,
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: proxiedImageUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      proxiedImageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.indigo,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.white,
                        );
                      },
                    ),
                  )
                : Container(), // pfp kosong kalau no image
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  community.name.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  community.shortDescription,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CommunityDetailPage(community: community),
                          ),
                        );
                      },
                      child: Text(
                        "VIEW DETAIL",
                        style: TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CommunityChatPage(community: community),
                          ),
                        );
                      },
                      child: Text(
                        "GROUP CHAT",
                        style: TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onLeave,
                      child: const Text(
                        "LEAVE",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
