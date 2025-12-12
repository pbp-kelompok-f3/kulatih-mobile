import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'package:kulatih_mobile/constants/app_colors.dart';
import '../models/community.dart';
import '../services/community_service.dart';
import '../widgets/my_community_card.dart';

class MyCommunityPage extends StatefulWidget {
  const MyCommunityPage({super.key});

  @override
  State<MyCommunityPage> createState() => _MyCommunityPageState();
}

class _MyCommunityPageState extends State<MyCommunityPage> {
  List<CommunityEntry> _myCommunities = [];
  List<CommunityEntry> _filteredCommunities = [];
  bool _loading = true;

  final TextEditingController _searchController = TextEditingController();

  // Pagination
  int currentPage = 1;
  int itemsPerPage = 6;
  int totalPages = 1;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_filterCommunities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final request = context.read<CookieRequest>();
    final data = await CommunityService.getMyCommunities(request);

    setState(() {
      _myCommunities = data;
      _filteredCommunities = data;
      _loading = false;
      _calculateTotalPages();
    });
  }

  void _filterCommunities() {
    final q = _searchController.text.toLowerCase().trim();

    setState(() {
      if (q.isEmpty) {
        _filteredCommunities = _myCommunities;
      } else {
        _filteredCommunities = _myCommunities.where((c) {
          return c.name.toLowerCase().contains(q) ||
              c.shortDescription.toLowerCase().contains(q) ||
              c.fullDescription.toLowerCase().contains(q);
        }).toList();
      }
      currentPage = 1;
      _calculateTotalPages();
    });
  }

  void _calculateTotalPages() {
    totalPages = (_filteredCommunities.length / itemsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;
  }

  List<CommunityEntry> _getPaginatedCommunities() {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > _filteredCommunities.length) {
      endIndex = _filteredCommunities.length;
    }
    return _filteredCommunities.sublist(startIndex, endIndex);
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      setState(() {
        currentPage = page;
      });
    }
  }

  Future<void> _confirmLeave(CommunityEntry community) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Leave community?"),
        content: Text(
            'Are you sure you want to leave "${community.name}" community?\nYou can rejoin later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Leave", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok == true) {
      _leave(community);
    }
  }

  Future<void> _leave(CommunityEntry community) async {
    final request = context.read<CookieRequest>();
    final ok = await CommunityService.leaveCommunity(request, community.id);

    if (!mounted) return;

    if (ok) {
      setState(() {
        _myCommunities.removeWhere((c) => c.id == community.id);
        _filteredCommunities.removeWhere((c) => c.id == community.id);
        _calculateTotalPages();
        if (currentPage > totalPages) {
          currentPage = totalPages;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have left "${community.name}" community.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to leave community."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPagination() {
    List<Widget> pageButtons = [];

    // Previous button
    pageButtons.add(
      GestureDetector(
        onTap: currentPage > 1 ? () => _goToPage(currentPage - 1) : null,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: currentPage > 1 ? AppColors.card : AppColors.card.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '<',
              style: TextStyle(
                color: currentPage > 1 ? AppColors.textWhite : AppColors.textLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );

    // Page numbers
    for (int i = 1; i <= totalPages; i++) {
      pageButtons.add(
        GestureDetector(
          onTap: () => _goToPage(i),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: i == currentPage ? AppColors.gold : AppColors.card,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$i',
                style: TextStyle(
                  color: i == currentPage ? AppColors.indigoDark : AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Next button
    pageButtons.add(
      GestureDetector(
        onTap: currentPage < totalPages ? () => _goToPage(currentPage + 1) : null,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: currentPage < totalPages ? AppColors.card : AppColors.card.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '>',
              style: TextStyle(
                color: currentPage < totalPages ? AppColors.textWhite : AppColors.textLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: pageButtons,
    );
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

              // ===== TITLE =====
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    "MY COMMUNITY",
                    style: TextStyle(
                      color: AppColors.indigoDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ===== SEARCH BAR =====
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: AppColors.textWhite, fontSize: 14),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: "Search communities you have joined",
                    hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
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

              // ===== LIST =====
              Expanded(
                child: _loading
                    ? Center(
                        child: CircularProgressIndicator(color: AppColors.gold),
                      )
                    : _filteredCommunities.isEmpty
                        ? Center(
                            child: Text(
                              "No communities found.",
                              style: TextStyle(color: AppColors.textLight),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _getPaginatedCommunities().length,
                            itemBuilder: (_, i) {
                              return MyCommunityCard(
                                community: _getPaginatedCommunities()[i],
                                onLeave: () => _confirmLeave(_getPaginatedCommunities()[i]),
                              );
                            },
                          ),
              ),

              // ===== PAGINATION =====
              if (!_loading && _filteredCommunities.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildPagination(),
                const SizedBox(height: 20),
              ],

              // ===== BACK TO COMMUNITY BUTTON =====
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      "BACK TO COMMUNITY",
                      style: TextStyle(
                        color: AppColors.indigoDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
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