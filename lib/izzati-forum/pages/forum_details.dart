import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/forum_models.dart';
import '../models/comment_models.dart';
import '../styles/colors.dart';
import '../styles/text.dart';
import '../widgets/comment_entry_list.dart';

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

    // panggil endpoint Django untuk ambil komentar
    _futureComments = _fetchComments(request, widget.post.id);
  }

  Future<CommentEntry> _fetchComments(CookieRequest request, int id) async {
    final response =
        await request.get("http://localhost:8000/forum/json/$id/comments/");

    return CommentEntry.fromJson(response);
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      backgroundColor: AppColor.indigo,
      appBar: AppBar(
        backgroundColor: AppColor.indigo,
        elevation: 0,
        title: Text(
          "POST DETAILS",
          style: heading(26, color: AppColor.yellow),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // AUTHOR
            Text(post.author, style: heading(28, color: AppColor.yellow)),
            const SizedBox(height: 6),

            // DATE
            Text(
              post.created.toString().replaceAll("T", " • ").substring(0, 16),
              style: body(12, color: Colors.white70),
            ),

            const SizedBox(height: 20),

            // CONTENT
            Text(post.content, style: body(16, color: AppColor.white)),
            const SizedBox(height: 28),

            // SCORE + COMMENTS
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

            // ==========================
            //        COMMENT LIST
            // ==========================
            FutureBuilder<CommentEntry>(
              future: _futureComments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error loading comments",
                      style: body(14, color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
                  return Center(
                    child: Text(
                      "No comments yet...",
                      style: body(14, color: Colors.white54),
                    ),
                  );
                }

                // 👇 INI BAGIAN YANG MENAMPILKAN NESTED COMMENT TREE
                return CommentEntryList(comments: snapshot.data!.items);
              },
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
