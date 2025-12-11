// To parse this JSON data, do
//
//     final communityEntry = communityEntryFromJson(jsonString);

import 'dart:convert';

List<CommunityEntry> communityEntryFromJson(String str) => List<CommunityEntry>.from(json.decode(str).map((x) => CommunityEntry.fromJson(x)));

String communityEntryToJson(List<CommunityEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CommunityEntry {
    int id;
    String name;
    String shortDescription;
    String fullDescription;
    String? profileImageUrl;
    int membersCount;
    DateTime createdAt;
    CreatedBy createdBy;

    CommunityEntry({
        required this.id,
        required this.name,
        required this.shortDescription,
        required this.fullDescription,
        required this.profileImageUrl,
        required this.membersCount,
        required this.createdAt,
        required this.createdBy,
    });

    factory CommunityEntry.fromJson(Map<String, dynamic> json) => CommunityEntry(
        id: json["id"],
        name: json["name"],
        shortDescription: json["short_description"],
        fullDescription: json["full_description"],
        profileImageUrl: json["profile_image_url"],
        membersCount: json["members_count"],
        createdAt: DateTime.parse(json["created_at"]),
        createdBy: createdByValues.map[json["created_by"]]!,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "short_description": shortDescription,
        "full_description": fullDescription,
        "profile_image_url": profileImageUrl,
        "members_count": membersCount,
        "created_at": createdAt.toIso8601String(),
        "created_by": createdByValues.reverse[createdBy],
    };
}

enum CreatedBy {
    ADMIN,
    PEW
}

final createdByValues = EnumValues({
    "admin": CreatedBy.ADMIN,
    "pew": CreatedBy.PEW
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
