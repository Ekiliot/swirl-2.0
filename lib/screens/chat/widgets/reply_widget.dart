import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../../../theme/app_theme.dart';
import '../models/chat_message.dart';

/// Виджет для отображения ответа на сообщение
class ReplyWidget extends StatelessWidget {
  final ChatMessage replyToMessage;
  final VoidCallback? onTap;

  const ReplyWidget({
    super.key,
    required this.replyToMessage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.darkGray.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: AppTheme.toxicYellow,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            // Иконка ответа
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.toxicYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                EvaIcons.messageCircleOutline,
                color: AppTheme.toxicYellow,
                size: 16,
              ),
            ),
            
            SizedBox(width: 8),
            
            // Контент ответа
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Имя отправителя
                  Text(
                    replyToMessage.isMine ? 'Вы' : 'Собеседник',
                    style: GoogleFonts.montserrat(
                      color: AppTheme.toxicYellow,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  SizedBox(height: 2),
                  
                  // Текст сообщения
                  Text(
                    _getReplyText(),
                    style: GoogleFonts.montserrat(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getReplyText() {
    // Если это медиа сообщение
    if (replyToMessage.mediaType != null) {
      switch (replyToMessage.mediaType) {
        case 'photo':
          return '📷 Фото';
        case 'video':
          return '🎥 Видео';
        default:
          return '📎 Медиа';
      }
    }
    
    // Если есть текст, обрезаем его
    if (replyToMessage.text.isNotEmpty) {
      if (replyToMessage.text.length > 50) {
        return '${replyToMessage.text.substring(0, 50)}...';
      }
      return replyToMessage.text;
    }
    
    return 'Сообщение';
  }
}
