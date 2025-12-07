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

  const Booking({
    required this.id,
    required this.coachName,
    required this.sport,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  // nanti dipakai kalau sudah sambung ke backend
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      coachName: json['coach_name'] as String,
      sport: (json['sport'] as String?) ?? 'Sport',
      location: (json['location'] as String?) ?? '',
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: bookingStatusFromString(json['status'] as String),
    );
  }

  // <<< INI YANG DIPAKE DI _cancelBooking DAN RESCHEDULE >>>
  Booking copyWith({
    int? id,
    String? coachName,
    String? sport,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    BookingStatus? status,
  }) {
    return Booking(
      id: id ?? this.id,
      coachName: coachName ?? this.coachName,
      sport: sport ?? this.sport,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
    );
  }
}
