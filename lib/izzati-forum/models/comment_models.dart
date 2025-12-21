// To parse this JSON data, do
//
//     final commentEntry = commentEntryFromJson(jsonString);

import 'dart:convert';

CommentEntry commentEntryFromJson(String str) => CommentEntry.fromJson(json.decode(str));

String commentEntryToJson(CommentEntry data) => json.encode(data.toJson());

class CommentEntry {
    bool ok;
    int count;
    List<ItemComment> items;

    CommentEntry({
        required this.ok,
        required this.count,
        required this.items,
    });

    factory CommentEntry.fromJson(Map<String, dynamic> json) => CommentEntry(
        ok: json["ok"],
        count: json["count"],
        items: List<ItemComment>.from(json["items"].map((x) => ItemComment.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "ok": ok,
        "count": count,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
    };
}

class ItemComment {
    int id;
    String author;
    int authorId;
    String content;
    int? parent;
    DateTime createdIso;
    String created;
    List<ItemComment> replies;
    int repliesCount;
    bool isOwner;
    String? repliesTo;

    ItemComment({
        required this.id,
        required this.author,
        required this.authorId,
        required this.content,
        required this.parent,
        required this.createdIso,
        required this.created,
        required this.replies,
        required this.repliesCount,
        required this.isOwner,
        this.repliesTo,
    });

    factory ItemComment.fromJson(Map<String, dynamic> json) => ItemComment(
        id: json["id"],
        author: json["author"],
        authorId: json["author_id"],
        content: json["content"],
        parent: json["parent"],
        createdIso: DateTime.parse(json["created_iso"]),
        created: json["created"],
        replies: List<ItemComment>.from(json["replies"].map((x) => ItemComment.fromJson(x))),
        repliesCount: json["replies_count"],
        isOwner: json["is_owner"],
        repliesTo: json["replies_to"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "author": author,
        "author_id": authorId,
        "content": content,
        "parent": parent,
        "created_iso": createdIso.toIso8601String(),
        "created": created,
        "replies": List<dynamic>.from(replies.map((x) => x.toJson())),
        "replies_count": repliesCount,
        "is_owner": isOwner,
        "replies_to": repliesTo,
    };
}
