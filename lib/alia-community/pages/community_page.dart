// lib/alia-community/pages/community_page.dart
import 'package:flutter/material.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';
import 'package:kulatih_mobile/navigationbar.dart';
import '../models/community.dart';
import '../services/community_service.dart';
import '../widgets/community_card.dart';
import 'my_community_page.dart';
import 'create_community_page.dart';
import 'community_detail_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List<Community> communities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCommunities();
  }

  Future<void> fetchCommunities() async {
    final data = await CommunityService.getAllCommunities();
    setState(() {
      communities = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.indigoDark,
      bottomNavigationBar: const NavBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "WELCOME TO OUR COMMUNITY",
                    style: TextStyle(
                      color: AppColors.indigoDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Searchbar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.textWhite,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search community",
                    hintStyle: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 14,
                    ),
                    suffixIcon: Icon(Icons.search, color: AppColors.indigoDark),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyCommunityPage()),
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.indigo,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "MY COMMUNITY",
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CreateCommunityPage()),
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.indigo,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "MAKE COMMUNITY",
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: AppColors.gold))
                    : ListView.builder(
                        itemCount: communities.length,
                        itemBuilder: (context, index) {
                          final c = communities[index];
                          return CommunityCard(
                            community: c,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CommunityDetailPage(community: c),
                                ),
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
