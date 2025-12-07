import 'package:flutter/material.dart';
import '../models/comment_models.dart';
import '../styles/colors.dart';
import '../styles/text.dart';

class CommentEntryCard extends StatelessWidget {
  final CommentEntry entry;
  final int level;

  const CommentEntryCard({
    super.key,
    required this.entry,
    this.level = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: level * 20.0, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${entry.author} • ${entry.time}",
              style: body(12, color: AppColor.yellow)),
          const SizedBox(height: 6),
          Text(entry.content, style: body(14)),
        ],
      ),
    );
  }
}
