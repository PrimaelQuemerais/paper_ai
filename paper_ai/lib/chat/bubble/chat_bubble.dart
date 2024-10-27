import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:paper_ai/chat/animated_dots.dart';
import 'package:paper_ai/chat/bubble/bubble_shape.dart';

class ChatBubble extends StatelessWidget {
  final bool isAI;
  final String message;

  const ChatBubble({super.key, required this.isAI, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8.0),
      padding: EdgeInsets.only(
        top: 2.0,
        bottom: 2.0,
        right: isAI ? 2.0 : 12.0,
        left: isAI ? 12.0 : 2.0,
      ),
      decoration: ShapeDecoration(
        color: isAI ? Colors.white : Colors.black,
        shape: BubbleShape(isAI: isAI),
      ),
      child: isAI
          ? (message == "..."
              ? const AnimatedDots()
              : MarkdownBody(
                  data: message,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ))
          : SelectableText(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
    );
  }
}
