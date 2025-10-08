import 'package:flutter/material.dart';
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
            child: GestureDetector(
              onLongPress: () => _showContextMenu(context),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 280,
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                        bottomLeft: Radius.circular(message.isMine ? 24 : 6),
                        bottomRight: Radius.circular(message.isMine ? 6 : 24),
                      ),
                      child: _buildMediaContent(),
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
}
