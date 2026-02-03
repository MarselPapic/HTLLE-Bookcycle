import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/chat_repository.dart';
import '../domain/chat_models.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return MockChatRepository();
});

final conversationsProvider = FutureProvider.family<List<ConversationSummary>, String>((ref, userId) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.fetchConversations(userId);
});

final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, AsyncValue<List<ChatMessage>>, String>((ref, conversationId) {
  final repo = ref.watch(chatRepositoryProvider);
  return ChatMessagesNotifier(repo, conversationId);
});

class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final ChatRepository repository;
  final String conversationId;

  ChatMessagesNotifier(this.repository, this.conversationId) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final messages = await repository.fetchMessages(conversationId);
      state = AsyncValue.data(messages);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> send(String senderId, String content) async {
    final current = state.value ?? [];
    final message = await repository.sendMessage(conversationId, senderId, content);
    state = AsyncValue.data([...current, message]);
  }
}
