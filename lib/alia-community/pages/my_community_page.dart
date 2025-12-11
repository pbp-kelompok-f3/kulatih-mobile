import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';
import '../models/community.dart';
import '../services/community_service.dart';
import '../widgets/my_community_card.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class MyCommunityPage extends StatefulWidget {
  const MyCommunityPage({super.key});

  @override
  State<MyCommunityPage> createState() => _MyCommunityPageState();
}

class _MyCommunityPageState extends State<MyCommunityPage> {
  List<Community> _myCommunities = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final request = context.read<CookieRequest>();

    final data = await CommunityService.getJoinedCommunities(request);

    setState(() {
      _myCommunities = data;
      _loading = false;
    });
  }

  Future<void> _leave(int id) async {
    final request = context.read<CookieRequest>();

    await CommunityService.leaveCommunity(request, id);

    _load();
  }

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
                child: _loading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.gold,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _myCommunities.length,
                        itemBuilder: (context, index) {
                          final c = _myCommunities[index];
                          return MyCommunityCard(
                            community: c,
                            onLeave: () => _leave(c.id),
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
