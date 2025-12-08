import 'package:flutter/material.dart';
import '../models/forum_models.dart';
import '../pages/forum_details.dart';
import '../styles/colors.dart';
import '../styles/text.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ForumEntryCard extends StatefulWidget {
  final Item post;

  const ForumEntryCard({super.key, required this.post});

  @override
  State<ForumEntryCard> createState() => _ForumEntryCardState();
}

class _ForumEntryCardState extends State<ForumEntryCard> {
  Future<void> _vote(String type) async {
    final req = context.read<CookieRequest>();

    // GUNAKAN ENDPOINT JSON SESUAI DJANGO MU
    final url = type == "up"
        ? "http://127.0.0.1:8000/forum/json/${widget.post.id}/upvote/"
        : "http://127.0.0.1:8000/forum/json/${widget.post.id}/downvote/";

    final res = await req.post(url, {});

    if (res["ok"] == true) {
      setState(() {
        widget.post.score = res["score"];
        widget.post.userVote = res["user_vote"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.post;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ForumDetailsPage(post: p),
          ),
        );
      },
      child: Container(
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
                    color:
                        p.userVote == 1 ? AppColor.yellow : Colors.white54,
                  ),
                ),
                Text("${p.score}", style: body(15)),
                GestureDetector(
                  onTap: () => _vote("down"),
                  child: Icon(
                    Icons.arrow_downward,
                    color:
                        p.userVote == -1 ? AppColor.yellow : Colors.white54,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // POST CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.author,
                    style: heading(20, color: AppColor.yellow),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.content,
                    style:
                        body(14, color: Colors.white.withOpacity(.85)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
