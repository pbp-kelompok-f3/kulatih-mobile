import 'package:flutter/material.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';
import '../models/community.dart';
<<<<<<< HEAD
=======
import '../services/community_service.dart';
>>>>>>> 26f881cfd85d4334a73816b8428d92ab95e6f3b1

class CommunityCard extends StatelessWidget {
  final CommunityEntry community;
  final VoidCallback? onTap;

  const CommunityCard({
    super.key,
    required this.community,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
=======
    // PENTING: Pakai proxy untuk load gambar
    final proxiedImageUrl = CommunityService.getProxiedImageUrl(
      community.profileImageUrl,
    );

>>>>>>> 26f881cfd85d4334a73816b8428d92ab95e6f3b1
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
<<<<<<< HEAD
          color: AppColors.card, 
=======
          color: AppColors.card,
>>>>>>> 26f881cfd85d4334a73816b8428d92ab95e6f3b1
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
            // dummy avatar
=======
            // Profile Picture
>>>>>>> 26f881cfd85d4334a73816b8428d92ab95e6f3b1
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
<<<<<<< HEAD
=======
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
>>>>>>> 26f881cfd85d4334a73816b8428d92ab95e6f3b1
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
                      height: 1.4,
                      fontSize: 12,
                    ),
                  ),
<<<<<<< HEAD
                  const SizedBox(height: 8), 
                  Text(
                    "Click to view detail",
                    style: TextStyle(
                      color: AppColors.gold, 
=======
                  const SizedBox(height: 8),
                  Text(
                    "Click to view detail",
                    style: TextStyle(
                      color: AppColors.gold,
>>>>>>> 26f881cfd85d4334a73816b8428d92ab95e6f3b1
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
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