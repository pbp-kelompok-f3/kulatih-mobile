import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kulatih_mobile/models/user_provider.dart';
import 'package:kulatih_mobile/albert-user/widgets/profile_layout.dart';
import 'package:kulatih_mobile/albert-user/widgets/coach_card.dart'; // Import constant sportChoices

class CoachProfile extends StatelessWidget {
  const CoachProfile({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil data user yang sedang login dari Provider
    final userProfile = context.watch<UserProvider>().userProfile;

    if (userProfile == null) {
      return const Scaffold(body: Center(child: Text("User not found")));
    }

    // Menyiapkan Data Khusus Coach
    // 1. Label Olahraga (Mapping dari key database ke Text User Friendly)
    final sportKey = userProfile.profile?.sport ?? 'other';
    final sportLabel = sportChoices[sportKey] ?? 'Other';

    // 2. Hourly Fee
    final fee = userProfile.profile?.hourlyFee;
    final feeLabel = fee != null ? "IDR $fee" : "-";

    return ProfileLayout(
      user: userProfile,
      extraInfoRows: [
        _buildCoachRow("Sport", sportLabel),
        _buildCoachRow("Hourly Fee", feeLabel),
      ],
    );
  }

  // Helper widget lokal untuk baris info coach
  Widget _buildCoachRow(String label, String value) {
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
}
