import 'package:flutter/material.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';

import '../models/community.dart';
import '../pages/community_detail_page.dart';
import '../pages/community_chat_page.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.indigo,
        borderRadius: BorderRadius.circular(20),
      ),
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
              // VIEW DETAIL (member = true)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommunityDetailPage(
                        community: community,
                        isMember: true,   // <-- FIXED
                      ),
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

              // GROUP CHAT
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommunityChatPage(community: community),
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

              // LEAVE
              GestureDetector(
                onTap: onLeave,
                child: Text(
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
    );
  }
}
