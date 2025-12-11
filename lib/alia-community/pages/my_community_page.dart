// lib/alia-community/pages/my_community_page.dart
import 'package:flutter/material.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';
import 'package:kulatih_mobile/navigationbar.dart';
import '../models/community.dart';
import '../services/community_service.dart';
import '../widgets/my_community_card.dart';

class MyCommunityPage extends StatefulWidget {
  const MyCommunityPage({super.key});

  @override
  State<MyCommunityPage> createState() => _MyCommunityPageState();
}

class _MyCommunityPageState extends State<MyCommunityPage> {
  List<Community> myCommunities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMyCommunities();
  }

  Future<void> loadMyCommunities() async {
    final data = await CommunityService.getJoinedCommunities();
    setState(() {
      myCommunities = data;
      isLoading = false;
    });
  }

  Future<void> leaveCommunity(int id) async {
    await CommunityService.leaveCommunity(id);
    loadMyCommunities();
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
            children: [
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "MY COMMUNITY",
                  style: TextStyle(
                    color: AppColors.indigoDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.textWhite,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search communities you have joined",
                    hintStyle: TextStyle(color: AppColors.textLight),
                    suffixIcon: Icon(Icons.search, color: AppColors.indigoDark),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: AppColors.gold))
                    : ListView.builder(
                        itemCount: myCommunities.length,
                        itemBuilder: (_, index) {
                          final c = myCommunities[index];
                          return MyCommunityCard(
                            community: c,
                            onLeave: () => leaveCommunity(c.id),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
