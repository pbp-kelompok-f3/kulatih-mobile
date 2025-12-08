import 'package:flutter/material.dart';
import 'package:kulatih_mobile/izzati-forum/models/comment_models.dart';
import 'comment_entry_card.dart';

class CommentEntryList extends StatelessWidget {
  final List<ItemComment> comments;

  const CommentEntryList({super.key, required this.comments});

  Widget _render(ItemComment entry, int level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentEntryCard(entry: entry, level: level),

        // render children (reply)
        ...entry.replies.map((reply) => _render(reply, level + 1)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: comments.map((c) => _render(c, 0)).toList(),
    );
  }
}
