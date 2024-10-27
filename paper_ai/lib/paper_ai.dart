import 'package:flutter/material.dart';
import 'package:paper_ai/screens/chat_screen.dart';

class PaperAI extends StatelessWidget {
  const PaperAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paper AI',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodySmall: TextStyle(color: Colors.black, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.black, fontSize: 18),
          bodyLarge: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      home: const ChatScreen(),
    );
  }
}
