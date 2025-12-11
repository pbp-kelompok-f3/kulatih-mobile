// lib/alia-community/widgets/chat_bubble.dart
import 'package:flutter/material.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';
import '../models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isSelf = message.isSelf;

    return Align(
      alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelf ? AppColors.gold : AppColors.indigo,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isSelf ? 16 : 4),
            bottomRight: Radius.circular(isSelf ? 4 : 16),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isSelf ? AppColors.indigoDark : AppColors.textWhite,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
