import 'package:flutter/material.dart';
import 'dart:math';
import 'package:kulatih_mobile/app_bar.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:kulatih_mobile/theme/app_colors.dart';
import 'package:kulatih_mobile/albert-user/models/coach.dart';
import 'package:kulatih_mobile/albert-user/widgets/coach_card.dart';
import 'package:kulatih_mobile/albert-user/screens/coach_detail.dart';

class FindCoach extends StatefulWidget {
  const FindCoach({super.key});

  @override
  State<FindCoach> createState() => _FindCoachState();
}

class _FindCoachState extends State<FindCoach> {
  final TextEditingController _searchController = TextEditingController();

  // State untuk filter
  String _selectedSportKey = ""; // Kosong berarti "All"
  String _searchQuery = "";

  // Semua kategori untuk horizontal scroll
  final List<Map<String, String>> allCategories = [
    {'key': '', 'label': 'All'},
    {'key': 'gym', 'label': 'Gym & Fitness'},
    {'key': 'football', 'label': 'Football'},
    {'key': 'futsal', 'label': 'Futsal'},
    {'key': 'basketball', 'label': 'Basketball'},
    {'key': 'tennis', 'label': 'Tennis'},
    {'key': 'badminton', 'label': 'Badminton'},
    {'key': 'swimming', 'label': 'Swimming'},
    {'key': 'yoga', 'label': 'Yoga'},
    {'key': 'martial_arts', 'label': 'Martial Arts'},
    {'key': 'golf', 'label': 'Golf'},
    {'key': 'volleyball', 'label': 'Volleyball'},
    {'key': 'running', 'label': 'Running'},
    {'key': 'other', 'label': 'Other'},
  ];

  Future<List<Coach>> _fetchCoaches(CookieRequest request) async {
    String url =
        'http://localhost:8000/account/coaches-json/?q=$_searchQuery&sport=$_selectedSportKey';

    try {
      final response = await request.get(url);

      List<Coach> listCoach = [];
      for (var d in response) {
        if (d != null) {
          listCoach.add(Coach.fromJson(d));
        }
      }
      return listCoach;
    } catch (e) {
      print("Error fetching coaches: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const KulatihAppBar(),
      body: CustomScrollView(
        slivers: [
          // --- HERO IMAGE & TITLE (Akan scroll ke atas) ---
          SliverToBoxAdapter(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/hero_find_coach.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        AppColors.bg,
                      ],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 48,
                      fontFamily: 'BebasNeue',
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black54,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                    children: <TextSpan>[
                      TextSpan(text: 'FIND YOUR\n'),
                      TextSpan(
                        text: 'PERFECT COACH',
                        style: TextStyle(color: AppColors.textHeading),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- SEARCH BAR & FILTERS (Akan menempel di atas) ---
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 140.0,
              maxHeight: 140.0,
              child: Container(
                color: AppColors.bg,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Search Coach...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _searchQuery = _searchController.text;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Text(
                                "Search",
                                style: TextStyle(
                                  color: AppColors.buttonText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Filters Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: allCategories.map((cat) {
                          final isSelected = _selectedSportKey == cat['key'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: FilterChip(
                              label: Text(cat['label']!),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                setState(() {
                                  _selectedSportKey = cat['key']!;
                                });
                              },
                              backgroundColor: AppColors.cardBg,
                              selectedColor: AppColors.primary,
                              checkmarkColor: AppColors.buttonText,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? AppColors.buttonText
                                    : AppColors.textPrimary,
                              ),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.white24,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              showCheckmark: false,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- GRID VIEW (Konten yang bisa di-scroll) ---
          FutureBuilder<List<Coach>>(
            future: _fetchCoaches(request),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      "No coaches found.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final coach = snapshot.data![index];
                      return CoachCard(
                        coach: coach,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CoachDetail(coach: coach),
                            ),
                          );
                        },
                      );
                    },
                    childCount: snapshot.data!.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Helper class untuk SliverPersistentHeader
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}