import 'package:flutter/material.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_service.dart';
import 'package:kulatih_mobile/khalisha-booking/screens/booking_reschedule_modal.dart';
import 'package:kulatih_mobile/khalisha-booking/screens/booking_detail_page.dart';

class BookingListPage extends StatefulWidget {
  const BookingListPage({super.key});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final data = await BookingService.getBookings();
    setState(() {
      _bookings = data;
      _isLoading = false;
    });
  }

  List<Booking> get upcoming =>
      _bookings.where((b) => b.isUpcoming == true).toList();

  List<Booking> get history =>
      _bookings.where((b) => b.isHistory == true).toList();

  @override
  Widget build(BuildContext context) {
    final Color indigo = const Color(0xFF0F0F38);
    final Color indigoDark = const Color(0xFF0A0A28);
    final Color gold = const Color(0xFFD4BC4E);

    return Scaffold(
      backgroundColor: indigo,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "MY BOOKINGS",
                    style: TextStyle(
                      fontSize: 26,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                      color: gold,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // TABS
            _buildTabs(gold),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBookingList(upcoming, false),
                        _buildBookingList(history, true),
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }

  /// ---------------------------
  /// TAB SWITCHER (UPCOMING/HISTORY)
  /// ---------------------------
  Widget _buildTabs(Color gold) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF17173F),
        borderRadius: BorderRadius.circular(40),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: gold,
          borderRadius: BorderRadius.circular(40),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(text: "Upcoming"),
          Tab(text: "Booking History"),
        ],
      ),
    );
  }

  /// ---------------------------
  /// BOOKING LIST
  /// ---------------------------
  Widget _buildBookingList(List<Booking> items, bool isHistory) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          "No bookings yet",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, i) {
        return _buildBookingCard(items[i], isHistory);
      },
    );
  }

  /// ---------------------------
  /// BOOKING CARD (MATCH FIGMA)
  /// ---------------------------
  Widget _buildBookingCard(Booking booking, bool isHistory) {
    final Color indigoLight = const Color(0xFF1C1C4A);
    final Color gold = const Color(0xFFD4BC4E);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: indigoLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DATE + STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.formattedDateTime,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
              _buildStatusBadge(booking.status),
            ],
          ),

          const SizedBox(height: 15),

          // PROFILE + NAME + SPORT
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage(booking.imageUrl),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    booking.sport,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 15),

          // LOCATION
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                booking.location,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),

          const SizedBox(height: 15),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),

          // ACTION BUTTONS
          isHistory ? _buildHistoryButtons(booking) : _buildUpcomingButtons(booking),
        ],
      ),
    );
  }

  /// ---------------------------
  /// STATUS BADGE
  /// ---------------------------
  Widget _buildStatusBadge(String status) {
    Color bg;
    switch (status) {
      case "confirmed":
        bg = Colors.green;
        break;
      case "completed":
        bg = Colors.blue;
        break;
      case "cancelled":
        bg = Colors.grey;
        break;
      case "pending":
        bg = const Color(0xFFD4BC4E);
        break;
      case "rescheduled":
        bg = Colors.purple;
        break;
      default:
        bg = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// ---------------------------
  /// BUTTONS - UPCOMING
  /// ---------------------------
  Widget _buildUpcomingButtons(Booking b) {
    final Color gold = const Color(0xFFD4BC4E);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Cancel
        _btn("Cancel", Colors.red, () {
          BookingService.cancelBooking(b.id);
          _fetchBookings();
        }),

        // View Details
        _btn("View Details", gold, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingDetailPage(booking: b),
            ),
          );
        }),

        // Reschedule
        _btn("Reschedule", const Color(0xFF0F0F38), () {
          showDialog(
            context: context,
            builder: (_) => RescheduleModal(booking: b),
          );
        }),
      ],
    );
  }

  /// ---------------------------
  /// BUTTONS - HISTORY
  /// ---------------------------
  Widget _buildHistoryButtons(Booking b) {
    final Color gold = const Color(0xFFD4BC4E);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _btn("View Your Review", gold, () {}),
        _btn("Book Again", const Color(0xFF0F0F38), () {}),
      ],
    );
  }

  /// ---------------------------
  /// REUSABLE BUTTON
  /// ---------------------------
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
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
