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

  Future<ForumEntry> fetchPosts(CookieRequest request) async {
    final response = await request.get(
      "http://localhost:8000/forum/json/",
    );
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
                style: heading(18, color: AppColor.white),
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
