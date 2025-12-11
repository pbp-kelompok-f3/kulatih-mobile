// To parse this JSON data, do
//
//     final communityMessage = communityMessageFromJson(jsonString);

import 'dart:convert';

CommunityMessage communityMessageFromJson(String str) => CommunityMessage.fromJson(json.decode(str));

String communityMessageToJson(CommunityMessage data) => json.encode(data.toJson());

class CommunityMessage {
    int count;
    List<Message> messages;

    CommunityMessage({
        required this.count,
        required this.messages,
    });

    factory CommunityMessage.fromJson(Map<String, dynamic> json) => CommunityMessage(
        count: json["count"],
        messages: List<Message>.from(json["messages"].map((x) => Message.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "count": count,
        "messages": List<dynamic>.from(messages.map((x) => x.toJson())),
    };
}

class Message {
    int id;
    String text;
    String sender;
    int senderId;
    DateTime createdAt;

    Message({
        required this.id,
        required this.text,
        required this.sender,
        required this.senderId,
        required this.createdAt,
    });

    factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json["id"],
        text: json["text"],
        sender: json["sender"],
        senderId: json["sender_id"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "text": text,
        "sender": sender,
        "sender_id": senderId,
        "created_at": createdAt.toIso8601String(),
    };
}
