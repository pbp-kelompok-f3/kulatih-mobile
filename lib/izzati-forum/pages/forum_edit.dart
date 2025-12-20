import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../styles/colors.dart';
import '../styles/text.dart';
import '../models/forum_models.dart';
import 'dart:convert';

class ForumEditPage extends StatefulWidget {
  final Item post;

  const ForumEditPage({super.key, required this.post});

  @override
  State<ForumEditPage> createState() => _ForumEditPageState();
}

class _ForumEditPageState extends State<ForumEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content);
  }

  Future<void> _saveEdit() async {
    final req = context.read<CookieRequest>();

    final url =
        "http://localhost:8000/forum/json/${widget.post.id}/edit/";

    final response = await req.postJson(
    url,
    jsonEncode({"content": _contentController.text}),
    );

    if (!mounted) return;

    if (response["ok"] == true) {
      widget.post.content = response["content"];
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post updated successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: ${response["error"]}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.indigo,
      appBar: AppBar(
        backgroundColor: AppColor.indigoDark,
        title: Text("Edit Post", style: heading(24, color: AppColor.yellow)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                style: body(14, color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Edit Content",
                  labelStyle: body(14, color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? "Content cannot be empty"
                        : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.yellow,
                  foregroundColor: AppColor.indigoDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveEdit();
                  }
                },
                child: Text("Save Changes",
                    style: heading(16, color: AppColor.indigoDark)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
