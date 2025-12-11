import 'package:flutter/material.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';
import '../services/community_service.dart';
import '../models/community.dart';
import '../models/message.dart';
import '../widgets/chat_bubble.dart';

class CommunityChatPage extends StatefulWidget {
  final Community community;
  const CommunityChatPage({super.key, required this.community});

  @override
  State<CommunityChatPage> createState() => _CommunityChatPageState();
}

class _CommunityChatPageState extends State<CommunityChatPage> {
  final msgController = TextEditingController();
  List<Message> messages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    final data = await CommunityService.getMessages(widget.community.id);
    setState(() {
      messages = data;
      isLoading = false;
    });
  }

  Future<void> send() async {
    final text = msgController.text.trim();
    if (text.isEmpty) return;

    await CommunityService.sendMessage(
      context,
      widget.community.id,
      text,
    );

    msgController.clear();
    loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.indigoDark,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Text(
              widget.community.name,
              style: TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),

            const SizedBox(height: 6),

            Text(
              "Start chatting with others…",
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: AppColors.gold))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: messages.length,
                      itemBuilder: (_, index) {
                        final m = messages[index];
                        return ChatBubble(message: m);
                      },
                    ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.indigo,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: msgController,
                      style: TextStyle(color: AppColors.textWhite),
                      decoration: InputDecoration(
                        hintText: "Type your message…",
                        hintStyle: TextStyle(color: AppColors.textLight),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: send,
                    child: Text("SEND",
                        style: TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold)),
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
