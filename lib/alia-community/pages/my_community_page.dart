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
  List<CommunityEntry> all = [];
  List<CommunityEntry> filtered = [];
  bool loading = true;
  bool hasChanges = false; // 🔥 TRACK CHANGES

  final TextEditingController _searchController = TextEditingController();

  int currentPage = 1;
  final int itemsPerPage = 6;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// ================================
  /// LOAD DATA
  /// ================================
  Future<void> _load() async {
    final request = context.read<CookieRequest>();
    final data = await CommunityService.getMyCommunities(request);

    if (!mounted) return;

    setState(() {
      all = data;
      filtered = data;
      loading = false;
    });
  }

  /// ================================
  /// SEARCH
  /// ================================
  void _filter() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      filtered = q.isEmpty
          ? all
          : all.where((c) {
              return c.name.toLowerCase().contains(q) ||
                  c.shortDescription.toLowerCase().contains(q) ||
                  c.fullDescription.toLowerCase().contains(q);
            }).toList();
      currentPage = 1;
    });
  }

  /// ================================
  /// PAGINATION
  /// ================================
  int get totalPages =>
      (filtered.length / itemsPerPage).ceil().clamp(1, 999);

  List<CommunityEntry> get paginated {
    final start = (currentPage - 1) * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, filtered.length);
    if (start >= filtered.length) return [];
    return filtered.sublist(start, end);
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      setState(() => currentPage = page);
    }
  }

  /// ================================
  /// LEAVE
  /// ================================
  Future<void> _confirmLeave(CommunityEntry community) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Leave community?"),
        content: Text(
          'Are you sure you want to leave "${community.name}" community?\nYou can rejoin later.',
        ),
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
        all.removeWhere((c) => c.id == community.id);
        filtered.removeWhere((c) => c.id == community.id);
        if (currentPage > totalPages) currentPage = totalPages;
        hasChanges = true; // 🔥 MARK AS CHANGED
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You have left "${community.name}" community.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to leave community."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// ================================
  /// PAGINATION UI (BOTTOM ONLY)
  /// ================================
  Widget _buildPagination() {
    return Wrap(
      spacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _page('<', currentPage > 1 ? currentPage - 1 : null),
        for (int i = 1; i <= totalPages; i++)
          _page('$i', i, active: i == currentPage),
        _page('>', currentPage < totalPages ? currentPage + 1 : null),
      ],
    );
  }

  Widget _page(String t, int? p, {bool active = false}) {
    return GestureDetector(
      onTap: p == null ? null : () => _goToPage(p),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: active ? AppColors.gold : AppColors.card,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          t,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: active
                ? AppColors.indigoDark
                : p == null
                    ? AppColors.textLight
                    : AppColors.textWhite,
          ),
        ),
      ),
    );
  }

  /// ================================
  /// UI
  /// ================================
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // 🔥 INTERCEPT BACK BUTTON
      onWillPop: () async {
        Navigator.pop(context, hasChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.indigo,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // TITLE
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
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

                // SEARCH
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: AppColors.textWhite),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: "Search communities you joined",
                      hintStyle: TextStyle(color: AppColors.textLight),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // LIST + FOOTER
                Expanded(
                  child: loading
                      ? Center(
                          child:
                              CircularProgressIndicator(color: AppColors.gold),
                        )
                      : ListView.builder(
                          itemCount: paginated.length + 1,
                          itemBuilder: (_, i) {
                            if (i < paginated.length) {
                              return MyCommunityCard(
                                community: paginated[i],
                                onLeave: () => _confirmLeave(paginated[i]),
                              );
                            }

                            return Column(
                              children: [
                                const SizedBox(height: 30),
                                if (filtered.isNotEmpty) _buildPagination(),
                                const SizedBox(height: 20),
                                GestureDetector(
                                  onTap: () {
                                    // 🔥 RETURN hasChanges SIGNAL
                                    Navigator.pop(context, hasChanges);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 24),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "BACK TO COMMUNITY",
                                      style: TextStyle(
                                        color: AppColors.indigoDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}