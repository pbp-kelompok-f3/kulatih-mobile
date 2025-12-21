import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kulatih_mobile/theme/app_colors.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_service.dart';
import 'package:kulatih_mobile/khalisha-booking/style/text.dart';
import 'package:kulatih_mobile/models/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class BookingFormPage extends StatefulWidget {
  final bool isReschedule;
  final Booking? initialBooking;
  final String? coachId;

  const BookingFormPage({
    super.key,
    required this.isReschedule,
    this.initialBooking,
    this.coachId,
  });

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final BookingService _service = BookingService();

  DateTime? _selectedDateTime;
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.isReschedule && widget.initialBooking != null) {
      _selectedDateTime = widget.initialBooking!.startTime;
      _locationController.text = widget.initialBooking!.location;
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _selectedDateTime ?? DateTime.now(),
      ),
    );

    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (_selectedDateTime == null) {
      _showError("Please choose a schedule.");
      return;
    }

    if (_locationController.text.trim().isEmpty) {
      _showError("Location cannot be empty.");
      return;
    }

    final request = context.read<CookieRequest>();

    bool success;

    if (widget.isReschedule) {
      success = await _service.rescheduleBooking(
        request: request,
        id: widget.initialBooking!.id,
        newStart: _selectedDateTime!,
      );
    } else {
      success = await _service.createBooking(
        request: request,
        coachId: widget.coachId ?? "1",
        location: _locationController.text.trim(),
        dateTime: _selectedDateTime!,
      );
    }

    if (!success) {
      _showError("Failed to process booking. Try again.");
      return;
    }

    if (context.mounted) Navigator.pop(context, true);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: body(14, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isReschedule;
    final user = context.watch<UserProvider>();

    if (user.isCoach) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.bg,
          elevation: 0,
          title: Text(
            "New Booking",
            style: heading(20, color: AppColors.textHeading),
          ),
        ),
        body: Center(
          child: Text(
            "Coaches cannot create bookings",
            style: body(16, color: AppColors.textPrimary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text(
          isEditing ? "Reschedule Booking" : "New Booking",
          style: heading(20, color: AppColors.textHeading),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Schedule",
              style: heading(18, color: AppColors.textHeading),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _pickDateTime,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _selectedDateTime == null
                      ? "Choose date & time"
                      : DateFormat('EEEE, dd MMM yyyy HH:mm')
                          .format(_selectedDateTime!),
                  style: body(14, color: AppColors.textPrimary),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "Location",
              style: heading(18, color: AppColors.textHeading),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              style: body(14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.cardBg,
                hintText: "Enter location",
                hintStyle: body(14, color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isEditing ? "Submit Reschedule" : "Create Booking",
                  style: body(15, color: AppColors.buttonText),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
