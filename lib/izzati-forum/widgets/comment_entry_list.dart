import 'package:flutter/material.dart';
import '../models/comment_models.dart';
import 'comment_item.dart';

class CommentEntryList extends StatelessWidget {
  final List<ItemComment> items;
  final Function(ItemComment) onReply;

  const CommentEntryList({
    super.key,
    required this.items,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((c) {
        return CommentItem(
          comment: c,
          level: 0,
          onReply: onReply,
        );
      }).toList(),
    );
  }
}
