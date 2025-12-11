import 'package:flutter/material.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';
import '../models/community.dart';
import 'community_chat_page.dart';
import '../services/community_service.dart';

class CommunityDetailPage extends StatelessWidget {
  final Community community;
  const CommunityDetailPage({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.indigoDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              CircleAvatar(
                radius: 45,
                backgroundColor: AppColors.textWhite,
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 6, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.indigo,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "JUMLAH ANGGOTA COMMUNITY",
                  style:
                      TextStyle(color: AppColors.gold, fontSize: 12),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                community.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    community.longDescription,
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () async {
                  final ok = await CommunityService.joinCommunity(
                      context, community.id);

                  if (ok) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              CommunityChatPage(community: community)),
                    );
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "JOIN US NOW",
                    style: TextStyle(
                        color: AppColors.indigoDark,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
