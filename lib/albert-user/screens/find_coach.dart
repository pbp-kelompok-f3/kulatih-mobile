import 'package:flutter/material.dart';
import 'package:kulatih_mobile/albert-user/widgets/app_bar.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:kulatih_mobile/theme/app_colors.dart';
import 'package:kulatih_mobile/albert-user/models/coach.dart';
import 'package:kulatih_mobile/models/user_provider.dart';
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
    // Bangun URL dengan query params
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

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
                          horizontal: 12,
                          vertical: 8,
                        ),
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
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Filters Row - Semua kategori dalam horizontal scroll
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

              const SizedBox(height: 20),

              // Grid View dengan FutureBuilder (Real Data)
              Expanded(
                child: FutureBuilder<List<Coach>>(
                  future: _fetchCoaches(request),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error: ${snapshot.error}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          "No coaches found.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
