import 'package:flutter/material.dart';
import 'package:kulatih_mobile/salman-tournament/widgets/tournament_entry_list.dart';

class TournamentMainPage extends StatefulWidget {
  const TournamentMainPage({super.key});

  @override
  State<TournamentMainPage> createState() => _TournamentMainPageState();
}

class _TournamentMainPageState extends State<TournamentMainPage> {
  final TextEditingController searchController = TextEditingController();
  String query = '';

  void _onSearchChanged(String value) {
    setState(() => query = value);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      body: SafeArea(
        child: CustomScrollView(
          slivers: [

            // ================= HERO SECTION =================
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Container(
                    height: 260,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/tournament_bg.png"),
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
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ================= SEARCH BAR =================
            SliverToBoxAdapter(
              child: Padding(
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
                          onChanged: _onSearchChanged,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFCD34D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () => _onSearchChanged(searchController.text),
                        child: const Text("Search"),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ================= LIST SECTION =================
            SliverToBoxAdapter(
              child: TournamentEntryList(query: query),
            ),
          ],
        ),
      ),
    );
  }
}
