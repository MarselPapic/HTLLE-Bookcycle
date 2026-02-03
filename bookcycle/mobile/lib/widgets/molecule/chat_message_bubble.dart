import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../features/communication/domain/chat_models.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final color = isMe ? DesignTokens.primary : DesignTokens.surface;
    final textColor = isMe ? Colors.white : DesignTokens.textPrimary;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: DesignTokens.xs),
        padding: const EdgeInsets.all(DesignTokens.sm),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(DesignTokens.radius),
        ),
        child: Text(message.content, style: DesignTokens.body.copyWith(color: textColor)),
      ),
    );
  }
}
