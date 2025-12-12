// lib/alia-community/pages/community_chat_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'package:kulatih_mobile/constants/app_colors.dart';
import 'package:kulatih_mobile/models/user_provider.dart';

import '../models/community.dart';
import '../models/message.dart';
import '../services/community_service.dart';
import '../widgets/chat_bubble.dart';

class CommunityChatPage extends StatefulWidget {
  final CommunityEntry community;

  const CommunityChatPage({
    super.key,
    required this.community,
  });

  @override
  State<CommunityChatPage> createState() => _CommunityChatPageState();
}

class _CommunityChatPageState extends State<CommunityChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> _messages = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final request = context.read<CookieRequest>();

    final msgs = await CommunityService.getMessages(
      request,
      widget.community.id,
    );

    setState(() {
      _messages = msgs;
      _loading = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final request = context.read<CookieRequest>();

    setState(() => _sending = true);

    final newMsg = await CommunityService.sendMessage(
      request,
      widget.community.id,
      text,
    );

    setState(() => _sending = false);

    if (newMsg != null) {
      _messageController.clear();

      // langsung tambahkan tanpa reload
      setState(() {
        _messages.add(newMsg);
      });

      _scrollToBottom();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send message")),
      );
    }

  }

  Future<void> _deleteMessage(Message msg) async {
    final request = context.read<CookieRequest>();

    final ok = await CommunityService.deleteMessage(
      request,
      widget.community.id,
      msg.id,
    );

    if (ok) {
      setState(() => _messages.removeWhere((m) => m.id == msg.id));
    }
  }

  Future<void> _editMessage(Message msg) async {
    final controller = TextEditingController(text: msg.text);

    final updated = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit message"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "New text"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (updated == null || updated.isEmpty) return;

    final request = context.read<CookieRequest>();

    final ok = await CommunityService.editMessage(
      request,
      widget.community.id,
      msg.id,
      updated,
    );

    if (ok) {
      setState(() {
        msg.text = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.indigoDark,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Community info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.community.name,
                          style: TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          "Start chatting with others to get more information",
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // MESSAGES
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.indigo,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: _loading
                    ? Center(
                        child:
                            CircularProgressIndicator(color: AppColors.gold),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMe = msg.sender == user.username;

                          return ChatBubble(
                            message: msg,
                            isMe: isMe,
                            onDelete: isMe ? () => _deleteMessage(msg) : null,
                            onEdit: isMe ? () => _editMessage(msg) : null,
                          );
                        },
                      ),
              ),
            ),

            // SEND MESSAGE
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.indigo,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(color: AppColors.textWhite),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type your message",
                          hintStyle: TextStyle(color: AppColors.textLight),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    _sending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.gold,
                            ),
                          )
                        : GestureDetector(
                            onTap: _sendMessage,
                            child: Text(
                              "SEND",
                              style: TextStyle(
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}