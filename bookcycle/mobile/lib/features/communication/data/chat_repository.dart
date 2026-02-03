import '../domain/chat_models.dart';

abstract class ChatRepository {
  Future<List<ConversationSummary>> fetchConversations(String userId);
  Future<List<ChatMessage>> fetchMessages(String conversationId);
  Future<ChatMessage> sendMessage(String conversationId, String senderId, String content);
}

class MockChatRepository implements ChatRepository {
  final List<ConversationSummary> _conversations = [
    ConversationSummary(
      id: 'c-001',
      listingId: 'l-001',
      buyerId: 'user-001',
      sellerId: 'user-002',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'm-001',
      conversationId: 'c-001',
      senderId: 'user-001',
      content: 'Hi, is the book still available?',
      sentAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    ChatMessage(
      id: 'm-002',
      conversationId: 'c-001',
      senderId: 'user-002',
      content: 'Yes, it is available this week.',
      sentAt: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
  ];

  @override
  Future<List<ConversationSummary>> fetchConversations(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _conversations.where((c) => c.buyerId == userId || c.sellerId == userId).toList();
  }

  @override
  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _messages.where((m) => m.conversationId == conversationId).toList();
  }

  @override
  Future<ChatMessage> sendMessage(String conversationId, String senderId, String content) async {
    final message = ChatMessage(
      id: 'm-${_messages.length + 1}',
      conversationId: conversationId,
      senderId: senderId,
      content: content,
      sentAt: DateTime.now(),
    );
    _messages.add(message);
    return message;
  }
}

class ApiChatRepository implements ChatRepository {
  final String baseUrl;

  ApiChatRepository({required this.baseUrl});

  @override
  Future<List<ConversationSummary>> fetchConversations(String userId) {
    throw UnimplementedError();
  }

  @override
  Future<List<ChatMessage>> fetchMessages(String conversationId) {
    throw UnimplementedError();
  }

  @override
  Future<ChatMessage> sendMessage(String conversationId, String senderId, String content) {
    throw UnimplementedError();
  }
}
