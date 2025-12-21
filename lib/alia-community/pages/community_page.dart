import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'package:kulatih_mobile/constants/app_colors.dart';
import '../models/community.dart';
import '../services/community_service.dart';
import '../widgets/community_card.dart';

import 'my_community_page.dart';
import 'create_community_page.dart';
import 'community_detail_page.dart';

import 'package:kulatih_mobile/app_bar.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with AutomaticKeepAliveClientMixin {
  List<CommunityEntry> all = [];
  List<CommunityEntry> filtered = [];
  bool loading = true;

  final TextEditingController _searchController = TextEditingController();

  // Pagination
  int currentPage = 1;
  final int itemsPerPage = 6;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    fetchCommunities();
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load communities
  Future<void> fetchCommunities() async {
    if (mounted) {
      setState(() => loading = true);
    }
    
    try {
      final request = context.read<CookieRequest>();
      final data = await CommunityService.getAllCommunities(request);

      if (!mounted) return;

      setState(() {
        all = data;
        // Reapply filter setelah refresh
        _filter();
        loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
      }
      print('Error fetching communities: $e');
    }
  }

  /// Filter untuk search bar
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
      
      // Reset ke page 1 jika filter berubah
      if (currentPage > totalPages && totalPages > 0) {
        currentPage = 1;
      }
    });
  }

  /// Pagination helper
  int get totalPages =>
      filtered.isEmpty ? 1 : (filtered.length / itemsPerPage).ceil();

  List<CommunityEntry> get paginated {
    if (filtered.isEmpty) return [];
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

  /// PAGINATION UI (BOTTOM ONLY)
  Widget _buildPagination() {
    if (filtered.isEmpty) return const SizedBox.shrink();
    
    return Wrap(
      spacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _pageBtn('<', currentPage > 1 ? currentPage - 1 : null),
        for (int i = 1; i <= totalPages; i++)
          _pageBtn('$i', i, active: i == currentPage),
        _pageBtn('>', currentPage < totalPages ? currentPage + 1 : null),
      ],
    );
  }

  Widget _pageBtn(String label, int? page, {bool active = false}) {
    return GestureDetector(
      onTap: page == null ? null : () => _goToPage(page),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: active ? AppColors.gold : AppColors.card,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: active
                ? AppColors.indigoDark
                : page == null
                    ? AppColors.textLight
                    : AppColors.textWhite,
          ),
        ),
      ),
    );
  }

  /// UI
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: const KulatihAppBar(),
      backgroundColor: AppColors.indigo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "WELCOME TO OUR COMMUNITY",
                  style: TextStyle(
                    color: AppColors.indigoDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Search bar
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
                    hintText: "Search community to join",
                    hintStyle: TextStyle(color: AppColors.textLight),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Navigation Buttons
              Row(
                children: [
                  Expanded(
                    child: _navBtn(
                      "MY COMMUNITY",
                      () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyCommunityPage(),
                          ),
                        );

                        // Refresh buat fetch ulang kalau ada perubahan
                        if (mounted) {
                          await fetchCommunities();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _navBtn(
                      "MAKE COMMUNITY",
                      () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateCommunityPage(),
                          ),
                        );
                        if (mounted) {
                          await fetchCommunities();
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              //List of communities
              Expanded(
                child: RefreshIndicator(
                  onRefresh: fetchCommunities,
                  color: AppColors.gold,
                  child: loading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.gold,
                          ),
                        )
                      : filtered.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.4,
                                ),
                                Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 64,
                                        color: AppColors.textLight,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No communities found',
                                        style: TextStyle(
                                          color: AppColors.textLight,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              key: ValueKey('community_list_${all.length}'),
                              itemCount: paginated.length + 1,
                              itemBuilder: (_, i) {
                                if (i < paginated.length) {
                                  final c = paginated[i];
                                  return CommunityCard(
                                    key: ValueKey('community_${c.id}'),
                                    community: c,
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              CommunityDetailPage(community: c),
                                        ),
                                      );
                                      if (mounted) {
                                        await fetchCommunities();
                                      }
                                    },
                                  );
                                }

                                // Pagination
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 30),
                                  child: _buildPagination(),
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navBtn(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}