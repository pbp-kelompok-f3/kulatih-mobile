import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kulatih_mobile/models/user_provider.dart';

import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_service.dart';
import 'package:kulatih_mobile/khalisha-booking/widgets/booking_card.dart';
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

  Future<void> _fetchBookings() async {
    try {
      final data = await _service.getBookings();
      setState(() {
        _bookings = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<Booking> get upcoming => _bookings.where((b) => b.isUpcoming).toList();
  List<Booking> get history => _bookings.where((b) => b.isHistory).toList();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final bool isCoach = user.isCoach;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F38),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "MY BOOKINGS",
              style: TextStyle(
                color: Color(0xFFD4BC4E),
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _tabs(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _list(upcoming, false, isCoach),
                        _list(history, true, isCoach),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabs() {
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
          color: const Color(0xFFD4BC4E),
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

  Widget _list(List<Booking> items, bool historyMode, bool isCoach) {
    if (items.isEmpty) {
      return const Center(
        child: Text("No bookings found",
            style: TextStyle(color: Colors.white70)),
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

          // MEMBER
          onCancel: () async {
            await _service.cancelBooking(b.id);
            _fetchBookings();
          },
          onReschedule: () => showDialog(
            context: context,
            builder: (_) => RescheduleModal(booking: b),
          ),

          // COACH
          onAccept: isCoach
              ? () async {
                  await _service.acceptReschedule(b.id);
                  _fetchBookings();
                }
              : null,
          onReject: isCoach
              ? () async {
                  await _service.rejectReschedule(b.id);
                  _fetchBookings();
                }
              : null,
          onConfirm: isCoach
              ? () async {
                  await _service.confirmBooking(b.id);
                  _fetchBookings();
                }
              : null,
        );
      },
    );
  }
}
