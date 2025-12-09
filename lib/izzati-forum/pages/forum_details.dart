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
    final request = context.read<CookieRequest>();
    _futureComments = _fetchComments(request, widget.post.id);
  }

  Future<CommentEntry> _fetchComments(CookieRequest request, int id) async {
    final response =
        await request.get("http://localhost:8000/forum/json/$id/comments/");
    return CommentEntry.fromJson(response);
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

            /// POST HEADER
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.author, style: heading(28, color: AppColor.yellow)),
                      const SizedBox(height: 6),

                      Text(
                        post.created.toString().replaceAll("T", " • ").substring(0, 16),
                        style: body(12, color: Colors.white70),
                      ),

                      const SizedBox(height: 16),

                      Text(post.content, style: body(16, color: AppColor.white)),
                    ],
                  ),
                ),

                /// POST kebab (only owner)
                if (post.canDelete == true || post.canEdit == true)
                  PopupMenuButton(
                    color: AppColor.indigoLight,
                    icon: const Icon(Icons.more_vert, color: Colors.white70),
                    itemBuilder: (context) => [
                      if (post.canEdit == true)
                        const PopupMenuItem(value: "edit", child: Text("Edit Post")),
                      if (post.canDelete == true)
                        const PopupMenuItem(value: "delete", child: Text("Delete Post")),
                    ],
                    onSelected: (value) async {
                      final req = context.read<CookieRequest>();

                      if (value == "delete") {
                        final res = await req.postJson(
                          "http://localhost:8000/forum/json/${post.id}/delete/",
                          jsonEncode({}),
                        );

                        if (res["ok"] == true) {
                          Navigator.pop(context);
                        }
                      }
                    },
                  ),
              ],
            ),

            const SizedBox(height: 28),

            /// SCORE + COMMENT COUNT
            Row(
              children: [
                Icon(Icons.arrow_upward, color: AppColor.yellow, size: 20),
                const SizedBox(width: 4),
                Text("${post.score}", style: body(14, color: Colors.white)),
                const SizedBox(width: 18),
                Icon(Icons.comment, color: AppColor.yellow, size: 20),
                const SizedBox(width: 4),
                Text("${post.comments} comments",
                    style: body(14, color: Colors.white)),
              ],
            ),

            const SizedBox(height: 40),

            /// Add ROOT comment button
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
                      postId: widget.post.id,
                      parentId: null,
                    ),
                  ),
                );

                if (text != null && text.isNotEmpty) {
                  final req = context.read<CookieRequest>();

                  final res = await req.postJson(
                    "http://localhost:8000/forum/json/${widget.post.id}/comments/add/",
                    jsonEncode({"content": text, "parent": null}),
                  );

                  if (res["ok"] == true) {
                    widget.post.comments += 1;
                    setState(() {
                      _futureComments = _fetchComments(req, widget.post.id);
                    });
                  }
                }
              },
              child: const Text("Add Comment"),
            ),

            const SizedBox(height: 20),

            /// COMMENTS LIST
            FutureBuilder<CommentEntry>(
              future: _futureComments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error loading comments",
                        style: body(14, color: Colors.red)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
                  return Center(
                    child: Text("No comments yet...",
                        style: body(14, color: Colors.white54)),
                  );
                }

                final comments = snapshot.data!.items;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    post.comments = snapshot.data!.count;
                  });
                });

                return CommentEntryList(
                  items: comments,
                  onReply: (comment) async {
                    final replyText = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CommentReplyPage(postId: widget.post.id, parentId: comment.id),
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
