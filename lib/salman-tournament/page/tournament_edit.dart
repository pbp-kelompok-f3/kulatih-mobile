import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:kulatih_mobile/izzati-forum/styles/text.dart';
import 'package:kulatih_mobile/izzati-forum/styles/colors.dart';
import 'package:kulatih_mobile/salman-tournament/models/tournament_model.dart';

class TournamentEditPage extends StatefulWidget {
  final Tournament tournament;

  const TournamentEditPage({super.key, required this.tournament});

  @override
  State<TournamentEditPage> createState() => _TournamentEditPageState();
}

class _TournamentEditPageState extends State<TournamentEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _lokasiController;
  late TextEditingController _deskripsiController;
  late TextEditingController _dateController;
  late TextEditingController _posterController;

  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _namaController = TextEditingController(text: widget.tournament.nama);
    _lokasiController = TextEditingController(text: widget.tournament.lokasi);
    _deskripsiController = TextEditingController(
      text: widget.tournament.deskripsi,
    );
    _posterController = TextEditingController(text: widget.tournament.poster);

    _selectedDate = widget.tournament.tanggal;
    _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.tournament.tanggal),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    _posterController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColor.indigoLight,
      hintStyle: const TextStyle(color: Colors.white38),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColor.yellow, width: 2),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: body(14, color: Colors.white70)),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: AppColor.indigoLight,
            colorScheme: const ColorScheme.dark(
              primary: AppColor.yellow,
              surface: AppColor.indigoLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat("yyyy-MM-dd").format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: AppColor.indigoDark,
      appBar: AppBar(
        title: Text("EDIT TOURNAMENT", style: heading(45, color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColor.indigoDark,
        elevation: 0,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Nama Tournament"),
              TextFormField(
                controller: _namaController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration().copyWith(
                  hintText: "Enter tournament name",
                ),
                validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
              ),

              const SizedBox(height: 15),

              _buildLabel("Tanggal Tournament"),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration().copyWith(
                      hintText: "mm/dd/yyyy",
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: AppColor.yellow,
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? "Tanggal wajib diisi" : null,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              _buildLabel("Lokasi Tournament"),
              TextFormField(
                controller: _lokasiController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration().copyWith(
                  hintText: "Enter location",
                ),
                validator: (v) => v!.isEmpty ? "Lokasi wajib diisi" : null,
              ),

              const SizedBox(height: 15),

              _buildLabel("Poster URL"),
              TextFormField(
                controller: _posterController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration().copyWith(
                  hintText: "Enter poster URL",
                ),
              ),

              const SizedBox(height: 15),

              _buildLabel("Deskripsi"),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration().copyWith(
                  hintText: "Enter description",
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// CANCEL
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  /// SAVE
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;

                            setState(() => _isLoading = true);

                            final response = await request.postJson(
                              "https://muhammad-salman42-kulatih.pbp.cs.ui.ac.id/tournament/json/tournaments/${widget.tournament.id}/edit/",
                              jsonEncode({
                                "namaTournaments": _namaController.text,
                                "lokasiTournaments": _lokasiController.text,
                                "deskripsiTournaments":
                                    _deskripsiController.text,
                                "posterTournaments": _posterController.text,
                                "tanggalTournaments": _dateController.text,
                              }),
                            );

                            setState(() => _isLoading = false);

                            if (response["message"] != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    response["message"],
                                    style: const TextStyle(
                                      color: Colors
                                          .black, // biar kontras sama kuning
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: AppColor.yellow,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                              Navigator.pop(context, true);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    response["error"] ?? "Terjadi kesalahan",
                                  ),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.yellow,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Save",
                            style: TextStyle(color: Colors.black),
                          ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
