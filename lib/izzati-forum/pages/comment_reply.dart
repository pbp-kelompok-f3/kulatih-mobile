import 'package:flutter/material.dart';
import '../styles/colors.dart';
import '../styles/text.dart';

class CommentReplyPage extends StatefulWidget {
  final int postId;
  final int? parentId;

  const CommentReplyPage({
    super.key,
    required this.postId,
    required this.parentId,
  });

  @override
  State<CommentReplyPage> createState() => _CommentReplyPageState();
}

class _CommentReplyPageState extends State<CommentReplyPage> {
  final TextEditingController ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.indigo,
      appBar: AppBar(
        backgroundColor: AppColor.indigoDark,
        elevation: 0,
        title: Text("Reply", style: heading(20, color: AppColor.yellow)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: ctrl,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Write your reply...",
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.yellow,
                foregroundColor: AppColor.indigoDark,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                Navigator.pop(context, ctrl.text.trim());
              },
              child: const Text("Send Reply"),
            ),
          ],
        ),
      ),
    );
  }
}
