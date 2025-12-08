import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/forum_models.dart';
import 'forum_entry_card.dart';

class ForumEntryList extends StatefulWidget {
  const ForumEntryList({super.key});

  @override
  State<ForumEntryList> createState() => _ForumEntryListState();
}

class _ForumEntryListState extends State<ForumEntryList> {
  late Future<ForumEntry> _futurePosts;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _futurePosts = fetchForumPosts(request);
  }

  Future<ForumEntry> fetchForumPosts(CookieRequest request) async {
    final response = await request.get(
      "http://127.0.0.1:8000/forum/api/posts/", // sesuaikan endpoint kamu
    );

    // Response dari Django: { ok, count, items: [ ... ] }
    return ForumEntry.fromJson(response);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ForumEntry>(
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
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
          return const Center(
            child: Text("No forum posts found.",
                style: TextStyle(color: Colors.white)),
          );
        }

        final list = snapshot.data!.items;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: list.length,
          itemBuilder: (_, i) {
            return ForumEntryCard(post: list[i]);
          },
        );
      },
    );
  }
}
