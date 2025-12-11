// lib/alia-community/widgets/community_card.dart
import 'package:flutter/material.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';
import '../models/community.dart';

class CommunityCard extends StatelessWidget {
  final Community community;
  final VoidCallback? onTap;

  const CommunityCard({
    super.key,
    required this.community,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.indigo, // card background
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // avatar bulat dummy
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // boleh putih biasa untuk avatar
              ),
            ),
            const SizedBox(width: 16),
            // teks
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
                      height: 1.4,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
