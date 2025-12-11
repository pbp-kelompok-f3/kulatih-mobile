import 'package:flutter/material.dart';
import 'package:kulatih_mobile/salman-tournament/models/tournament_model.dart';
import 'package:kulatih_mobile/salman-tournament/widgets/tournament_entry_card.dart';
import 'package:kulatih_mobile/salman-tournament/page/tournament_details.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class TournamentEntryList extends StatefulWidget {
  final String query;
  final String filter;

  const TournamentEntryList({
    super.key,
    required this.query,
    required this.filter,
  });

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

    if (mounted) {
      setState(() {
        allTournaments = entry.tournaments;
        userRole = entry.role;
        currentUsername =
            entry.namaUser;
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

  List<Tournament> filtered = allTournaments;

  if (q.isNotEmpty) {
    filtered = filtered.where((t) {
      final nama = t.nama.toLowerCase();
      final lokasi = t.lokasi.toLowerCase();
      final pembuat = t.pembuat.toLowerCase();
      final tipe = t.tipe.toLowerCase();

      return nama.contains(q) ||
             lokasi.contains(q) ||
             pembuat.contains(q) ||
             tipe.contains(q);
    }).toList();
  }

    if (widget.filter == "My Tournaments") {
      filtered = filtered.where((t) {
        final isCreator = t.pembuat == currentUsername;
        final isParticipant = t.participants.any(
          (p) => p.member.username == currentUsername,
        );

        return isCreator || isParticipant;
      }).toList();
    }

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
            onTap: () async {
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
              _fetchTournaments();
            },
          );
        },
      ),
    );
  }
}
