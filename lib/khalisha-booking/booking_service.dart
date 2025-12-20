import 'dart:convert';
import 'package:http/http.dart' as http;

import 'booking_model.dart';

class BookingService {
  static const String baseUrl = "http://127.0.0.1:8000";

  /* ===================== LIST ===================== */
  Future<List<Booking>> getBookings() async {
    final url = Uri.parse("$baseUrl/booking/api/list/");
    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception("Failed to fetch bookings: ${res.statusCode}");
    }

    final decoded = jsonDecode(res.body);

    if (decoded is! Map || !decoded.containsKey("bookings")) {
      throw Exception("Unexpected JSON format from backend");
    }

    final List list = decoded["bookings"];

    // gunakan Booking.fromJson (lebih akurat)
    return list.map<Booking>((json) => Booking.fromJson(json)).toList();
  }

  /* ===================== CREATE ===================== */
  Future<bool> createBooking({
    required String coachId,
    required String location,
    required DateTime dateTime,
  }) async {
    final url = Uri.parse("$baseUrl/booking/api/create/");

    final body = {
      "coach_id": coachId,
      "location": location,
      "date":
          "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}",
      "start_time":
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}",
      "end_time":
          "${(dateTime.hour + 1).toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}",
    };

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    return res.statusCode == 200;
  }

  /* ===================== CANCEL ===================== */
  Future<bool> cancelBooking(int id) async {
    final url = Uri.parse("$baseUrl/booking/api/cancel/$id/");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
    );
    return res.statusCode == 200;
  }

  /* ===================== RESCHEDULE ===================== */
  Future<bool> rescheduleBooking({
    required int id,
    required DateTime newStart,
  }) async {
    final url = Uri.parse("$baseUrl/booking/api/reschedule/$id/");

    final body = {
      "new_start_time":
          "${newStart.year}-${newStart.month.toString().padLeft(2, '0')}-${newStart.day.toString().padLeft(2, '0')} "
              "${newStart.hour.toString().padLeft(2, '0')}:${newStart.minute.toString().padLeft(2, '0')}",

      "new_end_time":
          "${newStart.year}-${newStart.month.toString().padLeft(2, '0')}-${newStart.day.toString().padLeft(2, '0')} "
              "${(newStart.hour + 1).toString().padLeft(2, '0')}:${newStart.minute.toString().padLeft(2, '0')}",
    };

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    return res.statusCode == 200;
  }

  /* ===================== COACH ACTIONS (FIXED) ===================== */

  Future<bool> acceptReschedule(int id) async {
    final url = Uri.parse("$baseUrl/booking/api/accept/$id/");
    final res = await http.post(url);
    return res.statusCode == 200;
  }

  Future<bool> rejectReschedule(int id) async {
    final url = Uri.parse("$baseUrl/booking/api/reject/$id/");
    final res = await http.post(url);
    return res.statusCode == 200;
  }

  Future<bool> confirmBooking(int id) async {
    final url = Uri.parse("$baseUrl/booking/api/confirm/$id/");
    final res = await http.post(url);
    return res.statusCode == 200;
  }}
