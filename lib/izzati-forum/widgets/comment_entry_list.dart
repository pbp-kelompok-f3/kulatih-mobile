class CommentEntryList extends StatelessWidget {
  final List<CommentEntry> comments;

  const CommentEntryList({super.key, required this.comments});

  Widget _render(CommentEntry entry, int level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentEntryCard(entry: entry, level: level),

        // render children (reply)
        ...entry.replies.map((reply) => _render(reply, level + 1)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: comments.map((c) => _render(c, 0)).toList(),
    );
  }
}
