import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'package:kulatih_mobile/constants/app_colors.dart';
import '../services/community_service.dart';
import '../pages/my_community_page.dart';

class CreateCommunityPage extends StatefulWidget {
  const CreateCommunityPage({super.key});

  @override
  State<CreateCommunityPage> createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final _name = TextEditingController();
  final _short = TextEditingController();
  final _long = TextEditingController();
<<<<<<< HEAD
=======
  final _profilePicture = TextEditingController();
>>>>>>> 26f881cfd85d4334a73816b8428d92ab95e6f3b1

  bool _submitting = false;

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty ||
        _short.text.trim().isEmpty ||
        _long.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
        const SnackBar(content: Text("Please fill in all fields")),
=======
        const SnackBar(content: Text("Please fill in all required fields")),
>>>>>>> 26f881cfd85d4334a73816b8428d92ab95e6f3b1
      );
      return;
    }

    setState(() => _submitting = true);

    final request = context.read<CookieRequest>();

    final newCommunity = await CommunityService.createCommunity(
      request,
      _name.text.trim(),
      _short.text.trim(),
      _long.text.trim(),
<<<<<<< HEAD
      null,
=======
      _profilePicture.text.trim().isEmpty ? null : _profilePicture.text.trim(),
>>>>>>> 26f881cfd85d4334a73816b8428d92ab95e6f3b1
    );

    setState(() => _submitting = false);

    if (!mounted) return;

    if (newCommunity != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Community successfully created!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyCommunityPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create community")),
      );
    }
  }

  Widget _field(String label, TextEditingController controller,
<<<<<<< HEAD
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
=======
      {int maxLines = 1, bool optional = false, String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            if (optional)
              Text(
                " (optional)",
                style: TextStyle(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
          ],
>>>>>>> 26f881cfd85d4334a73816b8428d92ab95e6f3b1
        ),
        const SizedBox(height: 8),

        // Input box
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(
              color: AppColors.indigoDark,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
<<<<<<< HEAD
=======
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
>>>>>>> 26f881cfd85d4334a73816b8428d92ab95e6f3b1
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: AppColors.indigo,   
=======
      backgroundColor: AppColors.indigo,
>>>>>>> 26f881cfd85d4334a73816b8428d92ab95e6f3b1
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Judul
              Text(
                "MAKE YOUR OWN\nCOMMUNITY",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),

              const SizedBox(height: 40),

              // Form box
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
<<<<<<< HEAD
                  color: AppColors.indigoDark,  
=======
                  color: AppColors.indigoDark,
>>>>>>> 26f881cfd85d4334a73816b8428d92ab95e6f3b1
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _field("Community name", _name),
                    _field("Quick description", _short),
                    _field("Tell us more about your community", _long,
                        maxLines: 6),
<<<<<<< HEAD
=======
                    _field("Profile Picture", _profilePicture, 
                        optional: true, 
                        hintText: "URL HTTPS"),
>>>>>>> 26f881cfd85d4334a73816b8428d92ab95e6f3b1

                    const SizedBox(height: 10),

                    // Submit button
                    GestureDetector(
                      onTap: _submitting ? null : _submit,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: _submitting
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.indigoDark,
                                ),
                              )
                            : Text(
                                "MAKE COMMUNITY",
                                style: TextStyle(
                                  color: AppColors.indigoDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 26f881cfd85d4334a73816b8428d92ab95e6f3b1
