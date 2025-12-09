import 'package:flutter/material.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_service.dart';
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
    final now = DateTime.now();
    return _bookings.where((b) {
      final activeStatus =
          b.status == BookingStatus.pending ||
          b.status == BookingStatus.confirmed ||
          b.status == BookingStatus.rescheduled;
      return activeStatus && b.startTime.isAfter(now);
    }).toList();
  }

  List<Booking> get history {
    final now = DateTime.now();
    return _bookings.where((b) {
      final pastStatus =
          b.status == BookingStatus.completed ||
          b.status == BookingStatus.cancelled;
      return pastStatus || b.endTime.isBefore(now);
    }).toList();
  }

  /* ---------------- CANCEL ---------------- */
  Future<void> _cancelBooking(Booking booking) async {
    await _service.cancelBooking(booking.id);
    await _fetchBookings();
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

  /* ---------------- UI ---------------- */
  @override
  Widget build(BuildContext context) {
    const indigo = Color(0xFF0F0F38);
    const gold = Color(0xFFD4BC4E);

    return Scaffold(
      backgroundColor: indigo,
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
                  color: gold,
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
                        _buildList(upcoming, false),
                        _buildList(history, true),
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
          color: const Color(0xFFD4BC4E),
          borderRadius: BorderRadius.circular(40),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white,
        tabs: const [
          Tab(text: "Upcoming"),
          Tab(text: "Booking History"),
        ],
      ),
    );
  }

  /* ---------------- LIST BUILDER ---------------- */
  Widget _buildList(List<Booking> items, bool historyMode) {
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
      itemBuilder: (_, i) => _bookingCard(items[i], historyMode),
    );
  }

  /* ---------------- BOOKING CARD ---------------- */
  Widget _bookingCard(Booking b, bool historyMode) {
    const cardBg = Color(0xFF1C1C4A);

    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// DATE + STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                b.formattedDateTime,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              _statusBadge(b.status),
            ],
          ),

          const SizedBox(height: 12),

          /// COACH ROW
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundImage: AssetImage("assets/default_user.png"),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.coachName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    b.sport,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// LOCATION ROW
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(b.location, style: const TextStyle(color: Colors.white70)),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),

          historyMode ? _historyButtons(b) : _upcomingButtons(b),
        ],
      ),
    );
  }

  /* ---------------- STATUS BADGE ---------------- */
  Widget _statusBadge(BookingStatus status) {
    Color c;
    switch (status) {
      case BookingStatus.confirmed:
        c = Colors.green;
        break;
      case BookingStatus.rescheduled:
        c = Colors.purple;
        break;
      case BookingStatus.completed:
        c = Colors.blue;
        break;
      case BookingStatus.cancelled:
        c = Colors.grey;
        break;
      default:
        c = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        bookingStatusToText(status).toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /* ---------------- UPCOMING BUTTONS ---------------- */
  Widget _upcomingButtons(Booking b) {
    return Row(
      children: [
        _btn("Cancel", Colors.red, () => _cancelBooking(b)),
        _btn(
          "View Details",
          const Color(0xFFD4BC4E),
          () async {
            final updated = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BookingDetailPage(booking: b)),
            );

            if (updated == true) _fetchBookings();
          },
        ),
        _btn("Reschedule", Colors.grey, () => _openReschedule(b)),
      ],
    );
  }

  /* ---------------- HISTORY BUTTONS ---------------- */
  Widget _historyButtons(Booking b) {
    return Row(
      children: [
        _btn("View Your Review", const Color(0xFFD4BC4E), () {}),
        _btn("Book Again", Colors.grey.shade700, () {}),
      ],
    );
  }

  /* ---------------- REUSABLE BUTTON ---------------- */
  Widget _btn(String label, Color bg, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
