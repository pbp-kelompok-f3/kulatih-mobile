import 'package:flutter/material.dart';
import 'package:kulatih_mobile/constants/app_colors.dart';
import '../models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? AppColors.gold : AppColors.textWhite;
    final textColor = AppColors.indigoDark;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Username label (untuk pesan orang lain)
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 4),
              child: Text(
                message.sender,
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Chat bubble
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isMe
                    ? const Radius.circular(20)
                    : const Radius.circular(6),
                bottomRight: isMe
                    ? const Radius.circular(6)
                    : const Radius.circular(20),
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 14),
            ),
          ),

          // Edit & Delete untuk pesan sendiri
          if (isMe)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Text(
                      "edit",
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onDelete,
                    child: Text(
                      "delete",
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Edit & Delete untuk message orang lain)
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 6, top: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    GestureDetector(
                      onTap: onEdit,
                      child: Text(
                        "edit",
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  if (onEdit != null) const SizedBox(width: 12),
                  if (onDelete != null)
                    GestureDetector(
                      onTap: onDelete,
                      child: Text(
                        "delete",
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
