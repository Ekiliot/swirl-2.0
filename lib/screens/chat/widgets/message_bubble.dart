import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showTimestamp;
  final String? timestampText;

  const MessageBubble({
    super.key,
    required this.message,
    this.showTimestamp = false,
    this.timestampText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showTimestamp && timestampText != null)
          _buildTimestamp(),
        _buildMessageContent(),
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

  Widget _buildMessageContent() {
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
              child: _buildBubble(),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBubble() {
    return Stack(
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
