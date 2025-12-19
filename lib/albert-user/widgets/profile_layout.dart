import 'package:flutter/material.dart';
import 'package:kulatih_mobile/models/user_model.dart';
import 'package:kulatih_mobile/theme/app_colors.dart';

class ProfileLayout extends StatelessWidget {
  final UserProfile user;
  final List<Widget> extraInfoRows; // Widget tambahan khusus Coach

  const ProfileLayout({
    super.key,
    required this.user,
    this.extraInfoRows = const [],
  });

  @override
  Widget build(BuildContext context) {
    final String? rawPhotoUrl = user.profile?.profilePhoto;
    ImageProvider? imageProvider;

    if (rawPhotoUrl != null && rawPhotoUrl.isNotEmpty) {
      final proxyUrl =
          'http://localhost:8000/account/proxy-image/?url=${Uri.encodeComponent(user.profile?.profilePhoto ?? '')}';
      imageProvider = NetworkImage(proxyUrl);
    }

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
            padding: const EdgeInsets.only(right: 20),
            child: CircleAvatar(
              backgroundColor: Colors.grey[800],
              backgroundImage: imageProvider,
              child: (imageProvider == null)
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // --- PROFILE HEADER ---
            Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[800],
                    image: imageProvider != null
                        ? DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageProvider == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.isCoach ? "Coach Profile" : "User Profile",
                        style: const TextStyle(
                          color: AppColors.textHeading,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.fullName, // Menggunakan getter fullName dari model
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "@${user.username}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- INFO CONTAINER ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Description",
                    style: TextStyle(
                      color: AppColors.textHeading,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    (user.profile?.description != null &&
                            user.profile!.description!.isNotEmpty)
                        ? user.profile!.description!
                        : "No description available.",
                    style: const TextStyle(color: Colors.white, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  // Data Tambahan (Sport & Fee untuk Coach)
                  ...extraInfoRows,

                  // Data Standar
                  _buildInfoRow("City", user.profile?.city ?? "-"),
                  _buildInfoRow("Email", user.email ?? "-"),
                  _buildInfoRow("Phone", user.profile?.phone ?? "-"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- MENU BUTTONS ---
            _buildMenuButton(context, "Edit Profile", Icons.edit, () {
              // Navigasi Edit Profile
            }),
            const SizedBox(height: 10),
            _buildMenuButton(context, "My Bookings", Icons.calendar_today, () {
              // Navigasi Booking
            }),
            const SizedBox(height: 10),
            _buildMenuButton(context, "My Ratings", Icons.star_border, () {
              // Navigasi Ratings
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
