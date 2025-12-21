import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:kulatih_mobile/models/user_provider.dart';
import 'package:kulatih_mobile/theme/app_colors.dart';
import 'package:kulatih_mobile/albert-user/widgets/coach_card.dart'; // For sportChoices

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers for form fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _cityController;
  late TextEditingController _phoneController;
  late TextEditingController _descriptionController;
  late TextEditingController
  _profilePhotoController; // Controller for photo URL

  // Coach-specific fields
  late TextEditingController _hourlyFeeController;
  String? _selectedSport;

  // For image preview
  String _photoPreviewUrl = '';

  @override
  void initState() {
    super.initState();
    final userProfile = context.read<UserProvider>().userProfile;

    // Pre-fill form with existing data
    _firstNameController = TextEditingController(
      text: userProfile?.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: userProfile?.lastName ?? '',
    );
    _emailController = TextEditingController(text: userProfile?.email ?? '');
    _cityController = TextEditingController(
      text: userProfile?.profile?.city ?? '',
    );
    _phoneController = TextEditingController(
      text: userProfile?.profile?.phone ?? '',
    );
    _descriptionController = TextEditingController(
      text: userProfile?.profile?.description ?? '',
    );
    _profilePhotoController = TextEditingController(
      text: userProfile?.profile?.profilePhoto ?? '',
    );
    _photoPreviewUrl = userProfile?.profile?.profilePhoto ?? '';

    // Update preview on text change
    _profilePhotoController.addListener(() {
      if (mounted && _profilePhotoController.text != _photoPreviewUrl) {
        setState(() {
          _photoPreviewUrl = _profilePhotoController.text;
        });
      }
    });

    if (userProfile?.isCoach ?? false) {
      _hourlyFeeController = TextEditingController(
        text: userProfile?.profile?.hourlyFee?.toString() ?? '0',
      );
      _selectedSport = userProfile?.profile?.sport;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _profilePhotoController.dispose();
    if (context.read<UserProvider>().isCoach) {
      _hourlyFeeController.dispose();
    }
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final request = context.read<CookieRequest>();
    final userProvider = context.read<UserProvider>();

    final Map<String, dynamic> data = {
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'email': _emailController.text,
      'city': _cityController.text,
      'phone': _phoneController.text,
      'description': _descriptionController.text,
      'profile_photo': _profilePhotoController.text, // Add photo URL to payload
    };

    if (userProvider.isCoach) {
      data['sport'] = _selectedSport;
      data['hourly_fee'] = int.tryParse(_hourlyFeeController.text) ?? 0;
    }

    try {
      final response = await request.postJson(
        "https://muhammad-salman42-kulatih.pbp.cs.ui.ac.id/account/edit-profile-flutter/",
        jsonEncode(data),
      );

      if (context.mounted) {
        if (response['status'] == true) {
          final currentUser = userProvider.userProfile!;
          final updatedUserJson = {
            ...currentUser.toJson(),
            ...response['user'],
            'profile': {
              ...currentUser.profile!.toJson(),
              ...response['profile'],
            },
          };

          final finalUserData = Map<String, dynamic>.from(updatedUserJson);
          finalUserData['profile'] = Map<String, dynamic>.from(
            updatedUserJson['profile'],
          );

          userProvider.login(finalUserData);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile updated successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${response['message']}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: AppColors.navBarBg,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PROFILE PHOTO
              const Center(
                child: Text(
                  "PROFILE PHOTO",
                  style: TextStyle(
                    color: AppColors.textHeading,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_photoPreviewUrl.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://muhammad-salman42-kulatih.pbp.cs.ui.ac.id/account/proxy-image/?url=${Uri.encodeComponent(_photoPreviewUrl)}',
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(
                            Icons.no_photography,
                            color: Colors.white54,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              _buildTextField(_profilePhotoController, "Image URL"),
              const SizedBox(height: 24),

              // USER INFORMATION
              const Center(
                child: Text(
                  "USER INFORMATION",
                  style: TextStyle(
                    color: AppColors.textHeading,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(_firstNameController, "First Name"),
              const SizedBox(height: 16),
              _buildTextField(_lastNameController, "Last Name"),
              const SizedBox(height: 16),
              _buildTextField(
                _emailController,
                "Email",
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(_cityController, "City"),
              const SizedBox(height: 16),
              _buildTextField(
                _phoneController,
                "Phone",
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _descriptionController,
                "Description",
                maxLines: 4,
              ),

              if (userProvider.isCoach) ...[
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    "Coach Information",
                    style: TextStyle(
                      color: AppColors.textHeading,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSportDropdown(),
                const SizedBox(height: 16),
                _buildTextField(
                  _hourlyFeeController,
                  "Hourly Fee (IDR)",
                  keyboardType: TextInputType.number,
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.buttonText,
                        )
                      : const Text(
                          "Save Changes",
                          style: TextStyle(
                            color: AppColors.buttonText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.cardBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
      ),
    );
  }

  Widget _buildSportDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSport,
      items: sportChoices.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSport = value;
        });
      },
      decoration: InputDecoration(
        labelText: "Sport",
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.cardBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
      ),
      dropdownColor: AppColors.cardBg,
      style: const TextStyle(color: AppColors.textPrimary),
    );
  }
}
