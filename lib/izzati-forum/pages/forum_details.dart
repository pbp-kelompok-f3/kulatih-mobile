import 'package:flutter/material.dart';
import '../models/forum_models.dart';
import '../styles/colors.dart';
import '../styles/text.dart';

class ForumDetailsPage extends StatelessWidget {
  final Item post;

  const ForumDetailsPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
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
            Text(
              post.author,
              style: heading(28, color: AppColor.yellow),
            ),

            const SizedBox(height: 6),

            // DATE (converted ISO → readable)
            Text(
              post.created.toString().replaceAll("T", " • ").substring(0, 16),
              style: body(12, color: Colors.white70),
            ),

            const SizedBox(height: 20),

            // CONTENT
            Text(
              post.content,
              style: body(16, color: AppColor.white),
            ),

            const SizedBox(height: 28),

            // SCORE + COMMENTS
            Row(
              children: [
                Icon(Icons.arrow_upward, color: AppColor.yellow, size: 20),
                const SizedBox(width: 4),
                Text(
                  "${post.score}",
                  style: body(14, color: Colors.white),
                ),

                const SizedBox(width: 18),

                Icon(Icons.comment, color: AppColor.yellow, size: 20),
                const SizedBox(width: 4),
                Text(
                  "${post.comments} comments",
                  style: body(14, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // PLACEHOLDER COMMENT SECTION
            Center(
              child: Text(
                "Comments will be added here soon...",
                style: body(14, color: Colors.white54),
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
