class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.sentAt,
  });
}

class ConversationSummary {
  final String id;
  final String listingId;
  final String buyerId;
  final String sellerId;
  final DateTime lastMessageAt;

  const ConversationSummary({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    required this.lastMessageAt,
  });
}
