import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';

import '../models/forum_models.dart';
import '../models/comment_models.dart';
import '../styles/colors.dart';
import '../styles/text.dart';
import '../widgets/comment_entry_list.dart';
import '../pages/comment_reply.dart';
import '../pages/forum_edit.dart';  // pastikan ini ada

class ForumDetailsPage extends StatefulWidget {
  final Item post;

  const ForumDetailsPage({super.key, required this.post});

  @override
  State<ForumDetailsPage> createState() => _ForumDetailsPageState();
}

class _ForumDetailsPageState extends State<ForumDetailsPage> {
  late Future<CommentEntry> _futureComments;

  @override
  void initState() {
    super.initState();
    final req = context.read<CookieRequest>();
    _futureComments = _fetchComments(req, widget.post.id);
  }

  Future<CommentEntry> _fetchComments(CookieRequest request, int id) async {
    final response =
        await request.get("http://localhost:8000/forum/json/$id/comments/");

    final entry = CommentEntry.fromJson(response);

    // update comment count sekali saja
    widget.post.comments = entry.count;

    return entry;
  }

  Future<void> _submitReply(String text, int parentId) async {
    final req = context.read<CookieRequest>();

    final res = await req.postJson(
      "http://localhost:8000/forum/json/${widget.post.id}/comments/add/",
      jsonEncode({"content": text, "parent": parentId}),
    );

    if (res["ok"] == true) {
      setState(() {
        _futureComments = _fetchComments(req, widget.post.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      backgroundColor: AppColor.indigo,
      appBar: AppBar(
        backgroundColor: AppColor.indigo,
        elevation: 0,
        title: Text("POST DETAILS", style: heading(26, color: AppColor.yellow)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ========== POST HEADER ==========
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.author,
                          style: heading(28, color: AppColor.yellow)),
                      const SizedBox(height: 6),
                      Text(post.created,
                          style: body(12, color: Colors.white70)),
                      const SizedBox(height: 14),
                      Text(post.content,
                          style: body(16, color: Colors.white)),
                    ],
                  ),
                ),

                if (post.canEdit == true || post.canDelete == true)
                  PopupMenuButton(
                    color: AppColor.indigoDark,
                    icon: const Icon(Icons.more_vert, color: Colors.white70),
                    itemBuilder: (context) => [
                      if (post.canEdit == true)
                        PopupMenuItem(
                            value: "edit", child: Text("Edit", style: body(14, color: Colors.white))),
                      if (post.canDelete == true)
                        PopupMenuItem(
                            value: "delete", child: Text("Delete", style: body(14, color: Colors.white))),
                    ],
                    onSelected: (value) async {
                      if (value == "edit") {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ForumEditPage(post: post),
                          ),
                        );
                        if (updated == true) setState(() {});
                      }

                      if (value == "delete") {
                        final req = context.read<CookieRequest>();
                        final res = await req.postJson(
                          "http://localhost:8000/forum/json/${post.id}/delete/",
                          "{}",
                        );
                        if (res["ok"] == true) Navigator.pop(context);
                      }
                    },
                  ),
              ],
            ),

            const SizedBox(height: 28),

            /// ========== SCORE + COMMENT COUNT ==========
            Row(
              children: [
                Icon(Icons.arrow_upward, color: AppColor.yellow, size: 20),
                const SizedBox(width: 4),
                Text("${post.score}", style: body(14)),
                const SizedBox(width: 18),
                Icon(Icons.comment, color: AppColor.yellow, size: 20),
                const SizedBox(width: 4),
                Text("${post.comments} comments",
                    style: body(14, color: Colors.white)),
              ],
            ),

            const SizedBox(height: 40),

            /// ========== ADD COMMENT ==========
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.yellow,
                foregroundColor: AppColor.indigoDark,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () async {
                final text = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CommentReplyPage(
                      postId: post.id,
                      parentId: null,
                    ),
                  ),
                );

                if (text != null && text.isNotEmpty) {
                  final req = context.read<CookieRequest>();
                  final res = await req.postJson(
                    "http://localhost:8000/forum/json/${post.id}/comments/add/",
                    jsonEncode({"content": text, "parent": null}),
                  );

                  if (res["ok"] == true) {
                    setState(() {
                      _futureComments = _fetchComments(req, post.id);
                    });
                  }
                }
              },
              child: const Text("Add Comment"),
            ),

            const SizedBox(height: 20),

            /// ========== COMMENTS LIST ==========
            FutureBuilder<CommentEntry>(
              future: _futureComments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
                  return Center(
                    child: Text("No comments yet...",
                        style: body(14, color: Colors.white54)),
                  );
                }

                return CommentEntryList(
                  items: snapshot.data!.items,
                  onReply: (comment) async {
                    final replyText = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommentReplyPage(
                          postId: post.id,
                          parentId: comment.id,
                        ),
                      ),
                    );

                    if (replyText != null && replyText.isNotEmpty) {
                      await _submitReply(replyText, comment.id);
                    }
                  },
                );
              },
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
