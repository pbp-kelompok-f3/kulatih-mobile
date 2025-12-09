import 'dart:convert';
import 'package:http/http.dart' as http;
import 'booking_model.dart';

class BookingService {
  static const String baseUrl = "http://10.0.2.2:8000/booking/api";

  /* =====================================================================
     GET BOOKINGS
     ===================================================================== */
  Future<List<Booking>> getBookings() async {
    final url = Uri.parse("$baseUrl/list/");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch bookings (${response.statusCode})");
    }

    final data = jsonDecode(response.body);

    if (!data.containsKey("bookings")) {
      throw Exception("Invalid response format: missing 'bookings'");
    }

    final list = data["bookings"] as List<dynamic>;
    return list.map((e) => Booking.fromJson(e)).toList();
  }

  /* =====================================================================
     CREATE BOOKING
     Django expects EXACTLY:
       - coach_id: int/string
       - location: string
       - date: "YYYY-MM-DD"
       - start_time: "HH:MM"
     ===================================================================== */
  Future<bool> createBooking({
    required String coachId,
    required String location,
    required DateTime dateTime,
  }) async {
    final url = Uri.parse("$baseUrl/create/");

    final body = {
      "coach_id": coachId,
      "location": location,
      "date":
          "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}",
      "start_time":
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}",
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) return true;

    throw Exception("Create booking failed: ${response.body}");
  }

  /* =====================================================================
     CANCEL BOOKING
     ===================================================================== */
  Future<bool> cancelBooking(int id) async {
    final url = Uri.parse("$baseUrl/cancel/$id/");
    final response = await http.post(url);

    if (response.statusCode == 200) return true;

    throw Exception("Cancel failed (${response.statusCode}): ${response.body}");
  }

  /* =====================================================================
     RESCHEDULE BOOKING
     Django expects EXACTLY:
        new_start: "YYYY-MM-DD HH:MM"
     No ISO, no seconds, no timezone.
     ===================================================================== */
  Future<bool> rescheduleBooking({
    required int id,
    required DateTime newStart,
  }) async {
    final url = Uri.parse("$baseUrl/reschedule/$id/");

    final formatted =
        "${newStart.year}-${newStart.month.toString().padLeft(2, '0')}-${newStart.day.toString().padLeft(2, '0')} "
        "${newStart.hour.toString().padLeft(2, '0')}:${newStart.minute.toString().padLeft(2, '0')}";

    final body = {"new_start": formatted};

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) return true;

    throw Exception("Reschedule failed: ${response.body}");
  }
}
