import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kulatih_mobile/theme/app_colors.dart';
import 'package:kulatih_mobile/models/user_provider.dart';
import 'package:kulatih_mobile/albert-user/screens/coach_profile.dart';
import 'package:kulatih_mobile/albert-user/screens/member_profile.dart';

class KulatihAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KulatihAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan context.watch agar avatar terupdate jika data user berubah
    final userProvider = context.watch<UserProvider>();
    final userProfile = userProvider.userProfile;

    return AppBar(
      backgroundColor: AppColors.navBarBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 20,
      automaticallyImplyLeading:
          false, // Matikan tombol back default jika ini halaman utama

      title: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "KU",
            style: TextStyle(
              color: AppColors.logoWhite,
              fontSize: 36,
              fontFamily: 'BebasNeue',
            ),
          ),
          Text(
            "LATIH",
            style: TextStyle(
              color: AppColors.logoYellow,
              fontSize: 36,
              fontFamily: 'BebasNeue',
            ),
          ),
        ],
      ),

      // Bagian Kanan: Foto Profil
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: GestureDetector(
            onTap: () {
              // Logika Navigasi Profile (Member vs Coach)
              if (userProvider.isCoach) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CoachProfile()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MemberProfile()),
                );
              }
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[800],
              // Jika ada URL foto, pakai NetworkImage. Jika null, null.
              backgroundImage: userProfile?.profile?.profilePhoto != null
                  ? NetworkImage(
                      'http://localhost:8000/account/proxy-image/?url=${Uri.encodeComponent(userProfile?.profile?.profilePhoto ?? '')}',
                    )
                  : null,
              // Jika tidak ada foto, tampilkan Icon Person
              child: userProfile?.profile?.profilePhoto == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
