import 'package:flutter/material.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_model.dart';
import 'package:kulatih_mobile/khalisha-booking/booking_service.dart';
import 'package:kulatih_mobile/khalisha-booking/style/text.dart'; 

class RescheduleModal extends StatefulWidget {
  final Booking booking;

  const RescheduleModal({super.key, required this.booking});

  @override
  State<RescheduleModal> createState() => _RescheduleModalState();
}

class _RescheduleModalState extends State<RescheduleModal> {
  final BookingService _service = BookingService();

  DateTime? _newDate;
  TimeOfDay? _newStart;

  bool _loading = false;

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: widget.booking.startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (result != null) {
      setState(() => _newDate = result);
    }
  }

  Future<void> _pickStart() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.booking.startTime),
    );
    if (t != null) setState(() => _newStart = t);
  }

  Future<void> _submit() async {
    if (_newDate == null || _newStart == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please select new date & time",
            style: body(14),
          ),
        ),
      );
      return;
    }

    final newStartTime = DateTime(
      _newDate!.year,
      _newDate!.month,
      _newDate!.day,
      _newStart!.hour,
      _newStart!.minute,
    );

    setState(() => _loading = true);

    try {
      await _service.rescheduleBooking(
        id: widget.booking.id,
        newStart: newStartTime,
      );

      if (!mounted) return;

      Navigator.pop(context, false); // JANGAN REFRESH LIST

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Waiting for coach confirmation...",
            style: body(14),
          ),
        ),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed: $e",
            style: body(14),
          ),
        ),
      );
    }
  }

  Widget _picker(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: body(14, color: Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reschedule Booking",
              style: heading(20, color: Colors.black),
            ),

            const SizedBox(height: 20),

            _picker(
              _newDate == null
                  ? "Select New Date"
                  : "${_newDate!.day}/${_newDate!.month}/${_newDate!.year}",
              _pickDate,
            ),
            const SizedBox(height: 12),

            _picker(
              _newStart == null
                  ? "Select Start Time"
                  : "${_newStart!.hour.toString().padLeft(2, '0')}:${_newStart!.minute.toString().padLeft(2, '0')}",
              _pickStart,
            ),
            const SizedBox(height: 20),

            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4BC4E),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      "Submit",
                      style: heading(14, color: Colors.black),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
