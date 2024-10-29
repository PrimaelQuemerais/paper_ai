import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paper_ai/widgets/paper_button.dart';
import 'package:paper_ai/widgets/number_picker.dart';
import 'package:paper_ai/providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _geminiApiKeyController = TextEditingController();
  final TextEditingController _openaiApiKeyController = TextEditingController();
  final TextEditingController _claudeApiKeyController = TextEditingController();
  int _messageCount = 5;

  bool _isGeminiApiKeyVisible = false;
  bool _isOpenaiApiKeyVisible = false;
  bool _isClaudeApiKeyVisible = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await ref.read(settingsProvider.notifier).loadSettings();
    final settings = ref.read(settingsProvider);
    setState(() {
      _geminiApiKeyController.text = settings.geminiApiKey;
      _openaiApiKeyController.text = settings.openaiApiKey;
      _claudeApiKeyController.text = settings.claudeApiKey;
      _messageCount = settings.messageCount;
    });
  }

  Future<void> _saveSettings() async {
    ref
        .read(settingsProvider.notifier)
        .updateGeminiApiKey(_geminiApiKeyController.text);
    ref
        .read(settingsProvider.notifier)
        .updateOpenaiApiKey(_openaiApiKeyController.text);
    ref
        .read(settingsProvider.notifier)
        .updateClaudeApiKey(_claudeApiKeyController.text);
    ref.read(settingsProvider.notifier).updateMessageCount(_messageCount);
    await ref.read(settingsProvider.notifier).saveSettings();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'API keys',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _geminiApiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'Gemini API Key',
                    ),
                    obscureText: !_isGeminiApiKeyVisible,
                  ),
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: Icon(
                    _isGeminiApiKeyVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isGeminiApiKeyVisible = !_isGeminiApiKeyVisible;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _openaiApiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'OpenAI API Key',
                    ),
                    obscureText: !_isOpenaiApiKeyVisible,
                  ),
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: Icon(
                    _isOpenaiApiKeyVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isOpenaiApiKeyVisible = !_isOpenaiApiKeyVisible;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _claudeApiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'Claude API Key',
                    ),
                    obscureText: !_isClaudeApiKeyVisible,
                  ),
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: Icon(
                    _isClaudeApiKeyVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isClaudeApiKeyVisible = !_isClaudeApiKeyVisible;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              children: [
                Text(
                  'History length',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'This is the number of previous messages sent to the API. A bigger number provides more context but uses more tokens.',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            NumberPicker(
              initialValue: _messageCount,
              onValueChanged: (newValue) {
                _messageCount = newValue;
              },
            ),
            const Spacer(),
            PaperButton(text: 'Save', onPressed: _saveSettings),
          ],
        ),
      ),
    );
  }
}
