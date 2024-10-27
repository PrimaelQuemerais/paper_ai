import 'package:flutter/material.dart';
import 'package:paper_ai/widgets/paper_button.dart';

class ChatInput extends StatelessWidget {
  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter your message',
                hintStyle: TextStyle(color: Colors.black54),
              ),
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 160,
            child: PaperButton(
              text: 'Send',
              onPressed: onSend,
              outlined: true,
            ),
          ),
        ],
      ),
    );
  }
}
