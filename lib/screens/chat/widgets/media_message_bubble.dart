import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../../../theme/app_theme.dart';
import '../models/chat_message.dart';

class MediaMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showTimestamp;
  final String? timestampText;
  final bool isPinned;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;
  final VoidCallback? onDeleteForAll;
  final VoidCallback? onEdit;
  final VoidCallback? onReply;
  final VoidCallback? onForward;
  final VoidCallback? onPin;
  final VoidCallback? onReaction;

  static const List<String> reactions = [
    // Часто используемые эмодзи в начале
    '😀', '😂', '😍', '🥰', '😘', '😊', '😉', '😎', '🤔', '😏',
    '👍', '👎', '❤️', '💔', '🔥', '💯', '🎉', '👏', '🙌', '🤝',
    // Остальные эмодзи
    '🤣', '😅', '😋', '🤗', '🤩', '🤨', '😐', '😑', '🙄', '😥',
    '😯', '😴', '🥱', '😫', '😨', '🥳', '😈', '👿', '💀', '💩',
    '🍆', '🍑', '🌚', '🌝', '❤️‍🔥', '🤡', // клоун в конце
  ];

  const MediaMessageBubble({
    super.key,
    required this.message,
    required this.showTimestamp,
    this.timestampText,
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
  Widget build(BuildContext context) {
    final bool isPhoto = message.mediaType == 'photo';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: CupertinoContextMenu(
              actions: _buildContextMenuActions(context),
              child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75, // Ограничиваем ширину
                maxHeight: 200,
              ),
              child: Stack(
                children: [
                  // Основной контейнер медиа
                  Container(
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                            bottomLeft: Radius.circular(message.isMine ? 24 : 6),
                            bottomRight: Radius.circular(message.isMine ? 6 : 24),
                          ),
                          child: _buildMediaContent(),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
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
                        ),
                      ],
                    ),
                  ),
                  
                  // Индикатор типа медиа
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isPhoto ? EvaIcons.imageOutline : EvaIcons.videoOutline,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  
                  // Индикатор загрузки
                  if (message.isUploading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                            bottomLeft: Radius.circular(message.isMine ? 24 : 6),
                            bottomRight: Radius.circular(message.isMine ? 6 : 24),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: AppTheme.toxicYellow,
                                strokeWidth: 2,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Загрузка...',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                  // Индикатор ошибки
                  if (message.hasError)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                            bottomLeft: Radius.circular(message.isMine ? 24 : 6),
                            bottomRight: Radius.circular(message.isMine ? 6 : 24),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                EvaIcons.alertCircleOutline,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Ошибка загрузки',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    final bool isPhoto = message.mediaType == 'photo';

    if (isPhoto) {
      return _buildPhotoContent();
    } else if (message.mediaType == 'video') {
      return _buildVideoContent();
    } else {
      return _buildUnknownContent();
    }
  }

  Widget _buildPhotoContent() {
    return Container(
      width: double.infinity,
      height: 200,
      child: _buildImageWithThumbnail(),
    );
  }

  Widget _buildImageWithThumbnail() {
    // Если есть миниатюра, показываем её сразу
    if (message.thumbnailData != null) {
      return Stack(
        children: [
          // Миниатюра как фон
          Image.memory(
            message.thumbnailData!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
          ),
          // Полноразмерное изображение поверх миниатюры
          if (message.mediaUrl != null)
            Image.network(
              message.mediaUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.toxicYellow,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorContent();
              },
            ),
        ],
      );
    }
    
    // Если нет миниатюры, показываем обычную загрузку
    if (message.mediaUrl != null) {
      return Image.network(
        message.mediaUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.toxicYellow,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorContent();
        },
      );
    }
    
    return _buildPlaceholderContent();
  }

  Widget _buildVideoContent() {
    return Container(
      width: double.infinity,
      height: 200,
      child: Stack(
        children: [
          // Превью видео или плейсхолдер
          Container(
            width: double.infinity,
            height: double.infinity,
            child: message.mediaUrl != null
                ? Image.network(
                    message.mediaUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.toxicYellow,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildErrorContent();
                    },
                  )
                : _buildPlaceholderContent(),
          ),
          
          // Кнопка воспроизведения
          Center(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                EvaIcons.playCircleOutline,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          
          // Длительность видео (если есть)
          if (message.mediaDuration != null)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(message.mediaDuration!),
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderContent() {
    return Container(
      width: double.infinity,
      height: 200,
      color: AppTheme.mediumGray.withValues(alpha: 0.3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              message.mediaType == 'photo' 
                  ? EvaIcons.imageOutline 
                  : EvaIcons.videoOutline,
              color: AppTheme.toxicYellow.withValues(alpha: 0.5),
              size: 48,
            ),
            SizedBox(height: 8),
            Text(
              message.mediaType == 'photo' ? 'Фото' : 'Видео',
              style: GoogleFonts.montserrat(
                color: Colors.grey.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContent() {
    return Container(
      width: double.infinity,
      height: 200,
      color: AppTheme.mediumGray.withValues(alpha: 0.3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              EvaIcons.alertCircleOutline,
              color: Colors.red.withValues(alpha: 0.7),
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'Ошибка загрузки',
              style: GoogleFonts.montserrat(
                color: Colors.red.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnknownContent() {
    return Container(
      width: double.infinity,
      height: 200,
      color: AppTheme.mediumGray.withValues(alpha: 0.3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              EvaIcons.fileOutline,
              color: AppTheme.toxicYellow.withValues(alpha: 0.5),
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'Медиа файл',
              style: GoogleFonts.montserrat(
                color: Colors.grey.shade400,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    final int seconds = (milliseconds / 1000).round();
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    
    if (minutes > 0) {
      return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '0:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildReadStatus() {
    if (!message.isMine) return SizedBox.shrink();
    
    if (!message.isRead) {
      return Icon(Icons.done, size: 18, color: Colors.grey);
    } else {
      return Icon(Icons.done_all, size: 18, color: Colors.green);
    }
  }

  List<CupertinoContextMenuAction> _buildContextMenuActions(BuildContext context) {
    final List<CupertinoContextMenuAction> actions = [];

    // Карусель реакций
    actions.add(CupertinoContextMenuAction(
      child: Container(
        height: 60,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: MediaMessageBubble.reactions.map((emoji) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Закрываем меню
                  onReaction?.call();
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
        Clipboard.setData(ClipboardData(text: message.text));
        onCopy?.call();
      },
    ));

    if (message.isMine) {
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
          onEdit?.call();
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
          onDelete?.call();
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
          onDeleteForAll?.call();
        },
      ));
    }

    // Закрепить/Открепить
    actions.add(CupertinoContextMenuAction(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPinned ? EvaIcons.pin : EvaIcons.pinOutline, 
            size: 18, 
            color: AppTheme.toxicYellow
          ),
          SizedBox(width: 8),
          Text(isPinned ? 'Открепить' : 'Закрепить'),
        ],
      ),
      onPressed: () {
        Navigator.pop(context); // Закрываем меню
        onPin?.call();
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
        onReply?.call();
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
        onForward?.call();
      },
    ));

    return actions;
  }

}
