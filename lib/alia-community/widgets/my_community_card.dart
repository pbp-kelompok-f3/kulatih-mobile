// lib/alia-community/widgets/my_community_card.dart
import 'package:flutter/material.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';
import '../models/community.dart';

class MyCommunityCard extends StatelessWidget {
  final Community community;
  final VoidCallback onLeave;

  const MyCommunityCard({
    super.key,
    required this.community,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.indigo, // sama seperti card utama
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // avatar dummy
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
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
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onLeave,
                  child: Text(
                    "LEAVE",
                    style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
