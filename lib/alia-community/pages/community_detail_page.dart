import 'package:flutter/material.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';
import '../models/community.dart';
import '../services/community_service.dart';
import 'community_chat_page.dart';
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

  /// ===========================
  /// LOAD DETAIL + STATUS MEMBER
  /// ===========================
  Future<void> _loadDetail() async {
    final request = context.read<CookieRequest>();

    final detail =
        await CommunityService.getCommunityDetail(request, widget.community.id);

    setState(() {
      isMember = detail?["is_member"] == true;

      // update jumlah member
      if (detail?["members_count"] != null) {
        widget.community.membersCount = detail!["members_count"];
      }

      loading = false;
    });
  }

  /// ===========================
  /// HANDLE JOIN
  /// ===========================
  Future<void> _joinCommunity() async {
    final request = context.read<CookieRequest>();

    final updated =
        await CommunityService.joinCommunity(request, widget.community.id);

    if (updated != null) {
      // After join → redirect ke MyCommunityPage + kirim notif
      Navigator.pushReplacementNamed(
        context,
        "/my-community",
        arguments: {
          "joinedCommunityName": widget.community.name,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to join community."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: AppColors.indigoDark,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.indigoDark,
      appBar: AppBar(
        backgroundColor: AppColors.indigoDark,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textWhite),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // =====================
              // COMMUNITY NAME
              // =====================
              Center(
                child: Text(
                  widget.community.name,
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // =====================
              // MEMBERS COUNT
              // =====================
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                  decoration: BoxDecoration(
                    color: AppColors.indigo,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Members: ${widget.community.membersCount}",
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // =====================
              // FULL DESCRIPTION
              // =====================
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    widget.community.fullDescription,
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ===============================
              //    BUTTON JOIN / CHAT
              // ===============================
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
