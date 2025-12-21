import 'package:flutter/material.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';
import 'package:kulatih_mobile/izzati-forum/styles/text.dart';
import 'package:kulatih_mobile/salman-tournament/models/tournament_model.dart';
import 'package:kulatih_mobile/salman-tournament/widgets/tournament_assign.dart';
import 'package:kulatih_mobile/salman-tournament/page/tournament_edit.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:kulatih_mobile/salman-tournament/page/tournament_delete.dart';
import 'package:kulatih_mobile/salman-tournament/page/tournament_main.dart';
import 'package:kulatih_mobile/izzati-forum/styles/colors.dart';

class TournamentDetailPage extends StatefulWidget {
  final Tournament tournament;
  final String role;
  final String currentUsername;

  const TournamentDetailPage({
    super.key,
    required this.tournament,
    required this.role,
    required this.currentUsername,
  });

  @override
  State<TournamentDetailPage> createState() => _TournamentDetailPageState();
}

class _TournamentDetailPageState extends State<TournamentDetailPage> {
  late Tournament _tournamentData;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tournamentData = widget.tournament;
  }

  String formatTanggal(DateTime t) {
    const bulan = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];
    return "${t.day} ${bulan[t.month - 1]} ${t.year}";
  }

  Future<void> _refreshTournamentData() async {
    setState(() => _isRefreshing = true);
    final request = context.read<CookieRequest>();

    try {
      final response = await request.get(
        'https://muhammad-salman42-kulatih.pbp.cs.ui.ac.id/tournament/json/tournaments/',
      );

      final Map<String, dynamic> normalized =
          response is Map ? Map<String, dynamic>.from(response) : {};

      if (response is List) {
        normalized['role'] = 'unknown';
        normalized['username'] = '';
        normalized['tournaments'] = response;
      }

      final entry = TournamentEntry.fromJson(normalized);

      final updatedData = entry.tournaments.firstWhere(
        (t) => t.id == widget.tournament.id,
        orElse: () => _tournamentData,
      );

      if (mounted) {
        setState(() {
          _tournamentData = updatedData;
          _isRefreshing = false;
        });

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text(
      "Data turnamen diperbarui!",
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
    ),
    backgroundColor: AppColor.yellow,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
);

      }
    } catch (e) {
      if (mounted) setState(() => _isRefreshing = false);
      print("Gagal refresh data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCoach = widget.role == 'coach';
    final data = _tournamentData;

    final bool canSeeParticipants =
        widget.role == "coach" && data.pembuat == widget.currentUsername;
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: AppColor.indigo,
        foregroundColor: AppColor.yellow,
        title: Text(data.nama,
        style: heading(24, color: AppColor.yellow),
        ),
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColor.yellow,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
          color: AppColor.indigoDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                  bottom: Radius.circular(30),
                ),
                child: Image.network(
                  'https://muhammad-salman42-kulatih.pbp.cs.ui.ac.id/tournament/proxy-image/?url=${Uri.encodeComponent(data.poster)}',
                  height: 500,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'images/tournament_bg.png',
                    height: 500,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        data.nama,
                        style: heading(30, color: AppColor.yellow
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Participants (${data.participantCount})",
                      style: const TextStyle(
                        color: AppColor.yellow,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(
                color: Colors.white24,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColor.indigoLight,
                  borderRadius: BorderRadius.circular(100),
                ),
                width: 100,
                height: 30,
                margin: const EdgeInsets.only(left: 16, bottom: 10),
                child: Center(
                  child: Text(
                    data.tipe,
                    style: TextStyle(
                      color: AppColor.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.event,
                        color: AppColor.yellow, size: 30),
                    const SizedBox(width: 8),
                    Text(
                      formatTanggal(data.tanggal),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: AppColor.yellow, size: 30),
                    const SizedBox(width: 8),
                    Text(
                      data.lokasi,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(
                color: Colors.white24,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        'https://muhammad-salman42-kulatih.pbp.cs.ui.ac.id/tournament/proxy-image/?url=${Uri.encodeComponent(data.pembuatFoto)}',
                      ),
                      onBackgroundImageError: (_, __) {},
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Diselenggarakan oleh",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          data.pembuat.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: AppColor.indigoLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                child: Text(
                  data.deskripsi,
                  style: const TextStyle(
                    color: AppColor.white,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (isCoach && data.pembuat == widget.currentUsername) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Material(
                    color: const Color(0xFF10266A),
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TournamentEditPage(tournament: data),
                          ),
                        );
                        if (result == true) _refreshTournamentData();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Edit Turnamen",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Material(
                    color: Colors.red.shade800,
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Hapus Turnamen"),
                            content: const Text(
                                "Yakin ingin menghapus turnamen ini?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Batal"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final success =
                                      await TournamentDeleteService
                                          .deleteTournament(
                                    context: context,
                                    tournamentId: data.id,
                                  );
                                  if (!context.mounted) return;
                                  if (success) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              TournamentMainPage()),
                                    );
                                  }
                                },
                                child: const Text(
                                  "Hapus",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_forever, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Hapus Turnamen",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (widget.role == 'member') ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const Text(
                        "Bergabunglah dan tunjukkan kemampuanmu!",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Material(
                        color: const Color(0xFF10266A),
                        borderRadius: BorderRadius.circular(50),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            TournamentAssigner.assignToTournament(
                              context,
                              data.id,
                              data.nama,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Daftar Sekarang",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.keyboard_arrow_right_rounded,
                                    color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 30),
              if (canSeeParticipants) ...[
                const Divider(
                  color: Colors.white24,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
                  child: Text(
                    "LIST OF PARTICIPANT",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                if (data.participants.isEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "No participants yet.",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: data.participants.map((p) {
                        final member = p.member;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                'https://muhammad-salman42-kulatih.pbp.cs.ui.ac.id/tournament/proxy-image/?url=${Uri.encodeComponent(member.photo)}',
                              ),
                              backgroundColor: Colors.grey.shade800,
                            ),
                            title: Text(
                              member.username,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              member.city,
                              style:
                                  const TextStyle(color: Colors.white70),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
