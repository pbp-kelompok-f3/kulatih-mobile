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
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE8B923),
            brightness: Brightness.dark,
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
      // ================= PROFILE PAGE =================
      SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFFE8B923),
              backgroundImage: profile?.profile?.profilePhoto != null &&
                      profile!.profile!.profilePhoto!.isNotEmpty
                  ? NetworkImage(profile.profile!.profilePhoto!)
                  : null,
              child: profile?.profile?.profilePhoto == null ||
                      profile!.profile!.profilePhoto!.isEmpty
                  ? Text(
                      profile?.username.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontFamily: 'BebasNeue',
                        fontSize: 48,
                        color: Color(0xFF1A1625),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 24),

            // name
            Text(
              profile?.fullName ?? 'User',
              style: const TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: 32,
                color: Color(0xFFE8B923),
              ),
            ),
            const SizedBox(height: 8),

            // username
            Text(
              '@${profile?.username ?? 'username'}',
              style: const TextStyle(
                fontFamily: 'BeVietnamPro',
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),

            // badge COACH / MEMBER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: userProvider.isCoach
                    ? const Color(0xFFE8B923).withOpacity(0.2)
                    : Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: userProvider.isCoach
                      ? const Color(0xFFE8B923)
                      : Colors.blue,
                ),
              ),
              child: Text(
                userProvider.isCoach ? 'COACH' : 'MEMBER',
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 16,
                  color: userProvider.isCoach
                      ? const Color(0xFFE8B923)
                      : Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // basic info
            _buildInfoCard(
              icon: Icons.location_city,
              label: 'City',
              value: profile?.profile?.city ?? '-',
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.phone,
              label: 'Phone',
              value: profile?.profile?.phone ?? '-',
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.email,
              label: 'Email',
              value: profile?.email ?? '-',
            ),

            // khusus coach
            if (userProvider.isCoach) ...[
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.sports,
                label: 'Sport',
                value: profile?.profile?.sportLabel ?? '-',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.attach_money,
                label: 'Hourly Fee',
                value:
                    'Rp ${profile?.profile?.hourlyFee?.toString() ?? '0'}',
              ),
            ],

            if (profile?.profile?.description != null &&
                profile!.profile!.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.description,
                label: 'Description',
                value: profile.profile!.description!,
              ),
            ],

            // ================= MY REVIEWS BUTTON (COACH ONLY) =================
            if (userProvider.isCoach && profile?.profile != null) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  final coachId = profile!.profile!.id.toString();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewsListPage(
                        coachId: coachId,
                        coachName: profile.fullName,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8B923),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Color(0xFF1A1625)),
                          SizedBox(width: 8),
                          Text(
                            'My Reviews',
                            style: TextStyle(
                              fontFamily: 'BeVietnamPro',
                              fontSize: 16,
                              color: Color(0xFF1A1625),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.chevron_right, color: Color(0xFF1A1625)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),

      // ================= OTHER TABS =================
      TournamentMainPage(),
      const BookingListPage(),
      ForumMainPage(),
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1625),
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontFamily: 'BebasNeue', fontSize: 32),
            children: [
              TextSpan(text: 'KU', style: TextStyle(color: Colors.white)),
              TextSpan(
                text: 'LATIH',
                style: TextStyle(color: Color(0xFFE8B923)),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final response = await request.logout(
                "http://localhost:8000/auth/logout/",
              );
              if (context.mounted && response['status']) {
                userProvider.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                );
              }
            },
          ),
        ],
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
        border: Border.all(
          color: const Color(0xFFE8B923).withOpacity(0.3),
        ),
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
