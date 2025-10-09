import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../../../theme/app_theme.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool showTimestamp;
  final String? timestampText;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;
  final VoidCallback? onDeleteForAll;
  final VoidCallback? onEdit;
  final VoidCallback? onReply;
  final VoidCallback? onForward;
  final VoidCallback? onPin;
  final VoidCallback? onReaction;
  final bool isPinned;

  static const List<String> reactions = [
    '😀', '😂', '😍', '🥰', '😘', '😊', '😉', '😎', '🤔', '😏',
    '👍', '👎', '❤️', '💔', '🔥', '💯', '🎉', '👏', '🙌', '🤝',
    '🤣', '😅', '😋', '🤗', '🤩', '🤨', '😐', '😑', '🙄', '😥',
    '😯', '😴', '🥱', '😫', '😨', '🥳', '😈', '👿', '💀', '💩',
    '🍆', '🍑', '🌚', '🌝', '❤️‍🔥', '🤡',
  ];

  const MessageBubble({
    super.key,
    required this.message,
    this.showTimestamp = false,
    this.timestampText,
    this.onCopy,
    this.onDelete,
    this.onDeleteForAll,
    this.onEdit,
    this.onReply,
    this.onForward,
    this.onPin,
    this.onReaction,
    this.isPinned = false,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {

  Widget _buildMessageContent(BuildContext context) {
    final message = widget.message;
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 300),
              child: _buildBubble(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    final message = widget.message;
    return CupertinoContextMenu(
      actions: _buildContextMenuActions(),
      child: Stack(
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75, // Ограничиваем ширину
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: message.isMine
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.toxicYellow, AppTheme.darkYellow],
                    )
                  : null,
              color: message.isMine ? null : AppTheme.darkGray,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(message.isMine ? 24 : 6),
                bottomRight: Radius.circular(message.isMine ? 6 : 24),
              ),
              border: message.isMine
                  ? null
                  : Border.all(color: AppTheme.mediumGray.withValues(alpha: 0.5), width: 1),
              boxShadow: message.isMine
                  ? [
                      BoxShadow(
                        color: AppTheme.toxicYellow.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      )
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Зависит от содержимого
              children: [
                Text(
                  message.text,
                  style: GoogleFonts.montserrat(
                    color: message.isMine ? AppTheme.pureBlack : Colors.white,
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: GoogleFonts.montserrat(
                        color: message.isMine ? AppTheme.pureBlack.withValues(alpha: 0.7) : Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8), // Паддинг между временем и иконкой
                    _buildReadStatus(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.mediumGray.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.mediumGray.withValues(alpha: 0.5), width: 1),
        ),
        child: Text(
          widget.timestampText ?? '',
          style: GoogleFonts.montserrat(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildReadStatus() {
    final isRead = widget.message.isRead;

    if (widget.message.isMine) {
      if (!isRead) {
        return Icon(Icons.check, size: 18, color: Colors.blue);
      } else {
        return Icon(Icons.done_all, size: 18, color: Colors.blue);
      }
    } else {
      return Icon(Icons.done_all, size: 18, color: Colors.green);
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  List<CupertinoContextMenuAction> _buildContextMenuActions() {
    final List<CupertinoContextMenuAction> actions = [];

    // Карусель реакций
    actions.add(CupertinoContextMenuAction(
      child: Container(
        height: 60,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: MessageBubble.reactions.map((emoji) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Закрываем меню
                  widget.onReaction?.call();
                },
                child: Container(
                  width: 44,
                  height: 44,
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  child: Center(
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: 26),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      onPressed: () {
        Navigator.pop(context); // Закрываем меню при нажатии на область карусели
      },
    ));

    // Копировать
    actions.add(CupertinoContextMenuAction(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(EvaIcons.copyOutline, size: 18, color: AppTheme.toxicYellow),
          SizedBox(width: 8),
          Text('Копировать'),
        ],
      ),
      onPressed: () {
        Navigator.pop(context); // Закрываем меню
        Clipboard.setData(ClipboardData(text: widget.message.text));
        widget.onCopy?.call();
      },
    ));

    if (widget.message.isMine) {
      // Изменить
      actions.add(CupertinoContextMenuAction(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(EvaIcons.editOutline, size: 18, color: AppTheme.toxicYellow),
            SizedBox(width: 8),
            Text('Изменить'),
          ],
        ),
        onPressed: () {
          Navigator.pop(context); // Закрываем меню
          widget.onEdit?.call();
        },
      ));

      // Удалить у себя
      actions.add(CupertinoContextMenuAction(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(EvaIcons.trash2Outline, size: 18, color: Colors.red),
            SizedBox(width: 8),
            Text('Удалить у себя'),
          ],
        ),
        isDestructiveAction: true,
        onPressed: () {
          Navigator.pop(context); // Закрываем меню
          widget.onDelete?.call();
        },
      ));

      // Удалить у всех
      actions.add(CupertinoContextMenuAction(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(EvaIcons.trash2Outline, size: 18, color: Colors.red),
            SizedBox(width: 8),
            Text('Удалить у всех'),
          ],
        ),
        isDestructiveAction: true,
        onPressed: () {
          Navigator.pop(context); // Закрываем меню
          widget.onDeleteForAll?.call();
        },
      ));
    }

    // Закрепить/Открепить
    actions.add(CupertinoContextMenuAction(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.isPinned ? EvaIcons.pin : EvaIcons.pinOutline, 
            size: 18, 
            color: AppTheme.toxicYellow
          ),
          SizedBox(width: 8),
          Text(widget.isPinned ? 'Открепить' : 'Закрепить'),
        ],
      ),
      onPressed: () {
        Navigator.pop(context); // Закрываем меню
        widget.onPin?.call();
      },
    ));

    // Ответить
    actions.add(CupertinoContextMenuAction(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(EvaIcons.messageCircleOutline, size: 18, color: AppTheme.toxicYellow),
          SizedBox(width: 8),
          Text('Ответить'),
        ],
      ),
      onPressed: () {
        Navigator.pop(context); // Закрываем меню
        widget.onReply?.call();
      },
    ));

    // Переслать
    actions.add(CupertinoContextMenuAction(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(EvaIcons.shareOutline, size: 18, color: AppTheme.toxicYellow),
          SizedBox(width: 8),
          Text('Переслать'),
        ],
      ),
      onPressed: () {
        Navigator.pop(context); // Закрываем меню
        widget.onForward?.call();
      },
    ));

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showTimestamp && widget.timestampText != null) _buildTimestamp(),
        _buildMessageContent(context),
      ],
    );
  }
}
