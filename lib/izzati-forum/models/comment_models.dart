// To parse this JSON data, do
//
//     final commentEntry = commentEntryFromJson(jsonString);

import 'dart:convert';

CommentEntry commentEntryFromJson(String str) => CommentEntry.fromJson(json.decode(str));

String commentEntryToJson(CommentEntry data) => json.encode(data.toJson());

class CommentEntry {
    bool ok;
    List<Item> items;
    int count;

    CommentEntry({
        required this.ok,
        required this.items,
        required this.count,
    });

    factory CommentEntry.fromJson(Map<String, dynamic> json) => CommentEntry(
        ok: json["ok"],
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
        count: json["count"],
    );

    Map<String, dynamic> toJson() => {
        "ok": ok,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "count": count,
    };
}

class Item {
    int id;
    String author;
    int authorId;
    String content;
    DateTime createdIso;
    String created;
    int? parent;
    List<Item> replies;
    int repliesCount;
    bool isOwner;

    Item({
        required this.id,
        required this.author,
        required this.authorId,
        required this.content,
        required this.createdIso,
        required this.created,
        required this.parent,
        required this.replies,
        required this.repliesCount,
        required this.isOwner,
    });

    factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        author: json["author"],
        authorId: json["author_id"],
        content: json["content"],
        createdIso: DateTime.parse(json["created_iso"]),
        created: json["created"],
        parent: json["parent"],
        replies: List<Item>.from(json["replies"].map((x) => Item.fromJson(x))),
        repliesCount: json["replies_count"],
        isOwner: json["is_owner"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "author": author,
        "author_id": authorId,
        "content": content,
        "created_iso": createdIso.toIso8601String(),
        "created": created,
        "parent": parent,
        "replies": List<dynamic>.from(replies.map((x) => x.toJson())),
        "replies_count": repliesCount,
        "is_owner": isOwner,
    };
}
