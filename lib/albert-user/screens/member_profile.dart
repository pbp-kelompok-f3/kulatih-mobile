import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kulatih_mobile/models/user_provider.dart';
import 'package:kulatih_mobile/albert-user/widgets/profile_layout.dart';
import 'package:kulatih_mobile/navigationbar.dart';

class MemberProfile extends StatelessWidget {
  const MemberProfile({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil data user yang sedang login dari Provider
    final userProfile = context.watch<UserProvider>().userProfile;

    // Safety check jika userProfile null (belum login atau error)
    if (userProfile == null) {
      return const Scaffold(body: Center(child: Text("User not found")));
    }

    return ProfileLayout(
      user: userProfile,
      extraInfoRows: const [], // Member tidak punya extra info
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0, // Index 0 = Coach/Find Coach
        onTap: (index) {
          Navigator.pop(context);
        },
      ),
    );
  }
}
