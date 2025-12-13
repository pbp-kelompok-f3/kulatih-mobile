import 'package:flutter/material.dart';
import 'package:kulatih_mobile/salman-tournament/models/tournament_model.dart';
import 'package:kulatih_mobile/salman-tournament/widgets/tournament_entry_card.dart';
import 'package:kulatih_mobile/salman-tournament/page/tournament_details.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class TournamentEntryList extends StatefulWidget {
  final String query;

  const TournamentEntryList({super.key, required this.query});

  @override
  State<TournamentEntryList> createState() => _TournamentEntryListState();
}

class _TournamentEntryListState extends State<TournamentEntryList> {
  bool isLoading = true;
  List<Tournament> allTournaments = [];
  String userRole = 'unknown';
  String currentUsername = '';

  Future<void> _fetchTournaments() async {
    setState(() => isLoading = true);

    final request = context.read<CookieRequest>();
    // Pastikan URL benar (localhost vs 10.0.2.2)
    final raw = await request.get(
      'http://localhost:8000/tournament/json/tournaments/',
    );

    final Map<String, dynamic> normalized = raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};

    if (raw is List) {
      normalized['role'] = 'unknown';
      normalized['username'] = '';
      normalized['tournaments'] = raw;
    }

    final entry = TournamentEntry.fromJson(normalized);

    // Cek mounted agar aman saat setState
    if (mounted) {
      setState(() {
        allTournaments = entry.tournaments;
        userRole = entry.role;
        currentUsername = entry.namaUser; // Pastikan key di model sesuai (namaUser/username)
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetchTournaments);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.query.trim().toLowerCase();

    final filtered = q.isEmpty
        ? allTournaments
        : allTournaments
            .where((t) => t.nama.toLowerCase().contains(q))
            .toList();

    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 60),
          child: CircularProgressIndicator(color: Colors.orangeAccent),
        ),
      );
    }

    if (filtered.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 60),
          child: Text(
            "No tournaments found.",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 40),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final tournament = filtered[index];

          return TournamentEntryCard(
            tournament: tournament,
            onTap: () async { // <--- UPDATE DI SINI
              // 1. Tunggu user selesai lihat detail / edit
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TournamentDetailPage(
                    tournament: tournament,
                    role: userRole,
                    currentUsername: currentUsername,
                  ),
                ),
              );

              // 2. Refresh list setelah user kembali
              _fetchTournaments(); 
            },
          );
        },
      ),
    );
  }
}