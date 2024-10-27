import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConversationTile extends StatelessWidget {
  final Map<String, dynamic> conversation;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 8,
      ),
      child: ListTile(
        title: Text(
          conversation['title'] as String,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        contentPadding: const EdgeInsets.only(left: 12.0),
        subtitle: Text(
          DateFormat('yyyy-MM-dd – kk:mm').format(
            DateTime.parse(
              conversation['timestamp'] as String,
            ),
          ),
        ),
        subtitleTextStyle: const TextStyle(
          fontSize: 14.0,
          color: Colors.black,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
