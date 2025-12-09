import 'package:intl/intl.dart';

enum BookingStatus {
  pending,
  confirmed,
  rescheduled,
  cancelled,
  completed,
}

/* ============================================================
   STATUS PARSING
   ============================================================ */

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
    case 'pending':
      return BookingStatus.pending;
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

/* ============================================================
   BOOKING MODEL
   ============================================================ */

class Booking {
  final int id;
  final String coachName;
  final String sport;
  final String location;

  final DateTime startTime;
  final DateTime endTime;

  final BookingStatus status;
  final String? imageUrl;

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

  /* ============================================================
     FACTORY FROM JSON
     ============================================================ */

  factory Booking.fromJson(Map<String, dynamic> json) {
    final date = json['date'];
    final start = json['start_time'];
    final end = json['end_time'];

    DateTime safeParse(String value) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        // fallback remove microseconds
        final cleaned = value.split('.').first;
        return DateTime.parse(cleaned);
      }
    }

    final startDT = safeParse("$date $start");
    final endDT = end != null
        ? safeParse("$date $end")
        : startDT.add(const Duration(hours: 1)); // backend fallback

    return Booking(
      id: json['id'],
      coachName: json['coach_name'] ?? '',
      sport: json['sport'] ?? '',
      location: json['location'] ?? '',
      startTime: startDT,
      endTime: endDT,
      status: bookingStatusFromString(json['status']),
      imageUrl: json['image_url'],
    );
  }

  /* ============================================================
     FORMATTED GETTERS (for UI)
     ============================================================ */

  String get formattedDate =>
      DateFormat('EEEE, dd MMM yyyy').format(startTime);

  String get formattedTimeRange {
    final s = DateFormat('HH:mm').format(startTime);
    final e = DateFormat('HH:mm').format(endTime);
    return "$s - $e WIB";
  }

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
