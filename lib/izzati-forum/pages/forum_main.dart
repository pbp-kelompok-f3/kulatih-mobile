import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../styles/colors.dart';
import '../styles/text.dart';
import '../widgets/forum_entry_list.dart';
import 'forum_details.dart'; // kalau mau push ke detail nanti
import '../models/forum_models.dart';

class ForumMainPage extends StatefulWidget {
  const ForumMainPage({super.key});

  @override
  State<ForumMainPage> createState() => _ForumMainPageState();
}

class _ForumMainPageState extends State<ForumMainPage> {
  late Future<ForumEntry> _futurePosts;

  @override
  void initState() {
    super.initState();
    final req = context.read<CookieRequest>();
    _futurePosts = fetchPosts(req);
  }

  Future<ForumEntry> fetchPosts(CookieRequest request) async {
    final response = await request.get(
      "http://127.0.0.1:8000/forum/api/posts/",
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
        onPressed: () {
          // TODO: buka modal create post
        },
        child: const Icon(Icons.add, size: 28),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Subheading kecil (mirip di web: SHARE YOUR THOUGHTS)
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
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
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

                  return ForumEntryList(posts: snapshot.data!.items);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
