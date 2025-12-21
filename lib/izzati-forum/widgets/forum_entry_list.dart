import 'package:flutter/material.dart';
import '../models/forum_models.dart';
import 'forum_entry_card.dart';

class ForumEntryList extends StatelessWidget {
  final List<Item> posts;
  final VoidCallback? onRefresh;

  const ForumEntryList({
    super.key,
    required this.posts,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: posts.length,
      itemBuilder: (_, i) {
        return ForumEntryCard(
          post: posts[i],
          onRefresh: onRefresh,
        );
      },
    );
  }
}