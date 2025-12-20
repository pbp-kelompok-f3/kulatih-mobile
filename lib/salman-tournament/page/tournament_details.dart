import 'package:flutter/material.dart';
import 'package:kulatih_mobile/salman-tournament/models/tournament_model.dart';
import 'package:kulatih_mobile/salman-tournament/widgets/tournament_assign.dart';
import 'package:kulatih_mobile/salman-tournament/page/tournament_edit.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart'; // Jangan lupa import ini
import 'package:provider/provider.dart'; // Jangan lupa import ini
import 'package:kulatih_mobile/salman-tournament/page/tournament_delete.dart';
import 'package:kulatih_mobile/salman-tournament/page/tournament_main.dart';

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
  // 1. Variabel State untuk menyimpan data yang bisa berubah (hasil edit)
  late Tournament _tournamentData;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi data awal dari halaman sebelumnya
    _tournamentData = widget.tournament;
  }

  // 2. Fungsi Helper Format Tanggal
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

  // 3. Fungsi Refresh Data dari Server
  Future<void> _refreshTournamentData() async {
    setState(() => _isRefreshing = true);
    final request = context.read<CookieRequest>();

    try {
      // NOTE: Ganti localhost dengan 10.0.2.2 jika pakai Emulator Android
      // Mengambil ulang list turnamen untuk mendapatkan data terbaru
      final response = await request.get(
        'http://localhost:8000/tournament/json/tournaments/',
      );

      // Parsing JSON manual (Sesuai struktur JSON kamu sebelumnya)
      final Map<String, dynamic> normalized = response is Map
          ? Map<String, dynamic>.from(response)
          : {};

      if (response is List) {
        normalized['role'] = 'unknown';
        normalized['username'] = '';
        normalized['tournaments'] = response;
      }

      final entry = TournamentEntry.fromJson(normalized);

      // Cari turnamen ini berdasarkan ID di dalam list yang baru diambil
      // Jika tidak ketemu (misal dihapus), tetap pakai data lama
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
          const SnackBar(content: Text("Data turnamen diperbarui!")),
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

    // PENTING: Gunakan _tournamentData (State) bukan widget.tournament
    final data = _tournamentData;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(data.nama), // Pakai data dari state
        actions: [
          // Indikator loading kecil kalau lagi refresh
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // POSTER IMAGE
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                  bottom: Radius.circular(30),
                ),
                child: Image.network(
                  'http://localhost:8000/tournament/proxy-image/?url=${Uri.encodeComponent(data.poster)}',
                  height: 500,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'images/tournament_bg.png', // Pastikan path asset benar (tanpa slash depan biasanya)
                    height: 500,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // NAMA TOURNAMENT
              Row(
                children: [
                  Expanded(
                    // Pake Expanded biar text panjang ga error overflow
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        data.nama,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // PESERTA COUNT TITLE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Participants (${data.participantCount})",
                      style: const TextStyle(
                        color: Colors.orangeAccent,
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

              // TIPE
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 30, 30, 30),
                  borderRadius: BorderRadius.circular(100),
                ),
                width: 100,
                height: 30,
                margin: const EdgeInsets.only(left: 16, bottom: 10),
                child: Center(
                  child: Text(
                    data.tipe,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // TANGGAL
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.event,
                      color: Colors.orangeAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatTanggal(data.tanggal),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
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
                    const Icon(
                      Icons.location_on,
                      color: Colors.orangeAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      data.lokasi,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
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

              // PEMBUAT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ClipOval(
                        child: Image.network(
                          'http://localhost:8000/tournament/proxy-image/?url=${Uri.encodeComponent(data.pembuatFoto)}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "images/tournament_bg.png",
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
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
                            fontWeight: FontWeight.w400,
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

              // DESKRIPSI
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5E1),
                  borderRadius: BorderRadius.circular(12),
                ),
                width: double.infinity,
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    data.deskripsi,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // --- LOGIC TOMBOL COACH (EDIT / DELETE) ---
              if (isCoach && data.pembuat == widget.currentUsername) ...[
                const SizedBox(height: 20),

                // TOMBOL EDIT
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Material(
                    color: const Color(0xFF10266A),
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () async {
                        // 1. Pindah ke halaman Edit dan TUNGGU (await) hasilnya
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TournamentEditPage(tournament: data),
                          ),
                        );

                        // 2. Jika result == true (berhasil simpan), Refresh Data!
                        if (result == true) {
                          _refreshTournamentData();
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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

                // TOMBOL DELETE
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
                              "Yakin ingin menghapus turnamen ini? Tindakan ini tidak bisa dibatalkan.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Batal"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // Panggil service untuk delete tournament
                                  final bool success =
                                      await TournamentDeleteService.deleteTournament(
                                        context: context,
                                        tournamentId: data.id,
                                      );

                                  if (!context.mounted) return;

                                  if (success) {
                                    // Opsi 1: Ganti halaman detail langsung dengan Main Page
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TournamentMainPage(),
                                      ),
                                    );

                                    // Opsi 2: Jika Main Page selalu ada di stack, bisa pakai ini:
                                    // Navigator.of(context).pop(true);

                                    // Opsi 3: Jika ingin memastikan Main Page adalah root
                                    // Navigator.of(context).popUntil((route) => route.isFirst);
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
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
              ] else if (widget.role == 'member') ...[
                // --- LOGIC MEMBER (DAFTAR) ---
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
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                                Icon(
                                  Icons.keyboard_arrow_right_rounded,
                                  color: Colors.white,
                                ),
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

              // --- LIST PESERTA ---
              if (data.participants.isEmpty) ...[
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "No participants yet.",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ] else ...[
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: data.participants.map((participant) {
                      final member = participant.member;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              'http://localhost:8000/tournament/proxy-image/?url=${Uri.encodeComponent(member.photo)}',
                            ),
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
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
