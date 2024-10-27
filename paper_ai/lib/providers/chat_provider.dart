import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:langchain_anthropic/langchain_anthropic.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:paper_ai/providers/settings_provider.dart';
import 'package:paper_ai/database/db_helper.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_google/langchain_google.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

class ChatState {
  List<Map<String, String>> messages;
  List<Map<String, dynamic>> conversations;
  final int? currentConversationId;
  final bool isNewConversation;

  ChatState({
    required this.messages,
    required this.conversations,
    this.currentConversationId,
    this.isNewConversation = true,
  });

  ChatState copyWith({
    List<Map<String, String>>? messages,
    List<Map<String, dynamic>>? conversations,
    int? currentConversationId,
    bool? isNewConversation,
    bool? hasApiKey,
    String? selectedModel,
    int? messageCount,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      conversations: conversations ?? this.conversations,
      currentConversationId:
          currentConversationId ?? this.currentConversationId,
      isNewConversation: isNewConversation ?? this.isNewConversation,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(ChatState(messages: [], conversations: []));

  final DBHelper _dbHelper = DBHelper();

  BaseChatModel? getClient(SettingsState settings) {
    if (settings.selectedModel == null) {
      return null;
    }

    switch (settings.selectedModel!.provider) {
      case ModelProvider.gemini:
        return ChatGoogleGenerativeAI(
          apiKey: settings.geminiApiKey,
          defaultOptions: ChatGoogleGenerativeAIOptions(
            model: settings.selectedModel!.name,
          ),
        );
      case ModelProvider.openai:
        return ChatOpenAI(
          apiKey: settings.openaiApiKey,
          defaultOptions: ChatOpenAIOptions(
            model: settings.selectedModel!.name,
          ),
        );
      case ModelProvider.claude:
        return ChatAnthropic(
          apiKey: settings.claudeApiKey,
          defaultOptions: ChatAnthropicOptions(
            model: settings.selectedModel!.name,
          ),
        );
    }
  }

  Future<void> loadConversations() async {
    final List<Map<String, dynamic>> conversations =
        List.from(await _dbHelper.getConversations());

    if (mounted) {
      state = state.copyWith(
        conversations: conversations
          ..sort(
            (a, b) => DateTime.parse(b['timestamp']).compareTo(
              DateTime.parse(a['timestamp']),
            ),
          ),
      );
    }
  }

  Future<void> loadMessages(int conversationId) async {
    final messages = await _dbHelper.getMessages(conversationId);
    state = state.copyWith(
      currentConversationId: conversationId,
      messages: messages
          .map((msg) => {
                'sender': msg['sender'] as String,
                'message': msg['message'] as String,
              })
          .toList(),
    );
  }

  Future<void> createNewConversation() async {
    state = state.copyWith(
      currentConversationId: null,
      messages: [],
      isNewConversation: true,
    );
  }

  Future<void> sendMessage(String userMessage, SettingsState settings) async {
    if (userMessage.isEmpty) {
      return;
    }

    if (state.isNewConversation) {
      final conversationId = await _dbHelper.createConversation(
        userMessage.substring(0, min(userMessage.length, 100)),
      );
      final newConversation = {
        'id': conversationId,
        'title': userMessage.substring(0, min(userMessage.length, 100)),
        'timestamp': DateTime.now().toIso8601String()
      };
      state = state.copyWith(
        currentConversationId: conversationId,
        conversations: [newConversation, ...state.conversations],
        isNewConversation: false,
      );
    }

    state = state.copyWith(
      messages: [
        ...state.messages,
        {'sender': 'You', 'message': userMessage},
        {'sender': 'AI', 'message': '...'},
      ],
    );

    await _dbHelper.insertMessage(
        state.currentConversationId!, 'You', userMessage);

    String? answer;
    try {
      final lastMessages = _getLastMessages(settings.messageCount);
      final prompt = PromptValue.string(
        '${lastMessages.map((msg) => '${msg['sender']}: ${msg['message']}').join('\n')}\nYou: $userMessage',
      );
      final result = await getClient(settings)?.invoke(prompt);
      answer = result?.output.content;
    } catch (e, s) {
      debugPrint('Failed to generate response: $e\n$s');
    }

    if (answer == null) {
      state = state.copyWith(
        messages: state.messages
          ..removeLast()
          ..removeLast(),
      );
      return;
    }

    state = state.copyWith(
      messages: [
        ...state.messages..removeLast(),
        {'sender': 'AI', 'message': answer},
      ],
    );

    await _dbHelper.insertMessage(state.currentConversationId!, 'AI', answer);
  }

  List<Map<String, String>> _getLastMessages(int count) {
    return state.messages.length <= count
        ? state.messages
        : state.messages.sublist(state.messages.length - count);
  }

  Future<void> deleteConversation(int conversationId) async {
    await _dbHelper.deleteConversation(conversationId);
    state = state.copyWith(
      conversations: state.conversations
          .where((conversation) => conversation['id'] != conversationId)
          .toList(),
    );
  }
}
