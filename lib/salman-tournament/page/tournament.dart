import 'package:kulatih_mobile/salman-tournament/models/tournament_entry.dart'; // pastikan path sesuai
import 'package:kulatih_mobile/salman-tournament/models/tournament_fetch.dart';
import 'package:flutter/material.dart';

class MainTournamentPage extends StatefulWidget {
  const MainTournamentPage({super.key});

  @override
  State<MainTournamentPage> createState() => _MainTournamentPageState();
}

class _MainTournamentPageState extends State<MainTournamentPage> {
  late Future<TournamentEntry> tournamentsFuture;

  @override
  void initState() {
    super.initState();
    tournamentsFuture = fetchTournaments();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tournaments")),
      body: FutureBuilder<TournamentEntry>(
        future: tournamentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final tournaments = snapshot.data!.tournaments;

          if (tournaments.isEmpty) {
            return const Center(child: Text("No tournaments found."));
          }

          return ListView.builder(
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              final t = tournaments[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(t.nama),
                  subtitle: Text("${t.tipe} - ${t.tanggal.toLocal()}"),
                  onTap: () {
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

