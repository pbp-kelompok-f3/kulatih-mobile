import 'package:flutter/material.dart';
import '../models/comment_models.dart';
import '../styles/colors.dart';
import '../styles/text.dart';

class CommentItem extends StatelessWidget {
  final ItemComment comment;
  final int level;
  final Function(ItemComment) onReply;

  const CommentItem({
    super.key,
    required this.comment,
    required this.level,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: level * 22, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 14, backgroundColor: Colors.white24),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment.author,
                        style: heading(14, color: AppColor.yellow)),
                    Text(comment.created,
                        style: body(11, color: Colors.white54)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            comment.content,
            style: body(14, color: Colors.white.withOpacity(.9)),
          ),

          const SizedBox(height: 4),

          GestureDetector(
            onTap: () => onReply(comment),
            child: Text(
              "Reply",
              style: body(12, color: AppColor.yellow)
                  .copyWith(decoration: TextDecoration.underline),
            ),
          ),

          const SizedBox(height: 8),

          // REPLIES (tidak pernah punya kebab)
          ...comment.replies.map(
            (child) => CommentItem(
              comment: child,
              level: level + 1,
              onReply: onReply,
            ),
          )
        ],
      ),
    );
  }
}
