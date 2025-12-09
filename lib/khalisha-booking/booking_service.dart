import 'dart:convert';
import 'package:http/http.dart' as http;
import 'booking_model.dart';

class BookingService {
  static const String baseUrl = "http://10.0.2.2:8000/booking/api";

  /// MODE: DUMMY vs BACKEND
  bool useDummy = true;

  /// Dummy storage
  final List<Booking> _dummyList = [];

  bool _dummyInitialized = false;

  int _generateDummyId() => DateTime.now().millisecondsSinceEpoch;

  /// =========================================================
  /// AUTO GENERATE 5 DUMMY BOOKINGS (cuman sekali)
  /// =========================================================
  void _generateInitialDummyData() {
    if (_dummyInitialized) return;

    final now = DateTime.now();

    _dummyList.addAll([
      // UPCOMING
      Booking(
        id: _generateDummyId(),
        coachName: "Muhammad Salman",
        sport: "Tennis",
        location: "Depok Stadium",
        startTime: now.add(const Duration(days: 1, hours: 2)),
        endTime: now.add(const Duration(days: 1, hours: 3)),
        status: BookingStatus.confirmed,
      ),
      Booking(
        id: _generateDummyId(),
        coachName: "Patrick Kluivert",
        sport: "Football",
        location: "Koci Soccer Field",
        startTime: now.add(const Duration(days: 2, hours: 1)),
        endTime: now.add(const Duration(days: 2, hours: 2)),
        status: BookingStatus.pending,
      ),
      Booking(
        id: _generateDummyId(),
        coachName: "Agung Hercules",
        sport: "Gym",
        location: "Fit Gym Jakarta",
        startTime: now.add(const Duration(hours: 3)),
        endTime: now.add(const Duration(hours: 4)),
        status: BookingStatus.rescheduled,
      ),

      // HISTORY
      Booking(
        id: _generateDummyId(),
        coachName: "Rangga Saputra",
        sport: "Badminton",
        location: "GOR Cibubur",
        startTime: now.subtract(const Duration(days: 1, hours: 2)),
        endTime: now.subtract(const Duration(days: 1, hours: 1)),
        status: BookingStatus.completed,
      ),
      Booking(
        id: _generateDummyId(),
        coachName: "Bima Putra",
        sport: "Basketball",
        location: "UI Hall",
        startTime: now.subtract(const Duration(days: 3, hours: 2)),
        endTime: now.subtract(const Duration(days: 3, hours: 1)),
        status: BookingStatus.cancelled,
      ),
    ]);

    _dummyInitialized = true;
  }

  /// =========================================================
  /// GET BOOKINGS
  /// =========================================================
  Future<List<Booking>> getBookings() async {
    if (useDummy) {
      _generateInitialDummyData();
      return _dummyList;
    }

    final url = Uri.parse("$baseUrl/list/");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch bookings");
    }

    final data = jsonDecode(response.body);
    final list = data["bookings"] as List<dynamic>;
    return list.map((e) => Booking.fromJson(e)).toList();
  }

  /// =========================================================
  /// CREATE BOOKING
  /// =========================================================
  Future<bool> createBooking({
    required String coachId,
    required String location,
    required DateTime dateTime,
  }) async {
    if (useDummy) {
      final b = Booking(
        id: _generateDummyId(),
        coachName: "Dummy Coach $coachId",
        sport: "Football",
        location: location,
        startTime: dateTime,
        endTime: dateTime.add(const Duration(hours: 1)),
        status: BookingStatus.pending,
      );

      _dummyList.add(b);
      return true;
    }

    final url = Uri.parse("$baseUrl/create/");
    final body = {
      "coach_id": coachId,
      "location": location,
      "date":
          "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}",
      "start_time":
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}",
    };

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) return true;
    throw Exception("Failed to create booking: ${res.body}");
  }

  /// =========================================================
  /// CANCEL BOOKING
  /// =========================================================
  Future<bool> cancelBooking(int id) async {
    if (useDummy) {
      final i = _dummyList.indexWhere((e) => e.id == id);
      if (i != -1) {
        // langsung jadi cancelled → langsung pindah tab history
        _dummyList[i] = _dummyList[i].copyWith(status: BookingStatus.cancelled);
      }
      return true;
    }

    final url = Uri.parse("$baseUrl/cancel/$id/");
    final res = await http.post(url);
    return res.statusCode == 200;
  }

  /// =========================================================
  /// RESCHEDULE BOOKING — DOES NOT UPDATE IMMEDIATELY
  /// =========================================================
  Future<bool> rescheduleBooking({
    required int id,
    required DateTime newStart,
  }) async {

    if (useDummy) {
      // ❌ Jangan ubah data di dummy — nunggu coach confirm
      // (Mencocokkan flow Django kamu: pending approval)
      return true;
    }

    // ORIGINAL BACKEND (juga tidak mengubah status → coach yang mengubah)
    final url = Uri.parse("$baseUrl/reschedule/$id/");

    final formatted =
        "${newStart.year}-${newStart.month.toString().padLeft(2, '0')}-${newStart.day.toString().padLeft(2, '0')} "
        "${newStart.hour.toString().padLeft(2, '0')}:${newStart.minute.toString().padLeft(2, '0')}";

    final body = {"new_start": formatted};

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    return res.statusCode == 200;
  }
}
