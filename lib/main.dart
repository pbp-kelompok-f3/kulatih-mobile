import 'package:flutter/material.dart';
import 'package:kulatih_mobile/izzati-forum/pages/forum_main.dart';
import 'package:kulatih_mobile/khalisha-booking/screens/booking_list_page.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:kulatih_mobile/albert-user/screens/login.dart';
import 'package:kulatih_mobile/models/user_provider.dart';
import 'package:kulatih_mobile/navigationbar.dart';
import 'package:kulatih_mobile/salman-tournament/page/tournament_main.dart';
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
  final String title;
  final int initialIndex;

  const MyHomePage({super.key, required this.title, this.initialIndex = 0});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
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
}
