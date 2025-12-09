// To parse this JSON data, do
//
//     final forumEntry = forumEntryFromJson(jsonString);

import 'dart:convert';

ForumEntry forumEntryFromJson(String str) => ForumEntry.fromJson(json.decode(str));

String forumEntryToJson(ForumEntry data) => json.encode(data.toJson());

class ForumEntry {
    bool ok;
    int count;
    List<Item> items;

    ForumEntry({
        required this.ok,
        required this.count,
        required this.items,
    });

    factory ForumEntry.fromJson(Map<String, dynamic> json) => ForumEntry(
        ok: json["ok"],
        count: json["count"],
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "ok": ok,
        "count": count,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
    };
}

class Item {
    int id;
    String author;
    int authorId;
    String content;
    DateTime created;
    int score;
    int comments;
    int userVote;

    Item({
        required this.id,
        required this.author,
        required this.authorId,
        required this.content,
        required this.created,
        required this.score,
        required this.comments,
        required this.userVote,
    });

    factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        author: json["author"],
        authorId: json["author_id"],
        content: json["content"],
        created: DateTime.parse(json["created"]),
        score: json["score"],
        comments: json["comments"],
        userVote: json["user_vote"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "author": author,
        "author_id": authorId,
        "content": content,
        "created": created.toIso8601String(),
        "score": score,
        "comments": comments,
        "user_vote": userVote,
    };
}
