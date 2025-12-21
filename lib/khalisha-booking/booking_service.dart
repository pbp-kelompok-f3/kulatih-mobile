import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'booking_model.dart';

class BookingService {
  static const String baseUrl = 'http://localhost:8000';

  bool _isOk(dynamic res) {
    if (res is Map) {
      if (res['ok'] is bool) return res['ok'];
      if (res['success'] is bool) return res['success'];
      if (res['status'] is String) {
        final s = res['status'].toString().toLowerCase();
        return s == 'ok' || s == 'success';
      }
    }
    return true;
  }

  /* ===================== LIST ===================== */
  Future<List<Booking>> getBookings(CookieRequest request) async {
    final url = "$baseUrl/booking/list/json/";
    final res = await request.get(url);

    if (res is Map && res["items"] is List) {
      return (res["items"] as List)
          .map((e) => Booking.fromJson(e))
          .toList();
    }

    throw Exception("Invalid response when fetching bookings");
  }

  /* ===================== CREATE ===================== */
  Future<bool> createBooking({
    required CookieRequest request,
    required String coachId,
    required String location,
    required DateTime dateTime,
  }) async {
    final url = "$baseUrl/booking/create/json/$coachId/";

    final body = {
      "location": location,
      "datetime": dateTime.toIso8601String().substring(0, 16),
    };

    final res = await request.postJson(url, jsonEncode(body));
    return _isOk(res);
  }

  /* ===================== CANCEL ===================== */
  Future<bool> cancelBooking(CookieRequest request, int id) async {
    final url = "$baseUrl/booking/cancel/json/$id/";
    final res = await request.postJson(url, jsonEncode({}));
    return _isOk(res);
  }

  /* ===================== RESCHEDULE ===================== */
  Future<bool> rescheduleBooking({
    required CookieRequest request,
    required int id,
    required DateTime newStart,
  }) async {
    final url = "$baseUrl/booking/reschedule/json/$id/";

    final body = {
      "datetime": newStart.toIso8601String().substring(0, 16),
    };

    final res = await request.postJson(url, jsonEncode(body));
    return _isOk(res);
  }

  /* ===================== COACH ACTIONS ===================== */
  Future<bool> acceptReschedule(CookieRequest request, int id) async {
    final url = "$baseUrl/booking/accept-reschedule/json/$id/";
    final res = await request.postJson(url, jsonEncode({}));
    return _isOk(res);
  }

  Future<bool> rejectReschedule(CookieRequest request, int id) async {
    final url = "$baseUrl/booking/reject-reschedule/json/$id/";
    final res = await request.postJson(url, jsonEncode({}));
    return _isOk(res);
  }

  Future<bool> confirmBooking(CookieRequest request, int id) async {
    final url = "$baseUrl/booking/confirm-booking/json/$id/";
    final res = await request.postJson(url, jsonEncode({}));
    return _isOk(res);
  }
}
