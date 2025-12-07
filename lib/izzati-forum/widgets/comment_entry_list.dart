import 'package:flutter/material.dart';
import '../models/comment_models.dart';
import 'comment_entry_card.dart';

class CommentEntryList extends StatelessWidget {
  final List<CommentEntry> comments;

  const CommentEntryList({super.key, required this.comments});

  Widget _buildTree(CommentEntry c, int level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentEntryCard(entry: c, level: level),
        ...c.replies.map((r) => _buildTree(r, level + 1)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: comments.map((c) => _buildTree(c, 0)).toList(),
    );
  }
}
