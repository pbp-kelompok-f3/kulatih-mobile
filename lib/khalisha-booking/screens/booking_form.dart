import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_service.dart';
import 'package:kulatih_mobile/khalisha-booking/style/text.dart'; 

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
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      initialDate: _selectedDateTime ?? now,
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? now),
    );

    if (time == null) return;

    setState(() {
      _selectedDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
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

    bool success;

    if (widget.isReschedule) {
      success = await _service.rescheduleBooking(
        id: widget.initialBooking!.id,
        newStart: _selectedDateTime!,
      );
    } else {
      success = await _service.createBooking(
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
      SnackBar(content: Text(msg, style: body(14))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isReschedule;

    return Scaffold(
      backgroundColor: AppColors.indigo,
      appBar: AppBar(
        backgroundColor: AppColors.indigo,
        elevation: 0,
        title: Text(
          isEditing ? "Reschedule Booking" : "New Booking",
          style: heading(20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose Schedule",
              style: body(16),
            ),
            const SizedBox(height: 8),

            InkWell(
              onTap: _pickDateTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _selectedDateTime == null
                      ? "Tap to pick date & time"
                      : DateFormat("EEE, dd MMM yyyy • HH:mm")
                          .format(_selectedDateTime!),
                  style: body(14),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text(
              "Location",
              style: body(16),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _locationController,
              style: body(14),
              decoration: InputDecoration(
                hintText: "Enter location",
                hintStyle: body(14, color: Colors.white54),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
                  backgroundColor: AppColors.gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEditing ? "Save Changes" : "Book Now",
                  style: heading(16, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
