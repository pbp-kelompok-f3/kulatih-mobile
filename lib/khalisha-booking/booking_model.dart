import 'package:intl/intl.dart';

enum BookingStatus {
  pending,
  confirmed,
  rescheduled,
  cancelled,
  completed,
}

/// Convert backend string → enum
BookingStatus bookingStatusFromString(String value) {
  switch (value.toLowerCase()) {
    case 'confirmed':
      return BookingStatus.confirmed;
    case 'rescheduled':
      return BookingStatus.rescheduled;
    case 'cancelled':
    case 'canceled':
      return BookingStatus.cancelled;
    case 'completed':
      return BookingStatus.completed;
    case 'pending':
    default:
      return BookingStatus.pending;
  }
}

/// Convert enum → pretty text
String bookingStatusToText(BookingStatus status) {
  switch (status) {
    case BookingStatus.pending:
      return 'Pending';
    case BookingStatus.confirmed:
      return 'Confirmed';
    case BookingStatus.rescheduled:
      return 'Rescheduled';
    case BookingStatus.cancelled:
      return 'Cancelled';
    case BookingStatus.completed:
      return 'Completed';
  }
}

class Booking {
  final int id;
  final String coachName;
  final String sport;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final BookingStatus status;
  final String? imageUrl; // optional untuk avatar coach

  Booking({
    required this.id,
    required this.coachName,
    required this.sport,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.imageUrl,
  });

  /// Factory from backend JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    final date = json['date'];
    final start = json['start_time'];
    final end = json['end_time'];

    return Booking(
      id: json['id'],
      coachName: json['coach_name'] ?? '',
      sport: json['sport'] ?? '',
      location: json['location'] ?? '',
      startTime: DateTime.parse("$date $start"),
      endTime: DateTime.parse("$date $end"),
      status: bookingStatusFromString(json['status']),
      imageUrl: json['image_url'], // opsional
    );
  }

  /* ============================================================
      FORMATTED GETTERS (untuk UI clean)
     ============================================================ */

  /// Example → "Sunday, 09 Feb 2025"
  String get formattedDate =>
      DateFormat('EEEE, dd MMM yyyy').format(startTime);

  /// Example → "15:00 - 17:00 WIB"
  String get formattedTimeRange {
    final s = DateFormat('HH:mm').format(startTime);
    final e = DateFormat('HH:mm').format(endTime);
    return "$s - $e WIB";
  }

  /// Example → "Sunday, 09 Feb 2025 · 15:00 - 17:00 WIB"
  String get formattedDateTime => "$formattedDate · $formattedTimeRange";

  /* ============================================================
      STATUS HELPERS
     ============================================================ */

  bool get isUpcoming =>
      (status == BookingStatus.pending ||
          status == BookingStatus.confirmed ||
          status == BookingStatus.rescheduled) &&
      startTime.isAfter(DateTime.now());

  bool get isHistory =>
      status == BookingStatus.completed ||
      status == BookingStatus.cancelled ||
      endTime.isBefore(DateTime.now());

  /* ============================================================
      COPYWITH
     ============================================================ */
  Booking copyWith({
    int? id,
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
