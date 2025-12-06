import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kulatih_mobile/albert-user/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RegisterCoachPage extends StatefulWidget {
  const RegisterCoachPage({super.key});

  @override
  State<RegisterCoachPage> createState() => _RegisterCoachPageState();
}

class _RegisterCoachPageState extends State<RegisterCoachPage> {
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hourlyFeeController = TextEditingController();
  
  String _selectedSport = 'gym';
  
  final List<Map<String, String>> _sports = [
    {'value': 'gym', 'label': 'Gym & Fitness'},
    {'value': 'football', 'label': 'Football'},
    {'value': 'futsal', 'label': 'Futsal'},
    {'value': 'basketball', 'label': 'Basketball'},
    {'value': 'tennis', 'label': 'Tennis'},
    {'value': 'badminton', 'label': 'Badminton'},
    {'value': 'swimming', 'label': 'Swimming'},
    {'value': 'yoga', 'label': 'Yoga'},
    {'value': 'martial_arts', 'label': 'Martial Arts'},
    {'value': 'golf', 'label': 'Golf'},
    {'value': 'volleyball', 'label': 'Volleyball'},
    {'value': 'running', 'label': 'Running'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1625),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1625),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontFamily: 'BebasNeue', fontSize: 32),
            children: [
              TextSpan(text: 'KU', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'LATIH', style: TextStyle(color: Color(0xFFE8B923))),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text(
                'Sign In to Continue',
                style: TextStyle(
                  fontFamily: 'BeVietnamPro',
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              // Username
              _buildTextField(_usernameController, 'Username'),
              const SizedBox(height: 16),
              
              // First name & Last name
              Row(
                children: [
                  Expanded(child: _buildTextField(_firstNameController, 'First name')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_lastNameController, 'Last name')),
                ],
              ),
              const SizedBox(height: 16),
              
              // Email
              _buildTextField(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              
              // Password
              _buildTextField(_passwordController, 'Password', isPassword: true),
              const SizedBox(height: 16),
              
              // Confirm Password
              _buildTextField(_confirmPasswordController, 'Confirm Password', isPassword: true),
              const SizedBox(height: 16),
              
              // City
              _buildTextField(_cityController, 'City'),
              const SizedBox(height: 16),
              
              // Phone
              _buildTextField(_phoneController, 'Phone', keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              
              // Sport Dropdown
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE8B923),
                    width: 2,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSport,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF2A2438),
                    style: const TextStyle(
                      fontFamily: 'BeVietnamPro',
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    icon: const Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.arrow_drop_down, color: Color(0xFFE8B923)),
                    ),
                    items: _sports.map((sport) {
                      return DropdownMenuItem<String>(
                        value: sport['value'],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(sport['label']!),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSport = newValue!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Hourly Fee
              _buildTextField(_hourlyFeeController, 'Hourly fee', keyboardType: TextInputType.number),
              const SizedBox(height: 32),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    String username = _usernameController.text.trim();
                    String firstName = _firstNameController.text.trim();
                    String lastName = _lastNameController.text.trim();
                    String email = _emailController.text.trim();
                    String password1 = _passwordController.text;
                    String password2 = _confirmPasswordController.text;
                    String city = _cityController.text.trim();
                    String phone = _phoneController.text.trim();
                    String hourlyFee = _hourlyFeeController.text.trim();

                    // Validation
                    if (username.isEmpty || password1.isEmpty || password2.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Username and password are required!',
                            style: TextStyle(fontFamily: 'BeVietnamPro'),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (password1 != password2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Passwords do not match!',
                            style: TextStyle(fontFamily: 'BeVietnamPro'),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (password1.length < 8) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Password must be at least 8 characters!',
                            style: TextStyle(fontFamily: 'BeVietnamPro'),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // API Call
                    try {
                      final response = await request.postJson(
                        "http://localhost:8000/auth/register/",
                        jsonEncode({
                          "username": username,
                          "first_name": firstName,
                          "last_name": lastName,
                          "email": email,
                          "password1": password1,
                          "password2": password2,
                          "city": city,
                          "phone": phone,
                          "sport": _selectedSport,
                          "hourly_fee": hourlyFee.isEmpty ? "0" : hourlyFee,
                          "role": "coach",
                        }),
                      );

                      if (context.mounted) {
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Registration successful! Please login.',
                                style: TextStyle(fontFamily: 'BeVietnamPro'),
                              ),
                              backgroundColor: Color(0xFFE8B923),
                            ),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Registration failed: ${response['message']}',
                                style: const TextStyle(fontFamily: 'BeVietnamPro'),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error: $e',
                              style: const TextStyle(fontFamily: 'BeVietnamPro'),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8B923),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 24,
                      color: Color(0xFF1A1625),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Login Link
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: const Text(
                  'Already have an account? Log In',
                  style: TextStyle(
                    fontFamily: 'BeVietnamPro',
                    color: Colors.white,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
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
    String hint, {
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: 'BeVietnamPro',
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'BeVietnamPro',
          color: Colors.white54,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE8B923),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE8B923),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE8B923),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}