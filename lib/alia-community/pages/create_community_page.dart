import 'package:flutter/material.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';
import 'package:kulatih_mobile/navigationbar.dart';
import '../services/community_service.dart';

class CreateCommunityPage extends StatefulWidget {
  const CreateCommunityPage({super.key});

  @override
  State<CreateCommunityPage> createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final nameController = TextEditingController();
  final shortDescController = TextEditingController();
  final longDescController = TextEditingController();

  bool isSubmitting = false;

  void submit() async {
    setState(() => isSubmitting = true);

    final success = await CommunityService.createCommunity(
      context,
      nameController.text,
      shortDescController.text,
      longDescController.text,
    );

    setState(() => isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Community Created!")));

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to Create")));
    }
  }

  Widget inputField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: AppColors.textWhite, fontSize: 14)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.textWhite,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: label,
              hintStyle: TextStyle(color: AppColors.textLight),
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
      backgroundColor: AppColors.indigoDark,
      bottomNavigationBar: const NavBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("MAKE YOUR OWN COMMUNITY",
                  style: TextStyle(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
              const SizedBox(height: 30),

              inputField("Community name?", nameController),
              inputField("Quick description", shortDescController),
              inputField("Tell us more about your community",
                  longDescController,
                  maxLines: 4),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: isSubmitting ? null : submit,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: isSubmitting
                      ? CircularProgressIndicator(color: AppColors.indigoDark)
                      : Text(
                          "MAKE COMMUNITY",
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
