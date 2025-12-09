// To parse this JSON data:
//
//     final forumEntry = forumEntryFromJson(jsonString);

import 'dart:convert';

ForumEntry forumEntryFromJson(String str) =>
    ForumEntry.fromJson(json.decode(str));

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

  // DATE FIELDS
  String created;         // human readable, for display
  DateTime createdIso;    // ISO parseable for sorting if needed

  // VOTING
  int score;
  int comments;
  int userVote;

  // OWNER FLAGS FOR KEBAB MENU
  bool isOwner;
  bool canEdit;
  bool canDelete;

  Item({
    required this.id,
    required this.author,
    required this.authorId,
    required this.content,
    required this.created,
    required this.createdIso,
    required this.score,
    required this.comments,
    required this.userVote,
    required this.isOwner,
    required this.canEdit,
    required this.canDelete,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        author: json["author"],
        authorId: json["author_id"],
        content: json["content"],

        created: json["created"],                       // string only
        createdIso: DateTime.parse(json["created_iso"]), // safe

        score: json["score"],
        comments: json["comments"],
        userVote: json["user_vote"],

        isOwner: json["is_owner"] ?? false,
        canEdit: json["can_edit"] ?? false,
        canDelete: json["can_delete"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "author": author,
        "author_id": authorId,
        "content": content,
        "created": created,
        "created_iso": createdIso.toIso8601String(),
        "score": score,
        "comments": comments,
        "user_vote": userVote,
        "is_owner": isOwner,
        "can_edit": canEdit,
        "can_delete": canDelete,
      };
}
