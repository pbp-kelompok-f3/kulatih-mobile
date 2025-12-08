import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';

class BookingService {
  // Emulator Android → pakai 10.0.2.2
  final String baseUrl = "http://10.0.2.2:8000";

  // ============================
  // GET ALL BOOKINGS
  // ============================
  Future<List<Booking>> getBookings() async {
    final url = Uri.parse("$baseUrl/booking/api/list/");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch bookings: ${response.body}");
    }

    final data = jsonDecode(response.body);

    if (!data.containsKey("bookings")) {
      throw Exception("Invalid response structure: 'bookings' not found");
    }

    final list = data["bookings"] as List;

    return list.map((json) => Booking.fromJson(json)).toList();
  }

  // ============================
  // GET DETAIL BOOKING (OPTIONAL)
  // ============================
  Future<Booking> getBookingDetail(int id) async {
    final url = Uri.parse("$baseUrl/booking/api/detail/$id/");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch detail: ${response.body}");
    }

    final data = jsonDecode(response.body);
    return Booking.fromJson(data);
  }

  // ============================
  // CREATE BOOKING
  // ============================
  Future<void> createBooking({
    required int coachId,
    required String location,
    required DateTime startTime,
  }) async {
    final url = Uri.parse("$baseUrl/booking/api/create/");

    final payload = {
      "coach_id": coachId,
      "location": location,
      "date": startTime.toIso8601String(),
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Create failed: ${response.body}");
    }
  }

  // ============================
  // CANCEL BOOKING
  // ============================
  Future<void> cancelBooking(int id) async {
    final url = Uri.parse("$baseUrl/booking/api/cancel/$id/");

    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception("Cancel failed: ${response.body}");
    }
  }

  // ============================
  // RESCHEDULE BOOKING
  // ============================
  Future<void> rescheduleBooking({
    required int bookingId,
    required DateTime newDate,
  }) async {
    final url = Uri.parse("$baseUrl/booking/api/reschedule/$bookingId/");

    final payload = {
      "date": newDate.toIso8601String(),
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception("Reschedule failed: ${response.body}");
    }
  }
}
