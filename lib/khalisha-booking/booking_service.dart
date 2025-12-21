import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'booking_model.dart';

class BookingService {
  static const String baseUrl = 'https://muhammad-salman42-kulatih.pbp.cs.ui.ac.id';

  bool _isOk(dynamic res) {
    if (res is Map) {
      if (res['ok'] is bool) return res['ok'] as bool;
      if (res['success'] is bool) return res['success'] as bool;
      if (res['status'] is String) {
        final s = (res['status'] as String).toLowerCase();
        return s == 'ok' || s == 'success';
      }
    }
    return true;
  }

  /* ===================== LIST ===================== */
  Future<List<Booking>> getBookings(CookieRequest request) async {
    final url = "$baseUrl/booking/json/list/";
    final res = await request.get(url);

    if (res is Map && res["items"] is List) {
      return (res["items"] as List).map((e) => Booking.fromJson(e)).toList();
    }

    throw Exception("Invalid response when fetching bookings");
  }

  /* ===================== CREATE ===================== */
  Future<bool> createBooking({
    required CookieRequest request,
    required String coachId, // UUID string
    required String location,
    required DateTime dateTime,
  }) async {
    final url = "$baseUrl/booking/json/$coachId/create/";

    // ✅ backend create_booking_json expect "datetime" format "%Y-%m-%dT%H:%M"
    final body = {
      "location": location,
      "datetime": dateTime.toIso8601String().substring(0, 16),
    };

    final res = await request.postJson(url, jsonEncode(body));
    return _isOk(res);
  }

  /* ===================== CANCEL ===================== */
  Future<bool> cancelBooking(CookieRequest request, int id) async {
    final url = "$baseUrl/booking/api/cancel/$id/";
    final res = await request.postJson(url, jsonEncode({}));
    return _isOk(res);
  }

  /* ===================== RESCHEDULE ===================== */
  Future<bool> rescheduleBooking({
    required CookieRequest request,
    required int id,
    required DateTime newStart,
  }) async {
    final url = "$baseUrl/booking/api/reschedule/$id/";
    final body = {
      "new_start_time": newStart.toIso8601String(),
      "new_end_time": newStart.add(Duration(hours: 1)).toIso8601String(),
    };

    final res = await request.postJson(url, jsonEncode(body));
    return _isOk(res);
  }

  /* ===================== COACH ACTIONS ===================== */
  Future<bool> confirmBooking(CookieRequest request, int id) async {
    final url = "$baseUrl/booking/api/confirm/$id/";
    final res = await request.postJson(url, jsonEncode({}));
    return _isOk(res);
  }

  Future<bool> acceptReschedule(CookieRequest request, int id) async {
    final url = "$baseUrl/booking/api/accept/$id/";
    final res = await request.postJson(url, jsonEncode({}));
    return _isOk(res);
  }

  Future<bool> rejectReschedule(CookieRequest request, int id) async {
    final url = "$baseUrl/booking/api/reject/$id/";
    final res = await request.postJson(url, jsonEncode({}));
    return _isOk(res);
  }
}
