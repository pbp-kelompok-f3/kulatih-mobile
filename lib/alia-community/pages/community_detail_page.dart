import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';
import '../models/community.dart';
import '../services/community_service.dart';
import 'community_chat_page.dart';
import 'my_community_page.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class CommunityDetailPage extends StatefulWidget {
  final CommunityEntry community;

  const CommunityDetailPage({
    super.key,
    required this.community,
  });

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  bool? isMember;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final request = context.read<CookieRequest>();

    final detail =
        await CommunityService.getCommunityDetail(request, widget.community.id);

    setState(() {
      isMember = detail?["is_member"] == true;

      if (detail?["members_count"] != null) {
        widget.community.membersCount = detail!["members_count"];
      }

      loading = false;
    });
  }

  Future<void> _joinCommunity() async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.postJson(
        "${CommunityService.baseUrl}/join/${widget.community.id}/json/",
        jsonEncode({}),
      );

      if (!mounted) return;

      if (response != null &&
          (response["success"] == true || response["community"] != null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('You\'ve joined "${widget.community.name}" community.'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 250));

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyCommunityPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to join community."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: AppColors.indigo,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
      );
    }

    final proxiedImageUrl = CommunityService.getProxiedImageUrl(
      widget.community.profileImageUrl,
    );

    return Scaffold(
      backgroundColor: AppColors.indigo,
      appBar: AppBar(
        backgroundColor: AppColors.indigo,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textWhite),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Profile Picture
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: proxiedImageUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          proxiedImageUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: AppColors.indigo,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.white,
                            );
                          },
                        ),
                      )
                    : Container(), // Empty white circle if no image
              ),

              const SizedBox(height: 16),

              // Judul
              Text(
                widget.community.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Members count
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "Members: ${widget.community.membersCount}",
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Full Description
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          widget.community.fullDescription,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Join / Go to group chat button
              isMember == true
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CommunityChatPage(community: widget.community),
                          ),
                        );
                      },
                      child: Text(
                        "GO TO GROUP CHAT",
                        style: TextStyle(
                          color: AppColors.indigoDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _joinCommunity,
                      child: Text(
                        "JOIN US NOW",
                        style: TextStyle(
                          color: AppColors.indigoDark,
                          fontWeight: FontWeight.bold,
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