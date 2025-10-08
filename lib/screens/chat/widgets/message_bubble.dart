import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../../../theme/app_theme.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
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
    // Часто используемые эмодзи в начале
    '😀', '😂', '😍', '🥰', '😘', '😊', '😉', '😎', '🤔', '😏',
    '👍', '👎', '❤️', '💔', '🔥', '💯', '🎉', '👏', '🙌', '🤝',
    // Остальные эмодзи
    '🤣', '😅', '😋', '🤗', '🤩', '🤨', '😐', '😑', '🙄', '😥',
    '😯', '😴', '🥱', '😫', '😨', '🥳', '😈', '👿', '💀', '💩',
    '🍆', '🍑', '🌚', '🌝', '❤️‍🔥', '🤡', // клоун в конце
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showTimestamp && timestampText != null)
          _buildTimestamp(),
        _buildMessageContent(context),
      ],
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
          border: Border.all(
            color: AppTheme.mediumGray.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          timestampText!,
          style: GoogleFonts.montserrat(
            color: Colors.grey.shade400,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 300,
              ),
              child: _buildBubble(context),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBubble(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showContextMenu(context),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: message.isMine
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.toxicYellow,
                        AppTheme.darkYellow,
                      ],
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
                : Border.all(
                    color: AppTheme.mediumGray.withValues(alpha: 0.5),
                    width: 1,
                  ),
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
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Текст сообщения
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
              
              // Время отправки
              Row(
                mainAxisAlignment: message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.montserrat(
                      color: message.isMine 
                          ? AppTheme.pureBlack.withValues(alpha: 0.7)
                          : Colors.grey.shade500,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Галочки статуса прочтения
        Positioned(
          bottom: 8,
          right: message.isMine ? null : 8,
          left: message.isMine ? 8 : null,
          child: _buildReadStatus(),
        ),
      ],
    ),
    );
  }

  void _showContextMenu(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size screenSize = MediaQuery.of(context).size;
    
    // Вычисляем доступное место под сообщением
    final double spaceBelow = screenSize.height - position.dy - renderBox.size.height;
    final double menuHeight = 320 + 60; // Высота меню + карусель реакций
    
    // Определяем, где показывать меню
    final bool showBelow = spaceBelow >= menuHeight + 20; // Добавляем небольшой буфер
    final double menuY = showBelow 
        ? position.dy + renderBox.size.height + 12
        : position.dy - menuHeight - 12; // Добавляем отступ сверху
    
    // Дополнительная проверка - если меню выходит за границы экрана, корректируем позицию
    final double finalMenuY = menuY.clamp(16, screenSize.height - menuHeight - 16);
    
    // Вычисляем горизонтальную позицию в зависимости от типа сообщения
    final double menuWidth = 200;
    final double menuX = message.isMine 
        ? position.dx + renderBox.size.width - menuWidth // Слева для исходящих
        : position.dx; // Справа для входящих
    
    // Ограничиваем позицию в пределах экрана с отступами
    final double clampedX = menuX.clamp(16, screenSize.width - menuWidth - 16);
    

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        clampedX,
        finalMenuY,
        clampedX + menuWidth,
        finalMenuY + menuHeight, // Уже включает высоту карусели
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppTheme.darkGray, // Темный фон как у хедера
      elevation: 12,
      shadowColor: AppTheme.toxicYellow.withOpacity(0.3), // Желтая тень
      items: [
        // Карусель реакций
        _buildReactionsCarousel(),
        // Разделитель
        _buildDivider(),
        // Обычные пункты меню
        _buildMenuItem(
          value: 'copy',
          icon: EvaIcons.copyOutline,
          label: 'Копировать',
          color: AppTheme.toxicYellow,
        ),
        if (message.isMine) _buildMenuItem(
          value: 'edit',
          icon: EvaIcons.editOutline,
          label: 'Изменить',
          color: AppTheme.toxicYellow,
        ),
        if (message.isMine) _buildMenuItem(
          value: 'delete',
          icon: EvaIcons.trash2Outline,
          label: 'Удалить у себя',
          color: Colors.red,
        ),
        if (message.isMine) _buildMenuItem(
          value: 'deleteForAll',
          icon: EvaIcons.trash2Outline,
          label: 'Удалить у всех',
          color: Colors.red,
        ),
        _buildMenuItem(
          value: 'pin',
          icon: isPinned ? EvaIcons.pin : EvaIcons.pinOutline, 
          label: isPinned ? 'Открепить' : 'Закрепить',
          color: AppTheme.toxicYellow,
        ),
        _buildMenuItem(
          value: 'reply',
          icon: EvaIcons.messageCircleOutline,
          label: 'Ответить',
          color: AppTheme.toxicYellow,
        ),
        _buildMenuItem(
          value: 'forward',
          icon: EvaIcons.shareOutline,
          label: 'Переслать',
          color: AppTheme.toxicYellow,
        ),
      ],
    ).then((value) {
      if (value != null) {
        switch (value) {
          case 'copy':
            Clipboard.setData(ClipboardData(text: message.text));
            onCopy?.call();
            break;
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
          case 'deleteForAll':
            onDeleteForAll?.call();
            break;
          case 'pin':
            onPin?.call();
            break;
          case 'reply':
            onReply?.call();
            break;
          case 'forward':
            onForward?.call();
            break;
        }
      }
    });
  }

  PopupMenuEntry<String> _buildReactionsCarousel() {
    return PopupMenuItem<String>(
      enabled: false,
      height: 60,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: AppTheme.darkGray,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: reactions.map((emoji) => _buildReactionButton(emoji)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildReactionButton(String emoji) {
    return GestureDetector(
      onTap: () {
        onReaction?.call();
        print('Выбрана реакция: $emoji');
      },
      child: Container(
        width: 44,
        height: 44,
        margin: EdgeInsets.symmetric(horizontal: 1),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(fontSize: 26),
          ),
        ),
      ),
    );
  }

  PopupMenuEntry<String> _buildDivider() {
    return PopupMenuItem<String>(
      enabled: false,
      height: 1,
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppTheme.toxicYellow.withOpacity(0.3),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuEntry<String> _buildMenuItem({
    required String value,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final bool isDestructive = color == Colors.red;
    final Color iconColor = isDestructive ? Colors.red : AppTheme.toxicYellow;

    return PopupMenuItem<String>(
      value: value,
      height: 48,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.mediumGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadStatus() {
    // Имитация статуса прочтения
    final isRead = message.isRead;
    
    if (message.isMine) {
      // Мои сообщения - показываем статус прочтения
      if (!isRead) {
        // Доставлено, но не прочитано - checkmark
        return Icon(
          Icons.check,
          size: 18,
          color: Colors.blue,
        );
      } else {
        // Прочитано - done_all
        return Icon(
          Icons.done_all,
          size: 18,
          color: Colors.blue,
        );
      }
    } else {
      // Входящие сообщения - всегда показываем как прочитанные
      return Icon(
        Icons.done_all,
        size: 18,
        color: Colors.green,
      );
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
