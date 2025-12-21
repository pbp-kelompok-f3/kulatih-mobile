import 'package:flutter/material.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_service.dart';
import 'package:kulatih_mobile/khalisha-booking/screens/booking_form.dart';
import 'package:kulatih_mobile/khalisha-booking/screens/booking_detail_page.dart';
import 'package:kulatih_mobile/khalisha-booking/widgets/booking_card.dart';
import 'package:kulatih_mobile/khalisha-booking/widgets/tab_switcher.dart';
import 'package:provider/provider.dart';
import 'package:kulatih_mobile/models/user_provider.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final BookingService _service = BookingService();

  int _selectedTab = 0; // 0 = Upcoming, 1 = History
  bool _loading = true;

  List<Booking> _bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  // ================================
  // FETCH BOOKINGS
  // ================================
  Future<void> _fetchBookings() async {
    setState(() => _loading = true);

    try {
      final list = await _service.getBookings();
      setState(() => _bookings = list);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed loading bookings: $e")),
      );
    }

    setState(() => _loading = false);
  }

  // ================================
  // FILTER
  // ================================
  List<Booking> get _upcoming =>
      _bookings.where((b) => b.isUpcoming).toList();

  List<Booking> get _history =>
      _bookings.where((b) => b.isHistory).toList();

  List<Booking> get _filtered =>
      _selectedTab == 0 ? _upcoming : _history;

  // ================================
  // USER ACTIONS
  // ================================
  Future<void> _openCreateBooking() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BookingFormPage(
          isReschedule: false,
          coachId: "1",
        ),
      ),
    );

    if (result != null) _fetchBookings();
  }

  Future<void> _openReschedule(Booking booking) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingFormPage(
          isReschedule: true,
          initialBooking: booking,
        ),
      ),
    );

    if (result != null) _fetchBookings();
  }

  Future<void> _cancelBooking(Booking booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title:
            const Text("Cancel Booking", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to cancel?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.cancelBooking(booking.id);
      _fetchBookings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to cancel: $e")),
      );
    }
  }

  // ================================
  // COACH ACTIONS
  // ================================
  Future<void> _acceptReschedule(Booking booking) async {
    try {
      final ok = await _service.acceptReschedule(booking.id);
      if (ok) {
        _fetchBookings();
      } else {
        throw Exception("API returned false");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to accept: $e")),
      );
    }
  }

  Future<void> _rejectReschedule(Booking booking) async {
    try {
      final ok = await _service.rejectReschedule(booking.id);
      if (ok) {
        _fetchBookings();
      } else {
        throw Exception("API returned false");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to reject: $e")),
      );
    }
  }

  Future<void> _confirmBooking(Booking booking) async {
    try {
      final ok = await _service.confirmBooking(booking.id);
      if (ok) {
        _fetchBookings();
      } else {
        throw Exception("API returned false");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to confirm: $e")),
      );
    }
  }

  // ================================
  // BUILD UI
  // ================================
  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final bool isCoach = userProvider.isCoach;

    return Scaffold(
      backgroundColor: AppColors.indigo,
      appBar: AppBar(
        backgroundColor: AppColors.indigo,
        elevation: 0,
        title: const Text(
          "MY BOOKINGS",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 12),

                TabSwitcher(
                  selectedIndex: _selectedTab,
                  onTabSelected: (index) {
                    setState(() => _selectedTab = index);
                  },
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: _filtered.isEmpty
                      ? const Center(
                          child: Text(
                            "No bookings found",
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 18),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final b = _filtered[i];

                            if (b.isHistory) {
                              return BookingCard(
                                booking: b,
                                historyMode: true,
                                isCoach: isCoach,
                                onCancel: () {},
                                onReschedule: () {},
                                onViewReview: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          BookingDetailPage(booking: b),
                                    ),
                                  );
                                },
                                onBookAgain: () {},
                              );
                            }

                            return BookingCard(
                              booking: b,
                              historyMode: false,
                              isCoach: isCoach,
                              onCancel: () => _cancelBooking(b),
                              onReschedule: () => _openReschedule(b),

                              // ===== COACH BUTTONS =====
                              onAccept: isCoach
                                  ? () => _acceptReschedule(b)
                                  : null,
                              onReject: isCoach
                                  ? () => _rejectReschedule(b)
                                  : null,
                              onConfirm: isCoach
                                  ? () => _confirmBooking(b)
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            ),

      floatingActionButton: isCoach
    ? null
    : FloatingActionButton.extended(
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.black,
        onPressed: _openCreateBooking,
        icon: const Icon(Icons.add),
        label: const Text("New Booking"),
      ),
    );
  }
}
