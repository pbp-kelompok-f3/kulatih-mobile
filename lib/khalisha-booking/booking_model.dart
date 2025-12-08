enum BookingStatus {
  pending,
  confirmed,
  rescheduled,
  cancelled,
  completed,
}

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
    default:
      return 'Unknown';
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

  Booking({
    required this.id,
    required this.coachName,
    required this.sport,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

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
    );
  }
}
