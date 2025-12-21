// To parse this JSON data, do
//
//     final Coach = coachFromJson(jsonString);

import 'dart:convert';

List<Coach> coachFromJson(String str) =>
    List<Coach>.from(json.decode(str).map((x) => Coach.fromJson(x)));

String coachToJson(List<Coach> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Coach {
  String id;
  String username;
  String fullName;
  String sport;
  String city;
  int hourlyFee;
  String description;
  String profilePhoto;

  Coach({
    required this.id,
    required this.username,
    required this.fullName,
    required this.sport,
    required this.city,
    required this.hourlyFee,
    required this.description,
    required this.profilePhoto,
  });

  factory Coach.fromJson(Map<String, dynamic> json) => Coach(
    id: json["id"],
    username: json["username"],
    fullName: json["full_name"],
    sport: json["sport"],
    city: json["city"],
    hourlyFee: (json["hourly_fee"] as num).toInt(),
    description: json["description"]?.toString() ?? '',
    profilePhoto: json["profile_photo"]?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "full_name": fullName,
    "sport_display": sport,
    "city": city,
    "hourly_fee": hourlyFee,
    "description": description,
    "profile_photo": profilePhoto,
  };
}
