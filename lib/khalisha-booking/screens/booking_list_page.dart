import 'package:flutter/material.dart';
import 'package:kulatih_mobile/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'package:kulatih_mobile/theme/app_colors.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_service.dart';
import 'package:kulatih_mobile/khalisha-booking/widgets/booking_card.dart';
import 'package:kulatih_mobile/models/user_provider.dart';
import 'package:kulatih_mobile/khalisha-booking/screens/booking_detail_page.dart';
import 'package:kulatih_mobile/khalisha-booking/screens/booking_reschedule_modal.dart';
import 'package:kulatih_mobile/khalisha-booking/style/text.dart';

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
      final request = context.read<CookieRequest>();
      final data = await _service.getBookings(request);
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
  List<Booking> get upcoming => _bookings.where((b) => b.isUpcoming).toList();
  List<Booking> get history => _bookings.where((b) => b.isHistory).toList();

  /* ---------------- CANCEL ---------------- */
  Future<void> _cancelBooking(Booking booking) async {
    try {
      final request = context.read<CookieRequest>();
      final ok = await _service.cancelBooking(request, booking.id);
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

  /* ---------------- RESCHEDULE ---------------- */
  Future<void> _openReschedule(Booking booking) async {
    final result = await showDialog(
      context: context,
      builder: (_) => RescheduleModal(booking: booking),
    );

    if (result != null) {
      _fetchBookings();
    }
  }

  /* ---------------- COACH ACTIONS ---------------- */
  Future<void> _accept(Booking booking) async {
    final request = context.read<CookieRequest>();
    final ok = await _service.acceptReschedule(request, booking.id);
    if (ok) await _fetchBookings();
  }

  Future<void> _reject(Booking booking) async {
    final request = context.read<CookieRequest>();
    final ok = await _service.rejectReschedule(request, booking.id);
    if (ok) await _fetchBookings();
  }

  Future<void> _confirm(Booking booking) async {
    final request = context.read<CookieRequest>();
    final ok = await _service.confirmBooking(request, booking.id);
    if (ok) await _fetchBookings();
  }

  /* ---------------- UI ---------------- */
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final isCoach = user.isCoach;

    return Scaffold(
      appBar: KulatihAppBar(),
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "MY BOOKINGS",
                style: heading(26, color: AppColors.textHeading),
              ),
            ),
            const SizedBox(height: 14),

            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(text: "Upcoming"),
                Tab(text: "History"),
              ],
              onTap: (_) => setState(() {}),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildList(upcoming, isCoach),
                        _buildList(history, isCoach),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Booking> list, bool isCoach) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          "No bookings found",
          style: body(14, color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final b = list[i];

        return BookingCard(
          booking: b,
          historyMode: b.isHistory,
          isCoach: isCoach,
          onCancel: () => _cancelBooking(b),
          onReschedule: () => _openReschedule(b),
          onAccept: isCoach ? () => _accept(b) : null,
          onReject: isCoach ? () => _reject(b) : null,
          onConfirm: isCoach ? () => _confirm(b) : null,
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
