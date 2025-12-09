import 'package:flutter/material.dart';
import '../models/comment_models.dart';
import '../styles/colors.dart';
import '../styles/text.dart';

class CommentEntryCard extends StatelessWidget {
  final ItemComment entry;
  final int level;

  const CommentEntryCard({
    super.key,
    required this.entry,
    this.level = 0,
  });

  void _showMenuComment(BuildContext context) async {
    final selected = await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(200, 100, 20, 0),
      items: [
        const PopupMenuItem(
          value: "edit",
          child: Text("Edit Comment"),
        ),
        const PopupMenuItem(
          value: "delete",
          child: Text("Delete Comment"),
        ),
      ],
    );

    if (selected == "edit") {
      // TODO: buka dialog edit
    } else if (selected == "delete") {
      // TODO: panggil endpoint delete comment
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: level * 20.0, bottom: 16),
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ===================== HEADER =====================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 14, backgroundColor: Colors.white30),
              const SizedBox(width: 10),

              // AUTHOR + TIMESTAMP
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.author,
                        style: heading(14, color: AppColor.yellow)),
                    Text(entry.created,
                        style: body(11, color: Colors.white54)),
                  ],
                ),
              ),

              // ===================== KEBAB MENU =====================
              if (entry.isOwner == true)
                GestureDetector(
                  onTap: () => _showMenuComment(context),
                  child: const Icon(Icons.more_vert,
                      size: 18, color: Colors.white70),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // ===================== COMMENT CONTENT =====================
          Text(entry.content, style: body(14)),

          const SizedBox(height: 4),

          // ===================== REPLY BUTTON =====================
          GestureDetector(
            onTap: () {
              // nanti: popup reply
            },
            child: Text(
              "Reply",
              style: body(12, color: AppColor.yellow)
                  .copyWith(decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }
}
