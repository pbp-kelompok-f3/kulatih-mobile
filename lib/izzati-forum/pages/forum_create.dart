import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../styles/colors.dart';
import '../styles/text.dart';

class ForumCreatePage extends StatefulWidget {
  const ForumCreatePage({super.key});

  @override
  State<ForumCreatePage> createState() => _ForumCreatePageState();
}

class _ForumCreatePageState extends State<ForumCreatePage> {
  final _formKey = GlobalKey<FormState>();
  String _content = "";

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();

    return Scaffold(
      backgroundColor: AppColor.indigo,
      appBar: AppBar(
        backgroundColor: AppColor.indigo,
        title: Text(
          "Create Post",
          style: heading(28, color: AppColor.yellow),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              TextFormField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Write something...",
                  labelText: "Post Content",
                  labelStyle: body(14, color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) => _content = value,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Content cannot be empty";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.yellow,
                  foregroundColor: AppColor.indigoDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final response = await request.postJson(
                    "https://muhammad-salman42-kulatih.pbp.cs.ui.ac.id/forum/json/create/",
                    jsonEncode({"content": _content}),
                  );

                  if (!mounted) return;

                  if (response["ok"] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Post created successfully!")),
                    );
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Failed: ${response["error"] ?? "Unknown error"}",
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  "Submit",
                  style: body(14, color: AppColor.indigoDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
