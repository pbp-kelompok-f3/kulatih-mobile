// lib/alia-community/models/message.dart

class Message {
  final int id;
  final int communityId;
  final int senderId;
  final String senderName;
  final String text;
  final String createdAt;

  Message({
    required this.id,
    required this.communityId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      communityId: json['community_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      senderName: json['sender_name'] ?? "",
      text: json['text'] ?? "",
      createdAt: json['created_at'] ?? "",
    );
  }
}
