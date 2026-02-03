import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/communication/presentation/chat_providers.dart';
import '../shared/providers.dart';
import '../widgets/widgets.dart';

/// User Story: US-004 Chat
class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Please log in to view chats.'));
        }
        final conversationId = 'c-001';
        final messagesAsync = ref.watch(chatMessagesProvider(conversationId));
        return messagesAsync.when(
          data: (messages) => ChatThread(
            messages: messages,
            currentUserId: user.id,
            onSend: (text) {
              ref.read(chatMessagesProvider(conversationId).notifier).send(user.id, text);
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}
