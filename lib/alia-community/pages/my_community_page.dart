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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// ================================
  /// LOAD DATA COMMUNITIES
  /// ================================
  Future<void> _load() async {
    final request = context.read<CookieRequest>();
    final data = await CommunityService.getMyCommunities(request);

    setState(() {
      _myCommunities = data;
      _loading = false;
    });
  }

  /// ================================
  /// SHOW LEAVE CONFIRMATION POP-UP
  /// ================================
  Future<void> _confirmLeave(CommunityEntry community) async {
    final shouldLeave = await showDialog<bool>(
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
            child: const Text(
              "Leave",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldLeave == true) {
      await _leave(community);
    }
  }

  /// ================================
  /// API LEAVE + INSTANT REMOVE + SNACKBAR
  /// ================================
  Future<void> _leave(CommunityEntry community) async {
    print('🔵 Leaving community: ${community.name}'); // DEBUG
    
    final request = context.read<CookieRequest>();
    final result = await CommunityService.leaveCommunity(request, community.id);

    print('🔵 Leave result: $result'); // DEBUG

    if (!mounted) return;

    if (result) {
      // ✅ Berhasil leave - hapus dari list
      setState(() {
        _myCommunities.removeWhere((c) => c.id == community.id);
      });

      print('✅ Successfully left community'); // DEBUG

      // ✅ Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have left "${community.name}" community.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      print('🔴 Failed to leave community'); // DEBUG
      
      // ❌ Gagal leave
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to leave community."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// ================================
  /// BUILD UI
  /// ================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.indigoDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // TITLE
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
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
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // SEARCH BAR (belum aktif, dekorasi saja)
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
                    suffixIcon:
                        Icon(Icons.search, color: AppColors.indigoDark),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // LIST OF COMMUNITIES
              Expanded(
                child: _loading
                    ? Center(
                        child:
                            CircularProgressIndicator(color: AppColors.gold),
                      )
                    : _myCommunities.isEmpty
                        ? Center(
                            child: Text(
                              "You haven't joined any community yet.",
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _myCommunities.length,
                            itemBuilder: (context, index) {
                              final c = _myCommunities[index];
                              return MyCommunityCard(
                                community: c,
                                onLeave: () => _confirmLeave(c),
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