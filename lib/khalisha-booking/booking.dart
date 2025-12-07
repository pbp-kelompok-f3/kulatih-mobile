import 'package:flutter/material.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';
import 'package:kulatih_mobile/khalisha-booking/screens/booking_form.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int _selectedTabIndex = 0; // 0 = Upcoming, 1 = History

  // sementara masih dummy lokal
  final List<Booking> _allBookings = [
    Booking(
      id: 1,
      coachName: 'Patrick Kluivert',
      sport: 'Football',
      location: 'Koci Soccer Field, Depok',
      startTime: DateTime(2025, 11, 8, 15, 0),
      endTime: DateTime(2025, 11, 8, 17, 0),
      status: BookingStatus.confirmed,
    ),
    Booking(
      id: 2,
      coachName: 'Agung Hercules',
      sport: 'Gym',
      location: 'Fit Gym, Jakarta Selatan',
      startTime: DateTime(2025, 10, 9, 14, 0),
      endTime: DateTime(2025, 10, 9, 16, 0),
      status: BookingStatus.completed,
    ),
    Booking(
      id: 3,
      coachName: 'Rui Costa',
      sport: 'Football',
      location: 'Lapangan ABC, Jakarta',
      startTime: DateTime(2025, 12, 20, 10, 0),
      endTime: DateTime(2025, 12, 20, 12, 0),
      status: BookingStatus.pending,
    ),
  ];

  List<Booking> get _filteredBookings {
    final now = DateTime.now();

    if (_selectedTabIndex == 0) {
      // Upcoming
      return _allBookings.where((b) {
        final isFuture = b.endTime.isAfter(now);
        final isActiveStatus = b.status == BookingStatus.pending ||
            b.status == BookingStatus.confirmed ||
            b.status == BookingStatus.rescheduled;
        return isFuture && isActiveStatus;
      }).toList();
    } else {
      // History
      return _allBookings.where((b) {
        final isPast = b.endTime.isBefore(now);
        final isHistoryStatus = b.status == BookingStatus.cancelled ||
            b.status == BookingStatus.completed;
        return isPast || isHistoryStatus;
      }).toList();
    }
  }

  Future<void> _openCreateBookingForm() async {
    final result = await Navigator.push<Booking>(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingFormPage(
          isReschedule: false,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _allBookings.add(result);
      });
    }
  }

  Future<void> _openRescheduleForm(Booking booking) async {
    final result = await Navigator.push<Booking>(
      context,
      MaterialPageRoute(
        builder: (context) => BookingFormPage(
          isReschedule: true,
          initialBooking: booking,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        final idx =
            _allBookings.indexWhere((element) => element.id == booking.id);
        if (idx != -1) {
          _allBookings[idx] = result;
        }
      });
    }
  }

  Future<void> _cancelBooking(Booking booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C3A),
        title: const Text(
          'Cancel Booking',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to cancel this booking?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      final idx =
          _allBookings.indexWhere((element) => element.id == booking.id);
      if (idx != -1) {
        _allBookings[idx] =
            _allBookings[idx].copyWith(status: BookingStatus.cancelled);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking #${booking.id} cancelled (local only)'),
      ),
    );
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
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C3A),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  _buildTabButton('Upcoming', 0),
                  _buildTabButton('Booking History', 1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredBookings.isEmpty
                ? const Center(
                    child: Text(
                      'No bookings yet',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = _filteredBookings[index];
                      return _buildBookingCard(booking);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD3B53E),
        foregroundColor: Colors.black,
        onPressed: _openCreateBookingForm,
        icon: const Icon(Icons.add),
        label: const Text('New Booking'),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD3B53E) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final dateText =
        '${booking.startTime.day.toString().padLeft(2, '0')}/${booking.startTime.month.toString().padLeft(2, '0')}/${booking.startTime.year}';
    final timeText =
        '${booking.startTime.hour.toString().padLeft(2, '0')}:${booking.startTime.minute.toString().padLeft(2, '0')}'
        ' - '
        '${booking.endTime.hour.toString().padLeft(2, '0')}:${booking.endTime.minute.toString().padLeft(2, '0')}';

    final statusText = bookingStatusToText(booking.status);
    final Color statusColor;
    switch (booking.status) {
      case BookingStatus.pending:
        statusColor = Colors.orange;
        break;
      case BookingStatus.confirmed:
        statusColor = Colors.green;
        break;
      case BookingStatus.rescheduled:
        statusColor = Colors.blue;
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.red;
        break;
      case BookingStatus.completed:
        statusColor = Colors.grey;
        break;
    }

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
          // tanggal + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$dateText · $timeText',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // coach + lokasi
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                child: Icon(Icons.person),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.coachName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    booking.sport,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.place,
                        size: 12,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        booking.location,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // tombol-tombol
          Row(
            children: [
              Expanded(
                child: _buildSmallButton(
                  label: 'Cancel',
                  color: Colors.red,
                  onTap: () => _cancelBooking(booking),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSmallButton(
                  label: 'View Details',
                  color: Colors.amber,
                  onTap: () {
                    // TODO: nanti bikin halaman detail
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('View details booking #${booking.id}'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSmallButton(
                  label: 'Reschedule',
                  color: Colors.grey,
                  onTap: () => _openRescheduleForm(booking),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
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
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
