class Community {
  final int id;
  final String name;
  final String shortDescription;
  final String fullDescription;
  final int membersCount;
  final bool isMember;

  Community({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.fullDescription,
    required this.membersCount,
    required this.isMember,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'],
      name: json['name'],
      shortDescription: json['short_description'] ?? '',
      fullDescription: json['full_description'] ?? '',
      membersCount: json['members_count'] ?? 0,
      isMember: json['is_member'] ?? false,
    );
  }
}
