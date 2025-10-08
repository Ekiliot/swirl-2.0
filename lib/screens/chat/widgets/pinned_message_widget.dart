import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../../../theme/app_theme.dart';
import '../models/chat_message.dart';

class PinnedMessageWidget extends StatelessWidget {
  final ChatMessage pinnedMessage;
  final VoidCallback? onTap;
  final VoidCallback? onUnpin;

  const PinnedMessageWidget({
    super.key,
    required this.pinnedMessage,
    this.onTap,
    this.onUnpin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.darkGray,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.toxicYellow.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.toxicYellow.withOpacity(0.1),
                  blurRadius: 6,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Иконка закрепления
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.toxicYellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    EvaIcons.pin,
                    color: AppTheme.toxicYellow,
                    size: 12,
                  ),
                ),
                
                SizedBox(width: 8),
                
                // Контент закрепленного сообщения
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Заголовок
                      Text(
                        'Закрепленное сообщение',
                        style: GoogleFonts.montserrat(
                          color: AppTheme.toxicYellow,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      SizedBox(height: 2),
                      
                      // Текст сообщения
                      Text(
                        _getTruncatedText(),
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Кнопка открепить
                if (onUnpin != null)
                  GestureDetector(
                    onTap: onUnpin,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        EvaIcons.close,
                        color: Colors.red,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTruncatedText() {
    if (pinnedMessage.mediaType != null) {
      switch (pinnedMessage.mediaType) {
        case 'photo':
          return '📷 Фото';
        case 'video':
          return '🎥 Видео';
        default:
          return '📎 Медиа';
      }
    }
    
    if (pinnedMessage.text.length > 50) {
      return '${pinnedMessage.text.substring(0, 50)}...';
    }
    
    return pinnedMessage.text;
  }

}
