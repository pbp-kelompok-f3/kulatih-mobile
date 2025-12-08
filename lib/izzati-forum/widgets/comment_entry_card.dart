class CommentEntryCard extends StatelessWidget {
  final CommentEntry entry;
  final int level;

  const CommentEntryCard({
    super.key,
    required this.entry,
    this.level = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: level * 20.0, bottom: 16),
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // HEADER
          Row(
            children: [
              CircleAvatar(radius: 14, backgroundColor: Colors.white30),
              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.author, style: heading(14, color: AppColor.yellow)),
                  Text(entry.time, style: body(11, color: Colors.white54)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // COMMENT CONTENT
          Text(entry.content, style: body(14)),

          const SizedBox(height: 4),

          // REPLY BUTTON
          GestureDetector(
            onTap: () {
              // nanti masuk popup reply
            },
            child: Text(
              "Reply",
              style: body(12, color: AppColor.yellow)
                  .copyWith(decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }
}
