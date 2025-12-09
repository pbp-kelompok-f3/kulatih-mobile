import 'package:flutter/material.dart';
import 'package:kulatih_mobile/salman-tournament/models/tournament_model.dart';
import 'package:kulatih_mobile/salman-tournament/widgets/tournament_entry_card.dart';
import 'package:kulatih_mobile/salman-tournament/page/tournament_details.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class TournamentEntryListPage extends StatefulWidget {
  const TournamentEntryListPage({super.key});

  @override
  State<TournamentEntryListPage> createState() => _TournamentEntryListPageState();
}

class _TournamentEntryListPageState extends State<TournamentEntryListPage> {
  bool isLoading = true;
  List<Tournament> tournaments = [];

  Future<void> fetchTournaments(CookieRequest request) async {
    setState(() => isLoading = true);

    final response = await request.get(
      'http://localhost:8000/tournament/json/tournaments/',
    );

    // Response adalah List<TournamentEntry>
    List<Tournament> list = [];
    for (var entry in response) {
      TournamentEntry tEntry = TournamentEntry.fromJson(entry);
      list.addAll(tEntry.tournaments); // karena model berisi role + list tournament
    }

    setState(() {
      tournaments = list;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final request = context.read<CookieRequest>();
      fetchTournaments(request);
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Tournament List"),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.orangeAccent,
              ),
            )
          : tournaments.isEmpty
              ? const Center(
                  child: Text(
                    "No tournaments available.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: tournaments.length,
                  itemBuilder: (context, index) {
                    final tour = tournaments[index];

                    return TournamentEntryCard(
                      tournament: tour,
                      index: index,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TournamentDetailPage(tournament: tour),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
