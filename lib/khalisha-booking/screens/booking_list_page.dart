class Booking {
  final int id;
  final String status;
  final String name;          // coach or member depending role
  final String sport;
  final String imageUrl;
  final String location;
  final DateTime date;
  final String startTime;
  final String endTime;

  Booking({
    required this.id,
    required this.status,
    required this.name,
    required this.sport,
    required this.imageUrl,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  /// Convert JSON → Booking object
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json["id"],
      status: json["status"],
      name: json["coach_name"] ?? json["member_name"] ?? "Unknown",
      sport: json["sport"] ?? "",
      imageUrl: json["avatar"] ?? "",
      location: json["location"] ?? "-",
      date: DateTime.parse(json["date"]),
      startTime: json["start_time"],
      endTime: json["end_time"],
    );
  }

  /// For UI
  String get formattedDateTime {
    return "${dateForm()} • $startTime – $endTime WIB";
  }

  String dateForm() {
    final months = [
      "", "January", "February", "March", "April", "May",
      "June", "July", "August", "September", "October",
      "November", "December"
    ];
    return "${date.day} ${months[date.month]} ${date.year}";
  }

  bool get isUpcoming {
    final now = DateTime.now();
    return date.isAfter(now) && status != "completed" && status != "cancelled";
  }

  bool get isHistory {
    return !isUpcoming;
  }
}
