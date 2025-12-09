import 'package:flutter/material.dart';
import 'package:kulatih_mobile/salman-tournament/models/tournament_model.dart';

class TournamentDetailPage extends StatelessWidget {
  final Tournament tournament;

  const TournamentDetailPage({
    super.key,
    required this.tournament,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(tournament.nama),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // POSTER IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Image.network(
                tournament.poster,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 240,
                  color: Colors.grey.shade900,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.white54),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // NAMA TOURNAMENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                tournament.nama,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // TIPE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.sports_martial_arts, color: Colors.orangeAccent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    tournament.tipe,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // TANGGAL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.event, color: Colors.orangeAccent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "${tournament.tanggal.toLocal()}".split(" ")[0],
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // LOKASI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.orangeAccent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    tournament.lokasi,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // DESKRIPSI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                tournament.deskripsi,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),

            const SizedBox(height: 20),

            // PEMBUAT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Created by: ${tournament.pembuat}",
                style: const TextStyle(color: Colors.orangeAccent, fontSize: 14),
              ),
            ),

            const SizedBox(height: 20),

            // PESERTA COUNT TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Participants (${tournament.participantCount})",
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // LIST PESERTA
            if (tournament.participants.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "No participants yet.",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: tournament.participants.map((participant) {
                    final member = participant.member;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(member.photo),
                          onBackgroundImageError: (_, __) {},
                          backgroundColor: Colors.grey.shade800,
                        ),
                        title: Text(
                          member.username,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          member.city,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
