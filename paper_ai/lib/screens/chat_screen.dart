import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paper_ai/providers/chat_provider.dart';
import 'package:paper_ai/chat/bubble/chat_bubble.dart';
import 'package:paper_ai/chat/chat_input.dart';
import 'package:paper_ai/conversations/conversation_tile.dart';
import 'package:paper_ai/providers/settings_provider.dart';
import 'package:paper_ai/screens/settings_screen.dart';
import 'package:paper_ai/widgets/paper_button.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).loadConversations();
      ref.read(chatProvider.notifier).createNewConversation();
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final settingsState = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Paper AI', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          DropdownButton<Model?>(
            value: settingsState.selectedModel,
            dropdownColor: Colors.black,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            hint: const Text(
              'Select Model',
              style: TextStyle(color: Colors.white),
            ),
            items: settingsState.models.map((Model model) {
              return DropdownMenuItem<Model>(
                value: model,
                child: Text(
                  model.name,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (Model? newValue) {
              ref
                  .read(settingsProvider.notifier)
                  .updateSelectedModel(newValue!);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      drawer: settingsState.hasApiKey
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                    child: Center(
                      child: Text(
                        'Past Conversations',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('New Conversation'),
                    leading: const Icon(Icons.add_outlined),
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(chatProvider.notifier).createNewConversation();
                    },
                  ),
                  ...chatState.conversations
                      .map((conversation) => ConversationTile(
                            conversation: conversation,
                            onDelete: () {
                              _showDeleteConfirmationDialog(
                                  conversation['id'] as int);
                            },
                            onTap: () {
                              Navigator.pop(context);
                              ref
                                  .read(chatProvider.notifier)
                                  .loadMessages(conversation['id'] as int);
                            },
                          )),
                ],
              ),
            )
          : null,
      body: settingsState.hasApiKey
          ? Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];
                      final isAI = message['sender'] == 'AI';
                      return Align(
                        alignment:
                            isAI ? Alignment.centerLeft : Alignment.centerRight,
                        child: ChatBubble(
                            isAI: isAI, message: message['message']!),
                      );
                    },
                  ),
                ),
                ChatInput(
                  controller: _controller,
                  onSend: () async {
                    String input = _controller.text;
                    _controller.clear();
                    await ref.read(chatProvider.notifier).sendMessage(
                          input,
                          settingsState,
                        );
                    _scrollToBottom();
                  },
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Please add at least one API key to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    PaperButton(
                      text: 'Go to Settings',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showDeleteConfirmationDialog(int conversationId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          title: const Text('Delete Conversation'),
          content:
              const Text('Are you sure you want to delete this conversation?'),
          titlePadding: const EdgeInsets.all(12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          actionsPadding: const EdgeInsets.all(12),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: PaperButton(
                    outlined: true,
                    text: 'Cancel',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PaperButton(
                    text: 'Delete',
                    onPressed: () async {
                      await ref
                          .read(chatProvider.notifier)
                          .deleteConversation(conversationId);

                      if (conversationId ==
                          ref.read(chatProvider).currentConversationId) {
                        ref.read(chatProvider.notifier).createNewConversation();
                      }

                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
