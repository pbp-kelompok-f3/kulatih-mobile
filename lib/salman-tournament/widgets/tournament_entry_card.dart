import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kulatih_mobile/izzati-forum/styles/colors.dart';
import 'package:kulatih_mobile/izzati-forum/styles/text.dart';
import 'package:kulatih_mobile/salman-tournament/models/tournament_model.dart';

class TournamentEntryCard extends StatefulWidget {
  final Tournament tournament;
  final VoidCallback? onTap;

  const TournamentEntryCard({super.key, required this.tournament, this.onTap});

  @override
  State<TournamentEntryCard> createState() => _TournamentEntryCardState();
}

class _TournamentEntryCardState extends State<TournamentEntryCard> {
  String get formattedDate =>
      DateFormat('MMM dd, yyyy').format(widget.tournament.tanggal);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 22),
        decoration: BoxDecoration(
          color: Color(0xFF242244),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.12),
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- POSTER + BADGES ----------
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              child: Stack(
                children: [
                  (widget.tournament.poster.isEmpty)
                      ? Image.asset(
                          "images/tournament_bg.png",
                          height: 500,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          'https://muhammad-salman42-kulatih.pbp.cs.ui.ac.id/tournament/proxy-image/?url=${Uri.encodeComponent(widget.tournament.poster)}',
                          height: 500,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "images/tournament_bg.png",
                              height: 500,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
                        ),

                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 90,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromARGB(180, 0, 0, 0),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // TYPE BADGE
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4D03F),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        widget.tournament.tipe.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  // DATE BADGE
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4D03F),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        formattedDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ---------- CONTENT ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Text(
                    widget.tournament.nama,
                    style: heading(25, color: Colors.white),
                  ),

                  const SizedBox(height: 14),

                  // BY
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        "By ${widget.tournament.pembuat}",
                        style: body(16, color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // LOCATION
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.tournament.lokasi,
                          style: body(16, color: Colors.white),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  // Divider dulu
                  Divider(
                    color: Colors.white.withOpacity(0.3),
                    height: 24,
                    thickness: 1,
                  ),

                  // Tombol View Details
                  GestureDetector(
                    onTap: widget.onTap, // atau fungsi lain
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD22E), Color(0xFFF4C320)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "View Details",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
