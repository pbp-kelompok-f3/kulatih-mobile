import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:kulatih_mobile/salman-tournament/page/tournament_main.dart';

class TournamentCreatePage extends StatefulWidget {
  const TournamentCreatePage({super.key});

  @override
  State<TournamentCreatePage> createState() => _TournamentCreatePageState();
}

class _TournamentCreatePageState extends State<TournamentCreatePage> {
  final _formKey = GlobalKey<FormState>();

  // === FORM FIELDS ===
  String _namaTournaments = "";
  String _posterTornaments = "";
  String _deskripsiTournaments = "";
  String _tanggalTournaments = "";
  String _lokasiTournaments = "";
  String _tipeTournaments = "Other";

  final List<String> _categoryTournaments = [
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
      appBar: AppBar(
        title: const Text("Create Tournament"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // === Nama Tournament ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Nama Tournament",
                    labelText: "Nama Tournament",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (v) => setState(() => _namaTournaments = v),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Nama wajib diisi!" : null,
                ),
              ),

              // === Deskripsi ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Deskripsi Tournament",
                    labelText: "Deskripsi",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (v) => setState(() => _deskripsiTournaments = v),
                ),
              ),

              // === Tanggal ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "YYYY-MM-DD",
                    labelText: "Tanggal Tournament",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (v) => setState(() => _tanggalTournaments = v),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Tanggal wajib diisi!" : null,
                ),
              ),

              // === Lokasi ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Lokasi Tournament",
                    labelText: "Lokasi",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (v) => setState(() => _lokasiTournaments = v),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Lokasi wajib diisi!" : null,
                ),
              ),

              // === Kategori ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Kategori Turnamen",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  value: _tipeTournaments,
                  items: _categoryTournaments
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _tipeTournaments = v ?? "Other"),
                ),
              ),

              // === Poster URL ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Poster URL (https://...)",
                    labelText: "Poster URL",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (v) => setState(() => _posterTornaments = v),
                ),
              ),

              // === Tombol Submit ===
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.indigo),
                    ),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      final response = await request.postJson(
                        "http://localhost:8000/tournament/json/tournaments/create/",
                        jsonEncode({
                          "namaTournaments": _namaTournaments,
                          "tipeTournaments": _tipeTournaments,
                          "tanggalTournaments": _tanggalTournaments,
                          "lokasiTournaments": _lokasiTournaments,
                          "deskripsiTournaments": _deskripsiTournaments,
                          "posterTournaments": _posterTornaments,
                        }),
                      );

                      if (!context.mounted) return;

                      if (response["id"] != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Tournament berhasil dibuat!"),
                          ),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TournamentMainPage(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Gagal: ${response["error"] ?? "Unknown error"}",
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Simpan",
                      style: TextStyle(color: Colors.white),
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
}
