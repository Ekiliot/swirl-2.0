import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'message_bubble.dart';
import '../models/chat_message.dart';

class VisibleMessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool showTimestamp;
  final String? timestampText;
  final String chatId;
  final Function(String messageId)? onMessageVisible;
  final bool isPinned;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;
  final VoidCallback? onDeleteForAll;
  final VoidCallback? onEdit;
  final VoidCallback? onReply;
  final VoidCallback? onForward;
  final VoidCallback? onPin;
  final VoidCallback? onReaction;

  const VisibleMessageBubble({
    super.key,
    required this.message,
    required this.showTimestamp,
    this.timestampText,
    required this.chatId,
    this.onMessageVisible,
    this.isPinned = false,
    this.onCopy,
    this.onDelete,
    this.onDeleteForAll,
    this.onEdit,
    this.onReply,
    this.onForward,
    this.onPin,
    this.onReaction,
  });

  @override
  State<VisibleMessageBubble> createState() => _VisibleMessageBubbleState();
}

class _VisibleMessageBubbleState extends State<VisibleMessageBubble> {
  bool _hasBeenVisible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('message_${widget.message.text}_${widget.message.timestamp.millisecondsSinceEpoch}'),
      onVisibilityChanged: (VisibilityInfo info) {
        // Сообщение считается видимым, если видимость больше 50%
        if (info.visibleFraction > 0.5 && !_hasBeenVisible) {
          _hasBeenVisible = true;
          
          // Вызываем callback только для сообщений от других пользователей
          if (!widget.message.isMine && !widget.message.isRead) {
            widget.onMessageVisible?.call(widget.message.text);
          }
        }
      },
      child: MessageBubble(
        message: widget.message,
        showTimestamp: widget.showTimestamp,
        timestampText: widget.timestampText,
        isPinned: widget.isPinned,
        onCopy: widget.onCopy,
        onDelete: widget.onDelete,
        onDeleteForAll: widget.onDeleteForAll,
        onEdit: widget.onEdit,
        onReply: widget.onReply,
        onForward: widget.onForward,
        onPin: widget.onPin,
        onReaction: widget.onReaction,
      ),
    );
  }
}
