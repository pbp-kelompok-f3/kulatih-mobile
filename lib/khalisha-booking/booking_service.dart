import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';

class BookingService {
  // GANTI baseUrl ini sesuai backend kamu
  // kalau lagi jalan di lokal:
  // - emulator Android: http://10.0.2.2:8000
  // - Flutter web di browser: http://127.0.0.1:8000
  final String baseUrl = 'http://127.0.0.1:8000';

  Future<List<Booking>> fetchMemberBookings() async {
    final url = Uri.parse('$baseUrl/api/bookings/member/'); // GANTI path-nya
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load bookings: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);

    // asumsi backend mengirim list JSON
    return (data as List)
        .map((item) => Booking.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Booking>> fetchCoachBookings() async {
    final url = Uri.parse('$baseUrl/api/bookings/coach/'); // GANTI path
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load coach bookings: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);

    return (data as List)
        .map((item) => Booking.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createBooking({
    required int coachId,
    required String location,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final url = Uri.parse('$baseUrl/api/bookings/create/'); // GANTI path
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'coach_id': coachId,
        'location': location,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create booking: ${response.body}');
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    final url = Uri.parse('$baseUrl/api/bookings/$bookingId/cancel/'); // GANTI
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to cancel booking: ${response.body}');
    }
  }

  Future<void> rescheduleBooking({
    required int bookingId,
    required DateTime newStartTime,
    required DateTime newEndTime,
  }) async {
    final url =
        Uri.parse('$baseUrl/api/bookings/$bookingId/reschedule/'); // GANTI
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'start_time': newStartTime.toIso8601String(),
        'end_time': newEndTime.toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reschedule booking: ${response.body}');
    }
  }
}
