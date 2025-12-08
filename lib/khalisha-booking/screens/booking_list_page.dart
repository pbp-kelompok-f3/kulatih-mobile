import 'package:flutter/material.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_service.dart';
import 'package:kulatih_mobile/khalisha-booking/screens/booking_detail_page.dart';
import 'package:kulatih_mobile/khalisha-booking/screens/booking_reschedule_modal.dart';
import 'package:intl/intl.dart';

class BookingListPage extends StatefulWidget {
  const BookingListPage({super.key});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Booking> _bookings = [];
  bool _loading = true;

  final BookingService _service = BookingService();

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
    } catch (e) {
      print("Error fetching bookings: $e");
    }
  }

  // ========= HELPERS =========

  bool isUpcoming(Booking b) {
    return b.status != BookingStatus.cancelled &&
        b.status != BookingStatus.completed &&
        b.startTime.isAfter(DateTime.now());
  }

  bool isHistory(Booking b) {
    return !isUpcoming(b);
  }

  String formatDateTime(Booking b) {
    final date = DateFormat('EEE, dd MMM yyyy').format(b.startTime);
    final time =
        "${DateFormat('HH:mm').format(b.startTime)} - ${DateFormat('HH:mm').format(b.endTime)} WIB";
    return "$date • $time";
  }

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios,
                        size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "MY BOOKINGS",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: gold,
                      letterSpacing: 1.2,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildTabs(),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildList(
                            _bookings.where((b) => isUpcoming(b)).toList(),
                            false),
                        _buildList(
                            _bookings.where((b) => isHistory(b)).toList(),
                            true),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// ------------------------
  /// TABS (UPCOMING / HISTORY)
  /// ------------------------
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

  /// ------------------------
  /// BOOKING LIST
  /// ------------------------
  Widget _buildList(List<Booking> items, bool isHistory) {
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
      itemBuilder: (_, i) => _bookingCard(items[i], isHistory),
    );
  }

  /// ------------------------
  /// BOOKING CARD
  /// ------------------------
  Widget _bookingCard(Booking b, bool isHistoryMode) {
    const cardBg = Color(0xFF1C1C4A);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// DATE & STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDateTime(b),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
              _statusBadge(b.status),
            ],
          ),

          const SizedBox(height: 15),

          /// COACH + SPORT
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundImage:
                    AssetImage("assets/default_user.png"), // sementara avatar default
              ),
              const SizedBox(width: 15),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.coachName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    b.sport,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 15),

          /// LOCATION
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Text(b.location, style: const TextStyle(color: Colors.white70)),
            ],
          ),

          const SizedBox(height: 15),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),

          isHistoryMode ? _historyButtons(b) : _upcomingButtons(b),
        ],
      ),
    );
  }

  /// ------------------------
  /// STATUS BADGE
  /// ------------------------
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
        c = Colors.amber;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        bookingStatusToText(status).toUpperCase(),
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// ------------------------
  /// UPCOMING BUTTONS
  /// ------------------------
  Widget _upcomingButtons(Booking b) {
    return Row(
      children: [
        _btn("Cancel", Colors.red, () async {
          await _service.cancelBooking(b.id);
          _fetchBookings();
        }),

        _btn("View Details", const Color(0xFFD4BC4E), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookingDetailPage(booking: b)),
          );
        }),

        _btn("Reschedule", const Color(0xFF0F0F38), () {
          showDialog(
            context: context,
            builder: (_) => RescheduleModal(booking: b),
          );
        }),
      ],
    );
  }

  /// ------------------------
  /// HISTORY BUTTONS
  /// ------------------------
  Widget _historyButtons(Booking b) {
    return Row(
      children: [
        _btn("View Your Review", const Color(0xFFD4BC4E), () {}),
        _btn("Book Again", const Color(0xFF0F0F38), () {}),
      ],
    );
  }

  /// ------------------------
  /// REUSABLE BUTTON
  /// ------------------------
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
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
