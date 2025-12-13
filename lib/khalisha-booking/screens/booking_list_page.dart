import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kulatih_mobile/constants/app_colors.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_service.dart';
import 'package:kulatih_mobile/khalisha-booking/widgets/booking_card.dart';
import 'package:kulatih_mobile/models/user_provider.dart';
import 'package:kulatih_mobile/khalisha-booking/screens/booking_detail_page.dart';
import 'package:kulatih_mobile/khalisha-booking/screens/booking_reschedule_modal.dart';

class BookingListPage extends StatefulWidget {
  const BookingListPage({super.key});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage>
    with SingleTickerProviderStateMixin {
  final BookingService _service = BookingService();

  late TabController _tabController;

  bool _loading = true;
  List<Booking> _bookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchBookings();
  }

  /* ---------------- FETCH FROM BACKEND ---------------- */
  Future<void> _fetchBookings() async {
    try {
      final data = await _service.getBookings();
      setState(() {
        _bookings = data;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error fetching bookings: $e");
      setState(() => _loading = false);
    }
  }

  /* ---------------- FILTER LOGIC ---------------- */
  List<Booking> get upcoming {
    return _bookings.where((b) => b.isUpcoming).toList();
  }

  List<Booking> get history {
    return _bookings.where((b) => b.isHistory).toList();
  }

  /* ---------------- CANCEL ---------------- */
  Future<void> _cancelBooking(Booking booking) async {
    try {
      final ok = await _service.cancelBooking(booking.id);

      if (!ok) return;

      setState(() {
        final idx = _bookings.indexWhere((b) => b.id == booking.id);
        if (idx != -1) {
          _bookings[idx] =
              _bookings[idx].copyWith(status: BookingStatus.cancelled);
        }
      });
    } catch (e) {
      debugPrint("Cancel failed: $e");
    }
  }

  /* ---------------- OPEN RESCHEDULE ---------------- */
  Future<void> _openReschedule(Booking booking) async {
    final result = await showDialog(
      context: context,
      builder: (_) => RescheduleModal(booking: booking),
    );

    if (result == true) {
      await _fetchBookings();
    }
  }

  /* ---------------- COACH ACTIONS ---------------- */

  Future<void> _accept(Booking b) async {
    await _service.acceptReschedule(b.id);
    _fetchBookings();
  }

  Future<void> _reject(Booking b) async {
    await _service.rejectReschedule(b.id);
    _fetchBookings();
  }

  Future<void> _confirm(Booking b) async {
    await _service.confirmBooking(b.id);
    _fetchBookings();
  }

  /* ---------------- UI ---------------- */
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final isCoach = user.isCoach;

    return Scaffold(
      backgroundColor: AppColors.indigo,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// HEADER
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "MY BOOKINGS",
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// TABS
            _buildTabs(),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildList(upcoming, false, isCoach),
                        _buildList(history, true, isCoach),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /* ---------------- TAB HEADER ---------------- */
  Widget _buildTabs() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF17173F),
        borderRadius: BorderRadius.circular(40),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(40),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white,
        tabs: const [
          Tab(text: "Upcoming"),
          Tab(text: "History"),
        ],
      ),
    );
  }

  /* ---------------- LIST BUILDER ---------------- */
  Widget _buildList(List<Booking> items, bool historyMode, bool isCoach) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          "No bookings found",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final b = items[i];

        return BookingCard(
          booking: b,
          historyMode: historyMode,
          isCoach: isCoach,

          // USER BUTTONS
          onCancel: () => _cancelBooking(b),
          onReschedule: () => _openReschedule(b),

          // COACH BUTTONS
          onAccept: () => _accept(b),
          onReject: () => _reject(b),
          onConfirm: () => _confirm(b),

          // HISTORY BUTTONS
          onViewReview: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingDetailPage(booking: b),
              ),
            );
          },
          onBookAgain: () {},
        );
      },
    );
  }
}
