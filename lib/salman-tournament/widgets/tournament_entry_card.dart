import 'package:flutter/material.dart';
import 'package:kulatih_mobile/salman-tournament/models/tournament_model.dart';

class TournamentEntryCard extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback? onTap;

  const TournamentEntryCard({
    super.key,
    required this.tournament,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2F),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(0.35),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BANNER
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: (tournament.poster.isEmpty)
    ? Image.asset(
        "assets/images/tournament_bg.png",
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      )
    : Image.network(
        tournament.poster,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            "images/tournament_bg.png",
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        },
      )
            ),

            // CONTENT
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tournament.nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.event, size: 16, color: Colors.orangeAccent),
                      const SizedBox(width: 8),
                      Text(
                        "${tournament.tanggal.toLocal()}".split(" ")[0],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.orangeAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tournament.lokasi,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
