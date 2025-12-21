import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../styles/colors.dart';
import '../styles/text.dart';
import '../widgets/forum_entry_list.dart';
import '../models/forum_models.dart';
import 'forum_create.dart';

class ForumMainPage extends StatefulWidget {
  const ForumMainPage({super.key});

  @override
  State<ForumMainPage> createState() => ForumMainPageState();
}

class ForumMainPageState extends State<ForumMainPage> {
  late Future<ForumEntry> _futurePosts;
  bool _loaded = false;
  TextEditingController _search = TextEditingController();
  bool _mineOnly = false;

  void refreshPosts() {
    final req = context.read<CookieRequest>();
    setState(() {
      _futurePosts = fetchPosts(req);
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // fetch forum list ONLY after CookieRequest is ready (after login)
    if (!_loaded) {
      final req = context.read<CookieRequest>();
      _futurePosts = fetchPosts(req);
      _loaded = true;
    }
  }

  Future<ForumEntry> fetchPosts(CookieRequest request,
      {String query = "", bool mine = false}) async {

    final url =
        "http://localhost:8000/forum/json/?q=$query&mine=${mine ? 1 : 0}";

    final response = await request.get(url);
    return ForumEntry.fromJson(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.indigo,

      appBar: AppBar(
        backgroundColor: AppColor.indigo,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "FORUM",
          style: heading(34, color: AppColor.yellow),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.yellow,
        foregroundColor: AppColor.indigoDark,
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ForumCreatePage(),
            ),
          );

          // Refresh list AFTER creating a new post
          if (created == true) {
            setState(() {
              final req = context.read<CookieRequest>();
              _futurePosts = fetchPosts(req);
            });
          }
        },
        child: const Icon(Icons.add, size: 28),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Subheading small (SHARE YOUR THOUGHTS)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Text(
                "SHARE YOUR THOUGHTS",
                style: heading(23, color: AppColor.white),
              ),
            ),

            // ===================== FILTER BAR =====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  // SEARCH BAR
                  Expanded(
                    child: TextField(
                      controller: _search,
                      style: body(14, color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColor.indigoLight,
                        hintText: "Search posts or author...",
                        hintStyle: body(14, color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // MY POSTS CHECKBOX
                  Row(
                    children: [
                      Checkbox(
                        value: _mineOnly,
                        onChanged: (v) {
                          setState(() => _mineOnly = v ?? false);
                        },
                      ),
                      Text("My posts", style: body(14, color: Colors.white)),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // APPLY BUTTON
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.yellow,
                      foregroundColor: AppColor.indigoDark,
                    ),
                    onPressed: () {
                      final req = context.read<CookieRequest>();
                      setState(() {
                        _futurePosts = fetchPosts(
                          req,
                          query: _search.text.trim(),
                          mine: _mineOnly,
                        );
                      });
                    },
                    child: Text(
                      "APPLY",
                      style: body(14, color: AppColor.indigoDark).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // CLEAR BUTTON
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      _search.clear();
                      _mineOnly = false;

                      final req = context.read<CookieRequest>();
                      setState(() {
                        _futurePosts = fetchPosts(req);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    child: Text(
                        "CLEAR",
                        style: body(14, color: Colors.white).copyWith(
                          fontWeight: FontWeight.w700,       // bold seperti APPLY
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            Expanded(
              child: FutureBuilder<ForumEntry>(
                future: _futurePosts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: body(14, color: Colors.redAccent),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
                    return Center(
                      child: Text(
                        "No posts yet.",
                        style: body(16, color: Colors.white70),
                      ),
                    );
                  }
                  return ForumEntryList(
                    posts: snapshot.data!.items,
                    onRefresh: () {
                      setState(() {
                        final req = context.read<CookieRequest>();
                        _futurePosts = fetchPosts(req);
                      });
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
