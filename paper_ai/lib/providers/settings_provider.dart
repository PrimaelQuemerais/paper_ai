import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

enum ModelProvider { gemini, openai, claude, koboldcpp }

class Model {
  final String name;
  final ModelProvider provider;

  Model({required this.name, required this.provider});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Model && other.name == name && other.provider == provider;
  }

  @override
  int get hashCode => name.hashCode ^ provider.hashCode;
}

class SettingsState {
  final String geminiApiKey;
  final String openaiApiKey;
  final String claudeApiKey;
  final int messageCount;
  final String customEndpoint;
  final String customModelName;
  final Model? selectedModel;

  SettingsState({
    required this.geminiApiKey,
    required this.openaiApiKey,
    required this.claudeApiKey,
    required this.messageCount,
    required this.customEndpoint,
    required this.customModelName,
    this.selectedModel,
  });

  SettingsState copyWith({
    String? geminiApiKey,
    String? openaiApiKey,
    String? claudeApiKey,
    int? messageCount,
    String? customEndpoint,
    String? customModelName,
    Model? selectedModel,
  }) {
    return SettingsState(
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      openaiApiKey: openaiApiKey ?? this.openaiApiKey,
      claudeApiKey: claudeApiKey ?? this.claudeApiKey,
      messageCount: messageCount ?? this.messageCount,
      customEndpoint: customEndpoint ?? this.customEndpoint,
      customModelName: customModelName ?? this.customModelName,
      selectedModel: selectedModel ?? this.selectedModel,
    );
  }

  List<Model> get models {
    final models = <Model>[];

    if (geminiApiKey.isNotEmpty) {
      models.addAll([
        Model(name: 'gemini-1.5-flash-latest', provider: ModelProvider.gemini),
        Model(name: 'gemini-1.5-pro-latest', provider: ModelProvider.gemini),
      ]);
    }
    if (openaiApiKey.isNotEmpty) {
      models.addAll([
        Model(name: 'gpt-4o', provider: ModelProvider.openai),
        Model(name: 'gpt-4o-mini', provider: ModelProvider.openai),
        Model(name: 'gpt-4-turbo', provider: ModelProvider.openai),
      ]);
    }
    if (claudeApiKey.isNotEmpty) {
      models.addAll([
        Model(name: 'claude-3-5-sonnet-latest', provider: ModelProvider.claude),
        Model(name: 'claude-3-opus-latest', provider: ModelProvider.claude),
      ]);
    }
    if (customEndpoint.isNotEmpty) {
      models.add(
        Model(
          name: customModelName,
          provider: ModelProvider.koboldcpp,
        ),
      );
    }

    return models;
  }

  bool get hasApiKey {
    return geminiApiKey.isNotEmpty ||
        openaiApiKey.isNotEmpty ||
        claudeApiKey.isNotEmpty;
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
      : super(
          SettingsState(
            geminiApiKey: '',
            openaiApiKey: '',
            claudeApiKey: '',
            messageCount: 5,
            customEndpoint: '',
            customModelName: 'my-model',
          ),
        ) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      geminiApiKey: prefs.getString('geminiApiKey') ?? '',
      openaiApiKey: prefs.getString('openaiApiKey') ?? '',
      claudeApiKey: prefs.getString('claudeApiKey') ?? '',
      messageCount: prefs.getInt('messageCount') ?? 5,
      customEndpoint: prefs.getString('customEndpoint') ?? '',
      customModelName: prefs.getString('customModelName') ?? 'my-model',
    );

    if (state.selectedModel == null) {
      String? selectedModelName = prefs.getString('selectedModel');

      state = selectedModelName != null
          ? state.copyWith(
              selectedModel: state.models.firstWhereOrNull(
              (model) => model.name == selectedModelName,
            ))
          : state.copyWith(selectedModel: state.models.firstOrNull);
    }
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('geminiApiKey', state.geminiApiKey);
    await prefs.setString('openaiApiKey', state.openaiApiKey);
    await prefs.setString('claudeApiKey', state.claudeApiKey);
    await prefs.setInt('messageCount', state.messageCount);
    await prefs.setString('customEndpoint', state.customEndpoint);
    await prefs.setString('customModelName', state.customModelName);

    loadSettings();
  }

  void updateGeminiApiKey(String apiKey) {
    state = state.copyWith(geminiApiKey: apiKey);
  }

  void updateOpenaiApiKey(String apiKey) {
    state = state.copyWith(openaiApiKey: apiKey);
  }

  void updateClaudeApiKey(String apiKey) {
    state = state.copyWith(claudeApiKey: apiKey);
  }

  void updateMessageCount(int count) {
    state = state.copyWith(messageCount: count);
  }

  void updateCustomEndpoint(String endpoint) {
    state = state.copyWith(customEndpoint: endpoint);
  }

  void updateCustomModelName(String name) {
    state = state.copyWith(customModelName: name);
  }

  void updateSelectedModel(Model model) async {
    state = state.copyWith(selectedModel: model);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedModel', state.selectedModel!.name);
  }
}
