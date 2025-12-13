import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:kulatih_mobile/salman-tournament/page/tournament_main.dart';
import 'package:kulatih_mobile/izzati-forum/styles/text.dart';
import 'package:kulatih_mobile/izzati-forum/styles/colors.dart';

class TournamentCreatePage extends StatefulWidget {
  const TournamentCreatePage({super.key});

  @override
  State<TournamentCreatePage> createState() => _TournamentCreatePageUIState();
}

class _TournamentCreatePageUIState extends State<TournamentCreatePage> {
  final _formKey = GlobalKey<FormState>();

  String _nama = "";
  String _poster = "";
  String _deskripsi = "";
  String _tanggal = "";
  String _lokasi = "";
  String _tipe = "Other";

  final List<String> _kategori = [
    'Gym & Fitness',
    'Football',
    'Futsal',
    'Basketball',
    'Tennis',
    'Badminton',
    'Swimming',
    'Yoga',
    'Martial Arts',
    'Golf',
    'Volleyball',
    'Running',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFF0E0D25), // DARK NAVY BG
      appBar: AppBar(
        title: Text(
          "CREATE TOURNAMENT",
          style: heading( 45, color: Colors.white )
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0E0D25),
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

              /// NAME
              _buildLabel("Nama Tournament"),
              _buildInput(
                hint: "Enter tournament name",
                onChanged: (v) => _nama = v,
                validator: (v) =>
                    v!.isEmpty ? "Nama wajib diisi" : null,
              ),

              SizedBox(height: 15),

              /// TIPE (Dropdown)
              _buildLabel("Tipe Tournament"),
              DropdownButtonFormField<String>(
                value: _tipe,
                dropdownColor: const Color(0xFF1B1A31),
                decoration: _inputDecoration(),
                items: _kategori
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _tipe = v ?? "Other"),
              ),

              SizedBox(height: 15),

              /// DATE
              _buildLabel("Tanggal Tournament"),
              GestureDetector(
                onTap: () async {
                  DateTime? pick = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          dialogBackgroundColor: Color(0xFF1B1A31),
                          colorScheme: ColorScheme.dark(
                            primary: Colors.yellow,
                            surface: Color(0xFF1B1A31),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pick != null) {
                    setState(() => _tanggal = "${pick.year}-${pick.month}-${pick.day}");
                  }
                },
                child: AbsorbPointer(
                  child: _buildInput(
                    hint: "mm/dd/yyyy",
                    controller: TextEditingController(text: _tanggal),
                    validator: (v) =>
                        v!.isEmpty ? "Tanggal wajib diisi" : null,
                  ),
                ),
              ),

              SizedBox(height: 15),

              /// LOKASI
              _buildLabel("Lokasi Tournament"),
              _buildInput(
                hint: "Enter location",
                onChanged: (v) => _lokasi = v,
                validator: (v) =>
                    v!.isEmpty ? "Lokasi wajib diisi" : null,
              ),

              SizedBox(height: 15),

              /// POSTER URL
              _buildLabel("Poster URL"),
              _buildInput(
                hint: "Enter poster URL",
                onChanged: (v) => _poster = v,
              ),

              SizedBox(height: 15),

              /// DESKRIPSI
              _buildLabel("Deskripsi"),
              _buildInput(
                hint: "Enter description",
                maxLines: 4,
                onChanged: (v) => _deskripsi = v,
              ),

              const SizedBox(height: 30),

              /// BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _cancelButton(context),
                  _createButton(request, context),
                ],
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // UI COMPONENTS ============================================================

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF1B1A31),
      hintStyle: const TextStyle(color: Colors.white38),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.yellow),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildInput({
    required String hint,
    TextEditingController? controller,
    int maxLines = 1,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration().copyWith(hintText: hint),
      validator: validator,
      onChanged: onChanged,
    );
  }

  Widget _cancelButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF5D637A),
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text("Cancel", style: TextStyle(color: Colors.white)),
    );
  }

  Widget _createButton(CookieRequest request, BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (!_formKey.currentState!.validate()) return;

        final res = await request.postJson(
          "http://localhost:8000/tournament/json/tournaments/create/",
          jsonEncode({
            "namaTournaments": _nama,
            "tipeTournaments": _tipe,
            "tanggalTournaments": _tanggal,
            "lokasiTournaments": _lokasi,
            "deskripsiTournaments": _deskripsi,
            "posterTournaments": _poster,
          }),
        );

        if (res["id"] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Tournament berhasil dibuat!")),
          );
          Navigator.pop(context,true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal: ${res["error"]}")),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow.shade600,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        "Create",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }
}
