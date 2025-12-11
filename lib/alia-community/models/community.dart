class Community {
  final int id;
  final String name;
  final String shortDescription;
  final String description;
  final int membersCount;
  final bool isMember;

  Community({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.description,
    required this.membersCount,
    required this.isMember,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] as int,
      name: json['name'] as String,
      shortDescription: json['short_description'] as String? ?? '',
      description: json['description'] as String? ?? '',
      membersCount: json['members_count'] as int? ?? 0,
      isMember: json['is_member'] as bool? ?? false,
    );
  }
}
