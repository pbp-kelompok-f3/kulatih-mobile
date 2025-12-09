import 'package:flutter/material.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_service.dart';
import 'package:kulatih_mobile/khalisha-booking/screens/booking_form.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final BookingService _service = BookingService();

  int _selectedTabIndex = 0;
  bool _loading = true;

  List<Booking> _allBookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _loading = true);

    try {
      final list = await _service.getBookings();
      setState(() => _allBookings = list);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed loading bookings: $e")),
      );
    }

    setState(() => _loading = false);
  }

  // FILTERING LIST
  List<Booking> get _filteredBookings {
    final now = DateTime.now();

    if (_selectedTabIndex == 0) {
      // UPCOMING
      return _allBookings.where((b) {
        final future = b.endTime.isAfter(now);
        final active = [
          BookingStatus.pending,
          BookingStatus.confirmed,
          BookingStatus.rescheduled,
        ].contains(b.status);
        return future && active;
      }).toList();
    } else {
      // HISTORY
      return _allBookings.where((b) {
        final past = b.endTime.isBefore(now);
        final history = [
          BookingStatus.cancelled,
          BookingStatus.completed,
        ].contains(b.status);
        return past || history;
      }).toList();
    }
  }

  // OPEN CREATE BOOKING FORM
  Future<void> _openCreateBookingForm() async {
    final result = await Navigator.push<Booking>(
      context,
      MaterialPageRoute(
        builder: (_) => const BookingFormPage(isReschedule: false),
      ),
    );

    if (result != null) {
      await _fetchBookings();
    }
  }

  // OPEN RESCHEDULE FORM
  Future<void> _openRescheduleForm(Booking booking) async {
    final result = await Navigator.push<Booking>(
      context,
      MaterialPageRoute(
        builder: (_) => BookingFormPage(
          isReschedule: true,
          initialBooking: booking,
        ),
      ),
    );

    if (result != null) {
      await _fetchBookings();
    }
  }

  // CANCEL BOOKING
  Future<void> _cancelBooking(Booking booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C3A),
        title: const Text("Cancel Booking", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to cancel this booking?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.cancelBooking(booking.id);
      await _fetchBookings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F2A),
        elevation: 0,
        title: const Text(
          'MY BOOKINGS',
          style: TextStyle(color: Colors.white, letterSpacing: 1.5),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C3A),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton("Upcoming", 0),
                        _buildTabButton("Booking History", 1),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _filteredBookings.isEmpty
                      ? const Center(
                          child: Text("No bookings yet",
                              style: TextStyle(color: Colors.white54)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: _filteredBookings.length,
                          itemBuilder: (_, i) =>
                              _buildBookingCard(_filteredBookings[i]),
                        ),
                )
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD3B53E),
        foregroundColor: Colors.black,
        onPressed: _openCreateBookingForm,
        icon: const Icon(Icons.add),
        label: const Text("New Booking"),
      ),
    );
  }

  // TAB BUTTON
  Widget _buildTabButton(String label, int index) {
    final selected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFD3B53E) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  // BOOKING CARD
  Widget _buildBookingCard(Booking booking) {
    final d = booking.startTime;

    final dateText = "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/"
        "${d.year}";

    final timeText =
        "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C3A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // date + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$dateText · $timeText",
                  style: const TextStyle(color: Colors.white70, fontSize: 10)),
              _statusBadge(booking.status),
            ],
          ),

          const SizedBox(height: 12),

          // coach + sport
          Row(
            children: [
              const CircleAvatar(radius: 22, child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.coachName,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(booking.sport,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.place, size: 12, color: Colors.white54),
              const SizedBox(width: 4),
              Text(
                booking.location,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child:
                    _btn("Cancel", Colors.red, () => _cancelBooking(booking)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _btn(
                    "Reschedule", Colors.grey, () => _openRescheduleForm(booking)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btn(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
        ),
      ),
    );
  }

  // STATUS BADGE
  Widget _statusBadge(BookingStatus st) {
    Color c;
    switch (st) {
      case BookingStatus.pending:
        c = Colors.orange;
        break;
      case BookingStatus.confirmed:
        c = Colors.green;
        break;
      case BookingStatus.rescheduled:
        c = Colors.blue;
        break;
      case BookingStatus.cancelled:
        c = Colors.red;
        break;
      default:
        c = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: c, borderRadius: BorderRadius.circular(999)),
      child: Text(
        bookingStatusToText(st),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}
