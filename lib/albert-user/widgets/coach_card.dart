import 'package:flutter/material.dart';
import 'package:kulatih_mobile/theme/app_colors.dart';
import 'package:kulatih_mobile/albert-user/models/coach.dart';

// Map antara Value Database (Key) dan Tampilan di Layar (Value)
const Map<String, String> sportChoices = {
  'gym': 'Gym & Fitness',
  'football': 'Football',
  'futsal': 'Futsal',
  'basketball': 'Basketball',
  'tennis': 'Tennis',
  'badminton': 'Badminton',
  'swimming': 'Swimming',
  'yoga': 'Yoga',
  'martial_arts': 'Martial Arts',
  'golf': 'Golf',
  'volleyball': 'Volleyball',
  'running': 'Running',
  'other': 'Other',
};

class CoachCard extends StatelessWidget {
  final Coach coach;
  final VoidCallback onTap;

  const CoachCard({super.key, required this.coach, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Image.network(
                'http://localhost:8000/account/proxy-image/?url=${Uri.encodeComponent(coach.profilePhoto)}',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, error, stackTrace) => Container(
                  color: Colors.grey,
                  child: const Center(child: Icon(Icons.person, size: 40)),
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coach.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    // Mengambil teks sport dari key (misal 'martial_arts' -> 'Martial Arts')
                    "${sportChoices[coach.sport] ?? coach.sport} • ${coach.city}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "IDR ${coach.hourlyFee}/hour",
                    style: const TextStyle(
                      color: AppColors.textHeading,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
