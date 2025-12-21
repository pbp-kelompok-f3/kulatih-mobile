class UserProfile {
  final String username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String role;
  final ProfileData? profile;

  UserProfile({
    required this.username,
    this.firstName,
    this.lastName,
    this.email,
    required this.role,
    this.profile,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      role: json['role'],
      profile: json['profile'] != null 
          ? ProfileData.fromJson(json['profile'], json['role']) 
          : null,
    );
  }

  bool get isCoach => role == 'coach';
  bool get isMember => role == 'member';
  
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return username;
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'role': role,
        'profile': profile?.toJson(),
      };
}

class ProfileData {
  final String? id;
  final String? city;
  final String? phone;
  final String? description;
  final String? profilePhoto;
  
  // Coach-specific fields
  final String? sport;
  final int? hourlyFee;

  ProfileData({
    this.id,
    this.city,
    this.phone,
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
      hourlyFee: role == 'coach' ? (json['hourly_fee'] as num?)?.toInt() : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'city': city,
        'phone': phone,
        'description': description,
        'profile_photo': profilePhoto,
        'sport': sport,
        'hourly_fee': hourlyFee,
      };

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