import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';

class BookingService {
  final String baseUrl = "http://10.0.2.2:8000";

  Future<List<Booking>> getBookings() async {
    final url = Uri.parse("$baseUrl/booking/api/list/");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch bookings: ${response.body}");
    }

    final data = jsonDecode(response.body);
    final list = data["bookings"] as List;
    return list.map((e) => Booking.fromJson(e)).toList();
  }

  Future<void> createBooking({
    required int coachId,
    required String location,
    required DateTime startTime,
  }) async {
    final url = Uri.parse("$baseUrl/booking/api/create/");
    final body = jsonEncode({
      "coach_id": coachId,
      "location": location,
      "date": startTime.toIso8601String(),
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Create failed: ${response.body}");
    }
  }

  Future<void> cancelBooking(int id) async {
    final url = Uri.parse("$baseUrl/booking/api/cancel/$id/");
    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception("Cancel failed: ${response.body}");
    }
  }

  /// *** RESCHEDULE BOOKING — FINAL VERSION ***
  Future<void> rescheduleBooking({
    required int bookingId,
    required DateTime newStartTime,
    required DateTime newEndTime,
  }) async {
    final url = Uri.parse("$baseUrl/booking/api/reschedule/$bookingId/");

    final body = jsonEncode({
      "new_start_time": newStartTime.toIso8601String(),
      "new_end_time": newEndTime.toIso8601String(),
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception("Reschedule failed: ${response.body}");
    }
  }
}
