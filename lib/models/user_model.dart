class UserProfile {
  final String username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String role;
  final ProfileData profile;

  UserProfile({
    required this.username,
    this.firstName,
    this.lastName,
    this.email,
    required this.role,
    required this.profile,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      role: json['role'],
      profile: ProfileData.fromJson(json['profile'], json['role']),
    );
  }

  bool get isCoach => role == 'coach';
  bool get isMember => role == 'member';
  
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    }
    return username;
  }
}

class ProfileData {
  final String id;
  final String city;
  final String phone;
  final String? description;
  final String? profilePhoto;
  
  // Coach-specific fields
  final String? sport;
  final int? hourlyFee;

  ProfileData({
    required this.id,
    required this.city,
    required this.phone,
    this.description,
    this.profilePhoto,
    this.sport,
    this.hourlyFee,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json, String role) {
    return ProfileData(
      id: json['id'],
      city: json['city'],
      phone: json['phone'],
      description: json['description'],
      profilePhoto: json['profile_photo'],
      sport: role == 'coach' ? json['sport'] : null,
      hourlyFee: role == 'coach' ? json['hourly_fee'] : null,
    );
  }

  String get sportLabel {
    const sportLabels = {
      'gym': 'Gym & Fitness',
      'football': 'Football',
      'futsal': 'Futsal',
      'basketball': 'Basketball',
      'tennis': 'Tennis',
      'badminton': 'Badminton',
      'swimming': 'Swimming',
      'yoga': 'Yoga',
      'martial_arts': 'Martial Arts',
      'golf': 'Golf',
      'volleyball': 'Volleyball',
      'running': 'Running',
      'other': 'Other',
    };
    return sportLabels[sport ?? 'other'] ?? 'Other';
  }
}