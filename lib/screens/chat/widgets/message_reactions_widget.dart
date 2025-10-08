import 'package:flutter/material.dart';

class MessageReactionsWidget extends StatelessWidget {
  final VoidCallback? onReactionSelected;
  final bool showAbove; // Показывать сверху или снизу
  final double menuWidth; // Ширина меню для позиционирования

  const MessageReactionsWidget({
    super.key,
    this.onReactionSelected,
    this.showAbove = false,
    required this.menuWidth,
  });

  static const List<String> reactions = [
    '😀', '🤣', '😅', '😍', '😘', '😎', '😉', '😋', '🤗', '🤩',
    '🤨', '😐', '😑', '🙄', '😏', '😥', '😯', '😴', '🥱', '😫',
    '😨', '🥳', '😈', '👿', '💀', '💩', '👍', '👎', '🍆', '🍑',
    '🌚', '🌝', '❤️', '❤️‍🔥', '💔', '🤡', // клоун в конце
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: menuWidth, // Точно такая же ширина как у контекстного меню
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: reactions.map((emoji) => _buildReactionButton(emoji)).toList(),
        ),
      ),
    );
  }

  Widget _buildReactionButton(String emoji) {
    // Вычисляем размер эмодзи на основе ширины меню
    final double emojiSize = (menuWidth / 8).clamp(24.0, 32.0); // 8 эмодзи на экране
    final double buttonWidth = menuWidth / reactions.length; // Равномерное распределение
    
    return GestureDetector(
      onTap: () {
        onReactionSelected?.call();
        print('Выбрана реакция: $emoji');
      },
      child: Container(
        width: buttonWidth,
        height: 44,
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(fontSize: emojiSize),
          ),
        ),
      ),
    );
  }

  /// Показать виджет реакций
  static OverlayEntry show({
    required BuildContext context,
    required Offset position,
    required double menuWidth,
    required bool showAbove,
    VoidCallback? onReactionSelected,
  }) {
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: showAbove 
            ? position.dy - 70 // Плотно над контекстным меню (60px высота + 10px отступ)
            : position.dy + 320, // Плотно под контекстным меню (320px высота меню)
        child: Material(
          color: Colors.transparent,
          child: MessageReactionsWidget(
            showAbove: showAbove,
            menuWidth: menuWidth,
            onReactionSelected: () {
              overlayEntry.remove(); // Удаляем overlay при выборе
              onReactionSelected?.call();
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    return overlayEntry;
  }
}
