import 'package:flutter/material.dart';
import 'package:kulatih_mobile/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoggedIn = false;

  UserProfile? get userProfile => _userProfile;
  bool get isLoggedIn => _isLoggedIn;
  bool get isCoach => _userProfile?.isCoach ?? false;
  bool get isMember => _userProfile?.isMember ?? false;
  String? get username => _userProfile?.username;
  String? get role => _userProfile?.role;

  void login(Map<String, dynamic> userData) {
    _userProfile = UserProfile.fromJson(userData);
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _userProfile = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}