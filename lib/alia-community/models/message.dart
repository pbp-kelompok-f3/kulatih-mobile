class Message {
  final int id;
  final String user;
  final String content;
  final String timestamp;
  final bool isSelf;

  Message({
    required this.id,
    required this.user,
    required this.content,
    required this.timestamp,
    required this.isSelf,
  });

  factory Message.fromJson(
    Map<String, dynamic> json, {
    required String currentUsername,
  }) {
    final user = json['user'] as String? ?? '';
    return Message(
      id: json['id'] as int,
      user: user,
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      isSelf: user == currentUsername,
    );
  }
}
