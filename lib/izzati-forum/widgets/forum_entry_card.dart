import 'package:flutter/material.dart';
import '../models/forum_models.dart';
import '../pages/forum_details.dart';
import '../styles/colors.dart';
import '../styles/text.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../pages/forum_edit.dart';

class ForumEntryCard extends StatefulWidget {
  final Item post;

  const ForumEntryCard({super.key, required this.post});

  @override
  State<ForumEntryCard> createState() => _ForumEntryCardState();
}

class _ForumEntryCardState extends State<ForumEntryCard> {
  Future<void> _vote(String type) async {
    final req = context.read<CookieRequest>();
    final url = type == "up"
        ? "http://localhost:8000/forum/json/${widget.post.id}/upvote/"
        : "http://localhost:8000/forum/json/${widget.post.id}/downvote/";

    final res = await req.post(url, {});

    if (res["ok"] == true) {
      setState(() {
        widget.post.score = res["score"];
        widget.post.userVote = res["user_vote"];
      });
    }
  }

  void _showKebabMenu(BuildContext context) async {
    final selected = await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(200, 100, 20, 0),
      items: [
        const PopupMenuItem(value: "edit", child: Text("Edit")),
        const PopupMenuItem(value: "delete", child: Text("Delete")),
      ],
    );

    if (selected == "edit") {
      final updated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ForumEditPage(post: widget.post),
        ),
      );

      if (updated == true) {
        setState(() {});
      }
    }

    if (selected == "delete") {
      _deletePost();
    }
  }

  Future<void> _deletePost() async {
    final req = context.read<CookieRequest>();
    final url = "http://localhost:8000/forum/json/${widget.post.id}/delete/";

    final res = await req.post(url, {});

    if (res["ok"] == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post deleted")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.post;

    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColor.indigoLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // VOTE COLUMN
          Column(
            children: [
              GestureDetector(
                onTap: () => _vote("up"),
                child: Icon(
                  Icons.arrow_upward,
                  color: p.userVote == 1 ? AppColor.yellow : Colors.white54,
                ),
              ),
              Text("${p.score}", style: body(15)),
              GestureDetector(
                onTap: () => _vote("down"),
                child: Icon(
                  Icons.arrow_downward,
                  color: p.userVote == -1 ? AppColor.yellow : Colors.white54,
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          // POST CONTENT
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ForumDetailsPage(post: p)));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ROW: author + timestamp + kebab
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p.author,
                        style: heading(18, color: AppColor.yellow),
                      ),
                      Text(
                        p.created,   // string human readable
                        style: body(12, color: Colors.white54),
                      ),

                      // kebab menu kalau owner
                      if (p.isOwner == true)
                        GestureDetector(
                          onTap: () => _showKebabMenu(context),
                          child: const Icon(Icons.more_vert, color: Colors.white70),
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    p.content,
                    style: body(14, color: Colors.white.withOpacity(.85)),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
