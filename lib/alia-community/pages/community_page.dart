import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:kulatih_mobile/constants/app_colors.dart';

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
  List<CommunityEntry> communities = [];
  List<CommunityEntry> filteredCommunities = [];
  bool isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCommunities();
    _searchController.addListener(_filterCommunities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchCommunities() async {
    final request = context.read<CookieRequest>();
    final data = await CommunityService.getAllCommunities(request);

    setState(() {
      communities = data;
      filteredCommunities = data;
      isLoading = false;
    });
  }

  void _filterCommunities() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        filteredCommunities = communities;
      } else {
        filteredCommunities = communities.where((c) {
          return c.name.toLowerCase().contains(query) ||
              c.shortDescription.toLowerCase().contains(query) ||
              c.fullDescription.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.indigo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ===== HEADER =====
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "WELCOME TO OUR COMMUNITY",
                    style: TextStyle(
                      color: AppColors.indigoDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ===== SEARCH BAR (Vertical padding 7) =====
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: AppColors.textWhite, fontSize: 14),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isCollapsed: true, // 🔥 Centers text perfectly
                    border: InputBorder.none,
                    hintText: "Search community to join",
                    hintStyle:
                        TextStyle(color: AppColors.textLight, fontSize: 14),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: AppColors.textLight),
                            onPressed: () => _searchController.clear(),
                          )
                        : Icon(Icons.search, color: AppColors.textLight),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ===== BUTTONS =====
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyCommunityPage()),
                        ).then((_) => fetchCommunities());
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.card,
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
                        ).then((_) => fetchCommunities());
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.card,
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

              // ===== LIST =====
              Expanded(
                child: isLoading
                    ? Center(
                        child:
                            CircularProgressIndicator(color: AppColors.gold),
                      )
                    : filteredCommunities.isEmpty
                        ? Center(
                            child: Text(
                              _searchController.text.isEmpty
                                  ? "No communities available."
                                  : "No communities found.",
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredCommunities.length,
                            itemBuilder: (context, index) {
                              final c = filteredCommunities[index];
                              return CommunityCard(
                                community: c,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          CommunityDetailPage(community: c),
                                    ),
                                  );
                                  fetchCommunities();
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
