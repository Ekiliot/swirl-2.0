import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'widgets/chat_header.dart';
import 'widgets/message_bubble.dart';
import 'widgets/typing_indicator.dart';
import 'widgets/message_input.dart';
import 'models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  final String userAvatar;

  const ChatScreen({
    super.key,
    required this.userName,
    required this.userAvatar,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadDemoMessages();
  }

  void _loadDemoMessages() {
    _messages = [
      ChatMessage(
        text: 'Привет! 👋',
        isMine: false,
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
      ),
      ChatMessage(
        text: 'Привет! Как дела?',
        isMine: true,
        timestamp: DateTime.now().subtract(Duration(hours: 2, minutes: 1)),
        isRead: true,
      ),
      ChatMessage(
        text: 'Отлично! Хочешь встретиться?',
        isMine: false,
        timestamp: DateTime.now().subtract(Duration(hours: 1)),
      ),
      ChatMessage(
        text: 'Да, с удовольствием! Когда тебе удобно?',
        isMine: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 30)),
        isRead: true,
      ),
      ChatMessage(
        text: 'Может завтра вечером?',
        isMine: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      ),
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage(String messageText) {
    if (messageText.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: messageText.trim(),
        isMine: true,
        timestamp: DateTime.now(),
        isRead: false, // Сначала непрочитано
      ));
    });

    // Прокрутка вниз после отправки
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Имитация набора текста
    setState(() => _isTyping = true);
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text: 'Звучит здорово! 😊',
            isMine: false,
            timestamp: DateTime.now(),
          ));
        });
        
        // Прокрутка вниз после ответа
        Future.delayed(Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
        
        // Пометить последнее сообщение как прочитанное через 3 секунды
        Future.delayed(Duration(seconds: 3), () {
          if (mounted && _messages.isNotEmpty) {
            setState(() {
              final lastMessageIndex = _messages.length - 1;
              _messages[lastMessageIndex] = _messages[lastMessageIndex].copyWith(isRead: true);
            });
          }
        });
      }
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Только что';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч назад';
    } else {
      return '${time.day}.${time.month}.${time.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      extendBodyBehindAppBar: true,
      appBar: ChatHeader(
        userName: widget.userName,
        userAvatar: widget.userAvatar,
        isTyping: _isTyping,
        onBack: () => Navigator.pop(context),
        onMenu: () {
          // TODO: Показать меню
        },
      ),
      body: Column(
        children: [
          // Сообщения
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(top: 90, bottom: 16, left: 16, right: 16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                // Показать индикатор печати в конце списка
                if (index == _messages.length && _isTyping) {
                  return TypingIndicator();
                }
                
                final message = _messages[index];
                final showTimestamp = index == 0 || 
                    _messages[index - 1].timestamp.difference(message.timestamp).inMinutes.abs() > 15;
                
                return MessageBubble(
                  message: message,
                  showTimestamp: showTimestamp,
                  timestampText: showTimestamp ? _formatTime(message.timestamp) : null,
                );
              },
            ),
          ),
          
          // Поле ввода
          MessageInput(
            onSendMessage: _sendMessage,
            onAttach: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.attach_file, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Функция скоро появится'),
                    ],
                  ),
                  backgroundColor: AppTheme.darkGray,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

}

