import 'package:flutter/material.dart';
import 'package:kulatih_mobile/salman-tournament/models/tournament_model.dart';

class TournamentEntryCard extends StatelessWidget {
  final Tournament tournament;
  final int index;
  final VoidCallback? onTap;

  const TournamentEntryCard({
    super.key,
    required this.tournament,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              spreadRadius: 1,
              color: Colors.black.withOpacity(0.25),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BANNER / POSTER
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Image.network(
                tournament.poster,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 170,
                  color: Colors.grey.shade900,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.white54),
                  ),
                ),
              ),
            ),

            // NAMA
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                tournament.nama,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // TIPE + TANGGAL + LOKASI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Icon(Icons.event, size: 16, color: Colors.orangeAccent),
                  const SizedBox(width: 6),
                  Text(
                    "${tournament.tanggal.toLocal()}".split(" ")[0],
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.orangeAccent),
                  const SizedBox(width: 6),
                  Text(
                    tournament.lokasi,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // PARTICIPANT COUNT
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 12),
              child: Text(
                "${tournament.participantCount} participants",
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
