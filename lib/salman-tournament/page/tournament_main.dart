import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kulatih_mobile/salman-tournament/widgets/tournament_entry_list.dart';
import 'package:kulatih_mobile/models/user_provider.dart';
import 'package:kulatih_mobile/salman-tournament/page/tournament_create.dart';
import 'package:kulatih_mobile/izzati-forum/styles/colors.dart';
import 'package:kulatih_mobile/izzati-forum/styles/text.dart';

class TournamentMainPage extends StatefulWidget {
  const TournamentMainPage({super.key});

  @override
  State<TournamentMainPage> createState() => _TournamentMainPageState();
}

class _TournamentMainPageState extends State<TournamentMainPage> {
  final TextEditingController searchController = TextEditingController();
  String query = '';
  String currentFilter = 'All Tournaments';

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
    final isCoach = context.watch<UserProvider>().isCoach;

    return Scaffold(
      backgroundColor: AppColor.indigoDark,
      floatingActionButton: AnimatedScale(
        scale: isCoach ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: isCoach ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: isCoach
              ? FloatingActionButton(
                  backgroundColor: AppColor.yellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TournamentCreatePage(),
                      ),
                    );

                    if (result == true) {
                      setState(() {}); // REFRESH UI
                    }
                  },

                  child: const Icon(
                    Icons.add_rounded,
                    size: 28,
                    color: Colors.black,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),

      body: SafeArea(
        child: CustomScrollView(
          slivers: [
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
                          AppColor.indigoDark.withOpacity(0.85),
                          AppColor.indigoDark.withOpacity(0.4),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "FIND YOUR",
                          style: heading(50, color: AppColor.white),
                        ),
                        Text(
                          "PERFECT TOURNAMENT",
                          style: heading(50, color: AppColor.yellow),
                        ),
                        SizedBox(height: 14),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            "Discover, join, and compete in tournaments that match your passion and skills.",
                            textAlign: TextAlign.center,
                            style: body(16, color: AppColor.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        style: body(14, color: Colors.grey.shade500),
                        decoration: InputDecoration(
                          hintText: "Search Tournament...",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColor.yellow.withOpacity(0.7),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: BorderSide(
                              color: AppColor.yellow,
                              width: 2.2,
                            ),
                          ),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        backgroundColor: AppColor.yellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _onSearchChanged(searchController.text),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildFilterButton("All Tournaments"),
                    const SizedBox(width: 10),
                    _buildFilterButton("My Tournaments"),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: TournamentEntryList(key: ValueKey(DateTime.now().toIso8601String()), query: query, filter: currentFilter),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    final isActive = currentFilter == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            currentFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColor.yellow : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.yellow, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: body(14, color: isActive ? Colors.black : AppColor.yellow),
          ),
        ),
      ),
    );
  }
}
