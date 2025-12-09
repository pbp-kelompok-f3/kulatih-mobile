import 'package:flutter/material.dart';
import 'package:kulatih_mobile/salman-tournament/models/tournament_model.dart';
import 'package:kulatih_mobile/salman-tournament/widgets/tournament_entry_card.dart';
import 'package:kulatih_mobile/salman-tournament/page/tournament_details.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class TournamentMainPage extends StatefulWidget {
  const TournamentMainPage({super.key});

  @override
  State<TournamentMainPage> createState() => _TournamentMainPageState();
}

class _TournamentMainPageState extends State<TournamentMainPage> {
  bool isLoading = true;
  List<Tournament> allTournaments = [];
  List<Tournament> filteredTournaments = [];

  final TextEditingController searchController = TextEditingController();

  Future<void> fetchTournaments(CookieRequest request) async {
    setState(() => isLoading = true);

    final response = await request.get(
      "http://localhost:8000/tournament/json/tournaments/",
    );

    List<Tournament> list = [];
    for (var entry in response) {
      final tEntry = TournamentEntry.fromJson(entry);
      list.addAll(tEntry.tournaments);
    }

    setState(() {
      allTournaments = list;
      filteredTournaments = list;
      isLoading = false;
    });
  }

  void searchTournament(String query) {
    setState(() {
      filteredTournaments = allTournaments.where((t) {
        final name = t.nama.toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
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
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ========================= HERO SECTION =========================
            Stack(
              children: [
                Container(
                  height: 260,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/tournament_bg.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.85),
                        Colors.black.withOpacity(0.4),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),

                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "FIND YOUR",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      Text(
                        "PERFECT TOURNAMENT",
                        style: TextStyle(
                          color: Color(0xFFFCD34D),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                      SizedBox(height: 14),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "Discover, join, and compete in tournaments that match your passion and skills.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            // ========================= SEARCH BAR =========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: "Search Tournament...",
                          border: InputBorder.none,
                        ),
                        onChanged: searchTournament,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFCD34D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => searchTournament(searchController.text),
                      child: const Text("Search"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ========================= LIST / GRID =========================
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: CircularProgressIndicator(
                    color: Colors.orangeAccent,
                  ),
                ),
              )
            else if (filteredTournaments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Text(
                    "No tournaments found.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 40),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.73,
                  ),
                  itemCount: filteredTournaments.length,
                  itemBuilder: (context, index) {
                    final tournament = filteredTournaments[index];

                    return TournamentEntryCard(
                      tournament: tournament,
                      index: index,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TournamentDetailPage(tournament: tournament),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
