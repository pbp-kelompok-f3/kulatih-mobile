import 'package:flutter/material.dart';
import 'package:kulatih_mobile/izzati-forum/pages/forum_main.dart';
import 'package:kulatih_mobile/khalisha-booking/screens/booking_list_page.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:kulatih_mobile/albert-user/screens/login.dart';
import 'package:kulatih_mobile/models/user_provider.dart';
import 'package:kulatih_mobile/navigationbar.dart';
import 'package:kulatih_mobile/salman-tournament/page/tournament_main.dart';
import 'package:kulatih_mobile/azizah-rating/screens/reviews_list_page.dart';
import 'package:kulatih_mobile/alia-community/pages/community_page.dart';
import 'package:kulatih_mobile/theme/app_colors.dart';
import 'package:kulatih_mobile/albert-user/screens/find_coach.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => CookieRequest()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'KuLatih',

        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'BeVietnamPro',

          scaffoldBackgroundColor: AppColors.bg,
          canvasColor: AppColors.bg,

          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.cardBg,
            onSurface: AppColors.textPrimary,
            onPrimary: AppColors.buttonText,
          ),
        ),

        home: const LoginPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.userProfile;

    List<Widget> pages = [
      // ================= INDEX 0: FIND COACH (HOME) =================
      const FindCoach(),

      // ================= INDEX 1: TOURNAMENT =================
      const TournamentMainPage(),

      // ================= INDEX 2: BOOKINGS =================
      const BookingListPage(),

      // ================= INDEX 3: FORUM =================
      const ForumMainPage(),

      // ================= INDEX 4: COMMUNITY =================
      const CommunityPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1625),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
      ),
    );
  }

  // ================= HELPER CARD =================
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8B923).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE8B923), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'BeVietnamPro',
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'BeVietnamPro',
                    fontSize: 16,
                    color: Colors.white,
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
