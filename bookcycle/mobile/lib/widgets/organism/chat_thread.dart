import 'package:flutter/material.dart';
import '../../features/communication/domain/chat_models.dart';
import '../../theme/design_tokens.dart';
import '../molecule/chat_message_bubble.dart';
import '../atom/primary_button.dart';

class ChatThread extends StatefulWidget {
  final List<ChatMessage> messages;
  final String currentUserId;
  final void Function(String message) onSend;

  const ChatThread({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.onSend,
  });

  @override
  State<ChatThread> createState() => _ChatThreadState();
}

class _ChatThreadState extends State<ChatThread> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(DesignTokens.md),
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              final message = widget.messages[index];
              return ChatMessageBubble(
                message: message,
                isMe: message.senderId == widget.currentUserId,
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(DesignTokens.md),
          decoration: const BoxDecoration(color: DesignTokens.surface),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Write a message',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.sm),
              SizedBox(
                width: 110,
                child: PrimaryButton(
                  label: 'Send',
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;
                    widget.onSend(text);
                    _controller.clear();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

