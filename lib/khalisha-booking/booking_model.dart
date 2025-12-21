import 'package:intl/intl.dart';

enum BookingStatus { pending, confirmed, rescheduled, cancelled, completed }

BookingStatus bookingStatusFromString(String value) {
  switch (value.toLowerCase().trim()) {
    case 'confirmed':
      return BookingStatus.confirmed;
    case 'rescheduled':
      return BookingStatus.rescheduled;
    case 'cancelled':
    case 'canceled':
      return BookingStatus.cancelled;
    case 'completed':
      return BookingStatus.completed;
    default:
      return BookingStatus.pending;
  }
}

String bookingStatusToText(BookingStatus status) {
  switch (status) {
    case BookingStatus.pending:
      return "Pending";
    case BookingStatus.confirmed:
      return "Confirmed";
    case BookingStatus.rescheduled:
      return "Rescheduled";
    case BookingStatus.cancelled:
      return "Cancelled";
    case BookingStatus.completed:
      return "Completed";
  }
}

class Booking {
  final int id;

  /// NEW FIELD → agar coach bisa lihat siapa membernya
  final String memberName;

  // buat modul review
  final String coachId;

  final String coachName;
  final String sport;
  final String location;

  final DateTime startTime;
  final DateTime endTime;

  final BookingStatus status;
  final String? imageUrl;

  Booking({
    required this.id,
    required this.memberName,
    required this.coachId,
    required this.coachName,
    required this.sport,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.imageUrl,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
  String _isoDT(String date, String time) {
    final t = (time.length == 5) ? "$time:00" : time;
    return "${date}T$t";
  }

  final date = json['date']?.toString() ?? '';
  final start = json['start_time']?.toString() ?? '00:00';
  final end = json['end_time']?.toString();

  final startDT = DateTime.parse(_isoDT(date, start));
  final endDT = end != null
      ? DateTime.parse(_isoDT(date, end))
      : startDT.add(const Duration(hours: 1));

  final coachIdVal =
      json['coach_id'] ??
      json['coachId'] ??
      json['coach_uuid'] ??
      (json['coach'] is Map ? (json['coach']['id'] ?? json['coach']['pk']) : null);

  return Booking(
    id: json['id'],
    memberName: json['member_name'] ?? "-",
    coachId: coachIdVal?.toString() ?? '',
    coachName: json['coach_name'] ?? "-",
    sport: json['sport'] ?? "-",
    location: json['location'] ?? "-",
    startTime: startDT,
    endTime: endDT,
    status: bookingStatusFromString(json['status']),
    imageUrl: json['image_url'] ?? json['imageUrl'] ?? json['coach_image_url'],
  );
}

  String get formattedDate => DateFormat('EEEE, dd MMM yyyy').format(startTime);

  String get formattedTimeRange {
    final s = DateFormat('HH:mm').format(startTime);
    final e = DateFormat('HH:mm').format(endTime);
    return "$s - $e WIB";
  }

  String get formattedDateTime => "$formattedDate · $formattedTimeRange";

  bool get isUpcoming =>
      (status == BookingStatus.pending ||
          status == BookingStatus.confirmed ||
          status == BookingStatus.rescheduled) &&
      startTime.isAfter(DateTime.now());

  bool get isHistory =>
      status == BookingStatus.completed ||
      status == BookingStatus.cancelled ||
      endTime.isBefore(DateTime.now());

  Booking copyWith({
    int? id,
    String? memberName,
    String? coachId,
    String? coachName,
    String? sport,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    BookingStatus? status,
    String? imageUrl,
  }) {
    return Booking(
      id: id ?? this.id,
      coachId: coachId ?? this.coachId,
      memberName: memberName ?? this.memberName,
      coachName: coachName ?? this.coachName,
      sport: sport ?? this.sport,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
