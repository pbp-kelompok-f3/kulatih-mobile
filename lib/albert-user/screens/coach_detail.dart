import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kulatih_mobile/models/user_provider.dart';
import 'package:kulatih_mobile/theme/app_colors.dart';
import 'package:kulatih_mobile/albert-user/models/coach.dart';
import 'package:kulatih_mobile/albert-user/widgets/coach_card.dart'; // Sport category
import 'package:kulatih_mobile/navigationbar.dart';

class CoachDetail extends StatelessWidget {
  final Coach coach;

  const CoachDetail({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    final formattedPrice = "IDR ${coach.hourlyFee}";
    final sportLabel = sportChoices[coach.sport] ?? coach.sport;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.navBarBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[800],
              backgroundImage: NetworkImage(
                'http://localhost:8000/account/proxy-image/?url=${Uri.encodeComponent(context.watch<UserProvider>().userProfile?.profile?.profilePhoto ?? '')}',
              ),
              onBackgroundImageError: (_, __) {},
              child: coach.profilePhoto.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- COACH INFO CARD ---
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Profile Photo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      'http://localhost:8000/account/proxy-image/?url=${Uri.encodeComponent(coach.profilePhoto)}',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey,
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coach.fullName,
                          style: const TextStyle(
                            color: AppColors.textHeading,
                            fontSize:
                                20, // Sedikit disesuaikan agar muat jika nama panjang
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "$sportLabel - ${coach.city}",
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- DESCRIPTION ---
            const Text(
              "Description",
              style: TextStyle(
                color: AppColors.textHeading,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              coach.description.isNotEmpty
                  ? coach.description
                  : "No description provided by this coach.",
              style: const TextStyle(
                color: AppColors.textPrimary,
                height: 1.5,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // --- PRICE ---
            Text(
              "$formattedPrice / Hour",
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // --- BOOKING BUTTON ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement Booking Logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Booking ${coach.fullName}...")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "BOOK COACH",
                  style: TextStyle(
                    color: AppColors.buttonText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- RATING AND FEEDBACK ---
            const Text(
              "RATING AND FEEDBACK",
              style: TextStyle(
                color: AppColors.textHeading,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Karena data Review belum ada di Model Coach maupun API,
            // Kita tampilkan placeholder kosong agar tidak menggunakan dummy data palsu.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    color: Colors.white54,
                    size: 40,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "No reviews yet.",
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 0, // Index 0 = Coach/Find Coach
        onTap: (index) {
          // Pop back ke MyHomePage dan pindah ke tab yang dipilih
          Navigator.pop(context);
          // Jika ingin navigasi ke tab lain, Anda perlu menggunakan callback atau state management
        },
      ),
    );
  }
}
