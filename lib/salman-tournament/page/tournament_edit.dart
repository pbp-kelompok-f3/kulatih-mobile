import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Jangan lupa: flutter pub add intl
import 'package:kulatih_mobile/salman-tournament/models/tournament_model.dart';

class TournamentEditPage extends StatefulWidget {
  final Tournament tournament;

  const TournamentEditPage({super.key, required this.tournament});

  @override
  State<TournamentEditPage> createState() => _TournamentEditPageState();
}

class _TournamentEditPageState extends State<TournamentEditPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk input
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
    // Isi form dengan data yang sudah ada (Pre-fill)
    _namaController = TextEditingController(text: widget.tournament.nama);
    _lokasiController = TextEditingController(text: widget.tournament.lokasi);
    _deskripsiController = TextEditingController(
      text: widget.tournament.deskripsi,
    );
    _posterController = TextEditingController(text: widget.tournament.poster);

    _selectedDate = widget.tournament.tanggal;
    // Format tanggal untuk tampilan (ex: 2023-12-01)
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

  // Fungsi Helper untuk memilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        // Custom theme date picker biar gelap (sesuai tema app)
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.orangeAccent,
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF121212),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Background gelap
      appBar: AppBar(
        title: const Text("Edit Turnamen"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- NAMA TURNAMEN ---
              _buildLabel("Nama Turnamen"),
              TextFormField(
                controller: _namaController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Contoh: Armaso 2026"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- LOKASI ---
              _buildLabel("Lokasi"),
              TextFormField(
                controller: _lokasiController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Contoh: GOR Pertamina"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lokasi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- TANGGAL ---
              _buildLabel("Tanggal Pelaksanaan"),
              TextFormField(
                controller: _dateController,
                readOnly: true, // Tidak bisa diketik manual, harus dipencet
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("YYYY-MM-DD").copyWith(
                  suffixIcon: const Icon(
                    Icons.calendar_today,
                    color: Colors.orangeAccent,
                  ),
                ),
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildLabel("Link Poster (URL)"),
              TextFormField(
                controller: _posterController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.url, // Keyboard khusus URL
                decoration: _inputDecoration(
                  "Contoh: https://imgur.com/foto.jpg",
                ),
                // Validator opsional, kalau boleh kosong hapus saja validator ini
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Link poster tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- DESKRIPSI ---
              _buildLabel("Deskripsi"),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 5, // Input paragraf
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Tulis deskripsi turnamen..."),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10266A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);

                            final url =
                                "http://localhost:8000/tournament/json/tournaments/${widget.tournament.id}/edit/";

                            final Map<String, dynamic> dataPayload = {
                              "namaTournaments": _namaController.text,
                              "lokasiTournaments": _lokasiController.text,
                              "deskripsiTournaments": _deskripsiController.text,
                              "posterTournaments": _posterController.text,
                              "tanggalTournaments": _dateController.text,
                            };

                            try {
                              final response = await request.postJson(
                                url,
                                jsonEncode(dataPayload),
                              );

                              setState(() => _isLoading = false);

                              if (response['message'] != null) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response['message']),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.pop(context, true);
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        response['error'] ??
                                            "Terjadi kesalahan",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              setState(() => _isLoading = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Simpan Perubahan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24),
      filled: true,
      fillColor: const Color(0xFF1E1E1E), // Warna box input
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.orangeAccent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
