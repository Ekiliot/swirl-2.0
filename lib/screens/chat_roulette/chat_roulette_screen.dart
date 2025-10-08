import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../services/chat_roulette_service.dart';
import '../../services/pinned_messages_service.dart';
import '../chat/widgets/chat_header.dart';
import '../chat/widgets/visible_message_bubble.dart';
import '../chat/widgets/media_message_bubble.dart';
import '../chat/widgets/message_input.dart';
import '../chat/widgets/typing_indicator.dart';
import '../chat/widgets/pinned_message_widget.dart';
import '../chat/models/chat_message.dart';

// Линейное смещение градиента для shimmer
class _ShimmerTranslation extends GradientTransform {
  final double dx;
  const _ShimmerTranslation(this.dx);
  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(dx, 0.0, 0.0);
  }
}

class ChatRouletteScreen extends StatefulWidget {
  final String? initialChatId;
  final String? initialPartnerName;
  final String? initialPartnerAvatar;
  final bool isSavedChat; // Флаг для сохраненных чатов

  const ChatRouletteScreen({
    super.key,
    this.initialChatId,
    this.initialPartnerName,
    this.initialPartnerAvatar,
    this.isSavedChat = false,
  });

  @override
  State<ChatRouletteScreen> createState() => _ChatRouletteScreenState();
}

class _ChatRouletteScreenState extends State<ChatRouletteScreen>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _isSearching = true;
  bool _isTyping = false;
  List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<AnimatedListState> _skeletonListKey = GlobalKey<AnimatedListState>();
  
  // Состояние загрузки медиа
  bool _isUploadingMedia = false;
  double _mediaUploadProgress = 0.0;
  Uint8List? _mediaThumbnail;
  int _skeletonCount = 0;
  Timer? _skeletonTimer;
  
  // Закрепленное сообщение
  ChatMessage? _pinnedMessage;
  
  // Данные текущего матча
  String? _currentPartner;
  String? _currentAvatar;
  String? _currentChatId;
  
  // Сервис чат-рулетки
  final ChatRouletteService _chatRouletteService = ChatRouletteService.instance;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat();
    
    // Загружаем закрепленные сообщения
    _loadPinnedMessages();
    
    // Если передан существующий чат, загружаем его
    if (widget.initialChatId != null) {
      _currentChatId = widget.initialChatId;
      _currentPartner = widget.initialPartnerName;
      _currentAvatar = widget.initialPartnerAvatar;
      _isSearching = false;
      // Останавливаем анимацию скелетона для существующего чата
      _skeletonTimer?.cancel();
      _skeletonCount = 0;
      _loadChatMessages();
    } else {
    _startSkeletonFlow();
      _initializeChatRoulette();
    }
  }

  @override
  void dispose() {
    _skeletonTimer?.cancel();
    _shimmerController.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    
    // Полная очистка данных при выходе из экрана
    _chatRouletteService.cleanupUserData();
    
    super.dispose();
  }

  void _startSkeletonFlow() {
    // Плавное добавление скелетонов сообщений, пока идёт поиск
    _skeletonTimer?.cancel();
    _skeletonCount = 0;
    _skeletonTimer = Timer.periodic(Duration(milliseconds: 280), (timer) {
      if (!_isSearching) {
        timer.cancel();
        return;
      }
      final insertIndex = _skeletonCount;
      _skeletonCount += 1;
      _skeletonListKey.currentState?.insertItem(
        insertIndex,
        duration: Duration(milliseconds: 260),
      );
      // Ограничим длину, чтобы не раздувать список
      if (_skeletonCount >= 12) {
        timer.cancel();
      }
    });
  }

  /// Инициализация чат-рулетки
  Future<void> _initializeChatRoulette() async {
    try {
      // Проверяем текущий статус пользователя
      final status = await _chatRouletteService.getUserStatus();
      
      if (status == 'connected') {
        // Пользователь уже подключен к чату
        await _loadCurrentMatch();
      } else {
        // Пользователь не в поиске, начинаем поиск
        await _startSearch();
      }
    } catch (e) {
      print('Ошибка инициализации чат-рулетки: $e');
      // В случае ошибки показываем демо-данные
      _startDemoSearch();
    }
  }

  /// Начать поиск собеседника
  Future<void> _startSearch() async {
    try {
      // Получаем данные пользователя из профиля
      // Здесь нужно будет интегрировать с ProfileService
      await _chatRouletteService.joinSearchQueue(
        name: 'Пользователь', // Временно, нужно получить из профиля
        age: 25, // Временно, нужно получить из профиля
        gender: 'Мужской', // Временно, нужно получить из профиля
        interests: ['Музыка', 'Спорт'], // Временно, нужно получить из профиля
      );

        // Слушаем матчи напрямую
        _chatRouletteService.watchMatch().listen((match) {
          if (mounted && match != null) {
            // Останавливаем анимацию скелетона
            _skeletonTimer?.cancel();
            
            setState(() {
              _isSearching = false;
              _currentPartner = match['partnerName'] as String?;
              _currentAvatar = match['partnerAvatar'] as String?;
              _currentChatId = match['chatId'] as String?;
              // Очищаем скелетоны при переходе к чату
              _skeletonCount = 0;
            });
            
            if (_currentChatId != null) {
              _loadChatMessages();
            }
          }
        });
    } catch (e) {
      print('Ошибка при начале поиска: $e');
      _startDemoSearch();
    }
  }

  /// Загрузить текущий матч
  Future<void> _loadCurrentMatch() async {
    try {
      final match = await _chatRouletteService.getCurrentMatch();
      if (match != null) {
        // Останавливаем анимацию скелетона
        _skeletonTimer?.cancel();
        
        setState(() {
          _currentPartner = match['partnerName'] as String;
          _currentAvatar = match['partnerAvatar'] as String;
          _currentChatId = match['chatId'] as String;
          _isSearching = false;
          // Очищаем скелетоны при переходе к чату
          _skeletonCount = 0;
        });

        // Загружаем сообщения чата
        if (_currentChatId != null) {
          _loadChatMessages();
        }
      }
    } catch (e) {
      print('Ошибка загрузки матча: $e');
      _startDemoSearch();
    }
  }

  /// Обработка видимости сообщения
  void _onMessageVisible(String messageText) {
    if (_currentChatId != null) {
      // Получаем ID сообщения из Firestore
      _chatRouletteService.getChatMessages(_currentChatId!).first.then((messages) {
        final messageData = messages.firstWhere(
          (data) => data['text'] == messageText && data['senderId'] != FirebaseAuth.instance.currentUser?.uid,
          orElse: () => messages.first,
        );
        
        if (messageData['id'] != null) {
          _chatRouletteService.markMessageAsRead(_currentChatId!, messageData['id']);
        }
      });
    }
  }

  /// Закрепление сообщения
  void _pinMessage(ChatMessage message) async {
    try {
      final success = await PinnedMessagesService.pinMessage(message);
      if (success) {
        setState(() {
          _pinnedMessage = message;
        });
        print('Сообщение закреплено: ${message.text}');
      } else {
        print('Ошибка при закреплении сообщения');
      }
    } catch (e) {
      print('Ошибка при закреплении сообщения: $e');
    }
  }

  /// Открепление сообщения
  void _unpinMessage() async {
    try {
      if (_pinnedMessage != null) {
        final success = await PinnedMessagesService.unpinMessage(_pinnedMessage!);
        if (success) {
          setState(() {
            _pinnedMessage = null;
          });
          print('Сообщение откреплено');
        } else {
          print('Ошибка при откреплении сообщения');
        }
      }
    } catch (e) {
      print('Ошибка при откреплении сообщения: $e');
    }
  }

  /// Загрузка закрепленных сообщений из локального хранилища
  void _loadPinnedMessages() async {
    try {
      final pinnedMessages = await PinnedMessagesService.getPinnedMessages();
      if (pinnedMessages.isNotEmpty) {
        setState(() {
          _pinnedMessage = pinnedMessages.first; // Показываем только первое закрепленное сообщение
        });
        print('Загружено закрепленных сообщений: ${pinnedMessages.length}');
      }
    } catch (e) {
      print('Ошибка при загрузке закрепленных сообщений: $e');
    }
  }

  /// Создание виджета загружаемого медиа
  Widget _buildUploadingMediaMessage() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 280,
        maxHeight: 200,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(6),
          bottomRight: Radius.circular(24),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.toxicYellow,
            AppTheme.darkYellow,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.toxicYellow.withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(6),
          bottomRight: Radius.circular(24),
        ),
        child: Stack(
          children: [
            // Миниатюра как фон
            if (_mediaThumbnail != null)
              Container(
                width: double.infinity,
                height: double.infinity,
                child: Image.memory(
                  _mediaThumbnail!,
                  fit: BoxFit.cover,
                ),
              ),
            
            // Оверлей с прогрессом
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Круглый прогресс бар
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: _mediaUploadProgress,
                        strokeWidth: 3,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.toxicYellow),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Текст прогресса
                    Text(
                      '${(_mediaUploadProgress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Обработка выбора медиа
  void _onMediaSelected(Map<String, dynamic> mediaData) async {
    try {
      setState(() {
        _isUploadingMedia = true;
        _mediaUploadProgress = 0.0;
        _mediaThumbnail = mediaData['thumbnailData'];
      });

      // Не создаем временное сообщение - показываем только виджет загрузки

      // Симулируем прогресс загрузки
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          _mediaUploadProgress = i / 100.0;
        });
      }

      // Отправляем медиа сообщение
      await _chatRouletteService.sendMessage(
        chatId: _currentChatId!,
        text: mediaData['type'] == 'photo' ? '📷 Фото' : '🎥 Видео',
        mediaType: mediaData['type'],
        mediaUrl: mediaData['url'],
        mediaSize: mediaData['size'],
        mediaDuration: mediaData['duration'],
      );

      // Завершаем загрузку
      setState(() {
        _isUploadingMedia = false;
        _mediaThumbnail = null;
      });

      // Прокручиваем к концу
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      print('Ошибка при отправке медиа: $e');
      setState(() {
        _isUploadingMedia = false;
        _mediaThumbnail = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка отправки медиа'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Загрузить сообщения чата
  void _loadChatMessages() {
    if (_currentChatId == null) return;

    _chatRouletteService.getChatMessages(_currentChatId!).listen((messages) {
      if (mounted) {
        setState(() {
          _messages = messages.map((data) {
            // Безопасная обработка timestamp
            DateTime timestamp;
            if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
              timestamp = (data['timestamp'] as Timestamp).toDate();
            } else if (data['timestamp'] != null && data['timestamp'] is DateTime) {
              timestamp = data['timestamp'] as DateTime;
            } else {
              timestamp = DateTime.now();
            }
            
            final messageId = data['id'] as String?;
            print('Создаем ChatMessage: text=${data['text']}, messageId=$messageId, senderId=${data['senderId']}');
            
            return ChatMessage(
              text: data['text'] as String? ?? '',
              isMine: data['senderId'] == FirebaseAuth.instance.currentUser?.uid,
              timestamp: timestamp,
              isRead: data['isRead'] as bool? ?? false,
              messageId: messageId,
              mediaType: data['mediaType'] as String?,
              mediaUrl: data['mediaUrl'] as String?,
              mediaSize: data['mediaSize'] as int?,
              mediaDuration: data['mediaDuration'] as int?,
            );
          }).toList();
          
          // Прокрутка к концу после загрузки сообщений
          Future.delayed(Duration(milliseconds: 100), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        });
      }
    });
  }

  /// Демо-поиск (для отладки)
  void _startDemoSearch() {
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        // Останавливаем анимацию скелетона
        _skeletonTimer?.cancel();
        
          setState(() {
            _isSearching = false;
          _currentPartner = 'Анна';
          _currentAvatar = 'А';
          // Очищаем скелетоны при переходе к чату
          _skeletonCount = 0;
            _loadDemoMessages();
        });
      }
    });
  }

  void _loadDemoMessages() {
    _messages = [
      ChatMessage(
        text: 'Привет! 👋',
        isMine: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 2)),
      ),
      ChatMessage(
        text: 'Привет! Как дела?',
        isMine: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 1)),
        isRead: true,
      ),
    ];
  }

  void _sendMessage(String messageText) {
    if (messageText.trim().isEmpty) return;

    // Если есть активный чат, отправляем сообщение через сервис
    if (_currentChatId != null) {
      _chatRouletteService.sendMessage(
        chatId: _currentChatId!,
        text: messageText.trim(),
      );
    } else {
      // Демо-режим
    setState(() {
      _messages.add(ChatMessage(
        text: messageText.trim(),
        isMine: true,
        timestamp: DateTime.now(),
        isRead: false,
      ));
    });

    // Имитация набора текста
    setState(() => _isTyping = true);
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text: 'Отлично! 😊',
            isMine: false,
            timestamp: DateTime.now(),
          ));
        });
        }
      });
    }
        
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 280),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
              child: child,
            ),
          ),
          child: _isSearching
              ? KeyedSubtree(key: ValueKey('searchingAppBar'), child: _buildSearchingHeader())
              : KeyedSubtree(
                  key: ValueKey('chatAppBar'),
                  child: ChatHeader(
        userName: _currentPartner ?? 'Неизвестно',
        userAvatar: _currentAvatar ?? '?',
        isTyping: _isTyping,
        onBack: () async {
          if (widget.isSavedChat) {
            // Для сохраненных чатов просто выходим
            Navigator.pop(context);
            return;
          }
          
          if (_currentChatId != null) {
            // Если есть активный чат, показываем диалог с выбором
            final action = await showDialog<String>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppTheme.darkGray,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Text(
                  'Что делать с чатом?',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                content: Text(
                  'Вы можете удалить чат или оставить его для продолжения общения.',
                  style: TextStyle(color: Colors.grey[300]),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'cancel'),
                    child: Text('Отмена', style: TextStyle(color: Colors.grey[400])),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'delete'),
                    child: Text('Удалить', style: TextStyle(color: Colors.red)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'keep'),
                    child: Text('Оставить', style: TextStyle(color: Colors.green)),
                  ),
                ],
              ),
            );

            if (action == 'delete') {
              await _chatRouletteService.deleteChat(_currentChatId!);
            } else if (action == 'keep') {
              await _chatRouletteService.endMatch();
            } else {
              return; // Отмена
            }
          }
          
          // Очищаем данные перед выходом
          _chatRouletteService.cleanupUserData();
          Navigator.pop(context);
        },
        onMenu: widget.isSavedChat ? null : () => _showChatMenu(context),
                  ),
                ),
        ),
      ),
      body: SafeArea(
        child: Column(
        children: [
          // Закрепленное сообщение
          if (_pinnedMessage != null)
            PinnedMessageWidget(
              pinnedMessage: _pinnedMessage!,
              onUnpin: _unpinMessage,
            ),
          // Основной контент
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
                  child: child,
                ),
              ),
              child: _isSearching
                  ? KeyedSubtree(key: ValueKey('skeletonView'), child: _buildSearchingView())
                  : KeyedSubtree(key: ValueKey('chatView'), child: _buildChatView()),
            ),
          ),
          
          // Поле ввода (только когда не ищем)
          if (!_isSearching) ...[
            MessageInput(
              onSendMessage: _sendMessage,
              onAttach: () {
                // Fallback для старых версий
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
              onMediaSelected: _onMediaSelected,
          ),
            
            // Кнопки управления чатом
          ],
        ],
        ),
      ),
    );
  }

  Widget _buildSearchingHeader() {
    return PreferredSize(
      preferredSize: Size.fromHeight(70),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.darkGray.withValues(alpha: 0.8),
                  AppTheme.mediumGray.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.toxicYellow.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Кнопка назад
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.mediumGray.withValues(alpha: 0.4),
                            AppTheme.mediumGray.withValues(alpha: 0.2),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.toxicYellow.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => Navigator.pop(context),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    
                    // Заголовок поиска
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Поиск собеседника',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Ищем идеального собеседника',
                            style: GoogleFonts.montserrat(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchingView() {
    // Скелетон-чат с AnimatedList: элементы плавно появляются
    return Padding(
      padding: EdgeInsets.only(top: 90, bottom: 24, left: 16, right: 16),
      child: Column(
        children: [
          // Верхняя стеклянная карточка-инфо
          _buildSkeletonGlass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 68,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.mediumGray.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 14),
                _buildSkeletonLine(width: 180, height: 18),
                SizedBox(height: 8),
                _buildSkeletonLine(width: 220, height: 12),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Скелетон-сообщения с анимацией вставки
          Expanded(
            child: AnimatedList(
              key: _skeletonListKey,
              initialItemCount: 0,
              itemBuilder: (context, index, animation) {
                final bool isMine = index % 2 == 0;
                final double widthFactor = isMine ? 0.7 : 0.8;
                return SizeTransition(
                  sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                  child: FadeTransition(
                    opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: _buildSkeletonMessageBubble(isMine: isMine, widthFactor: widthFactor),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonMessageBubble({required bool isMine, required double widthFactor}) {
    final bubbleColor = AppTheme.darkGray;
    final borderColor = AppTheme.mediumGray.withValues(alpha: 0.5);
    final radius = BorderRadius.only(
      topLeft: Radius.circular(22),
      topRight: Radius.circular(22),
      bottomLeft: Radius.circular(isMine ? 22 : 6),
      bottomRight: Radius.circular(isMine ? 6 : 22),
    );

    return Row(
      mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * widthFactor),
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: isMine ? null : bubbleColor,
                  gradient: isMine
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.toxicYellow,
                            AppTheme.darkYellow,
                          ],
                        )
                      : null,
                  borderRadius: radius,
                  border: isMine ? null : Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSkeletonLine(width: 120, height: 12),
                    SizedBox(height: 8),
                    _buildSkeletonLine(width: 160, height: 12),
                  ],
                ),
              ),
              // Shimmer маска
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, _) {
                    final double t = _shimmerController.value;
                    return ShaderMask(
                      shaderCallback: (rect) {
                        final width = rect.width;
                        final gradientWidth = width * 0.2;
                        final dx = (width + gradientWidth) * t - gradientWidth;
                    return LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.25),
                            Colors.transparent,
                          ],
                          stops: [0, 0.5, 1],
                          transform: _ShimmerTranslation(dx),
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.srcATop,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.02),
                          borderRadius: radius,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonGlass({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkGray.withValues(alpha: 0.55),
                AppTheme.mediumGray.withValues(alpha: 0.35),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.toxicYellow.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSkeletonLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.mediumGray.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  // (удалено) _buildSkeletonBar — не используется

  Widget _buildChatView() {
    // Сортируем сообщения по времени (старые сверху, новые снизу)
    final sortedMessages = List<ChatMessage>.from(_messages)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(top: 90, bottom: 16, left: 16, right: 16),
      itemCount: sortedMessages.length + (_isTyping ? 1 : 0) + (_isUploadingMedia ? 1 : 0),
      itemBuilder: (context, index) {
        // Показать анимацию загрузки медиа
        if (index == sortedMessages.length && _isUploadingMedia) {
          // Проверяем, нет ли уже медиа сообщения от текущего пользователя
          final hasRecentMediaMessage = sortedMessages.any((msg) => 
            msg.isMine && 
            msg.mediaType != null && 
            DateTime.now().difference(msg.timestamp).inSeconds < 5
          );
          
          if (hasRecentMediaMessage) {
            // Если есть недавнее медиа сообщение, не показываем виджет загрузки
            return SizedBox.shrink();
          }
          
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: _buildUploadingMediaMessage(),
                ),
              ],
            ),
          );
        }
        
        // Показать индикатор печати в конце списка
        if (index == sortedMessages.length + (_isUploadingMedia ? 1 : 0) && _isTyping) {
          return TypingIndicator();
        }
        
        final message = sortedMessages[index];
        final showTimestamp = index == 0 || 
            sortedMessages[index - 1].timestamp.difference(message.timestamp).inMinutes.abs() > 15;
        
        // Выбираем тип виджета в зависимости от типа сообщения
        if (message.mediaType != null) {
          return MediaMessageBubble(
            message: message,
            showTimestamp: showTimestamp,
            timestampText: showTimestamp ? _formatTime(message.timestamp) : null,
            isPinned: _pinnedMessage?.text == message.text,
            onCopy: () {
              Clipboard.setData(ClipboardData(text: message.text));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Сообщение скопировано'),
                  backgroundColor: AppTheme.toxicYellow,
                ),
              );
            },
            onDelete: () async {
              if (message.messageId != null && _currentChatId != null) {
                try {
                  await _chatRouletteService.deleteMessageForMe(_currentChatId!, message.messageId!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Сообщение скрыто'),
                      backgroundColor: AppTheme.toxicYellow,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка при скрытии сообщения'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            onDeleteForAll: () async {
              print('onDeleteForAll вызван для медиа сообщения: ${message.text}');
              print('messageId: ${message.messageId}');
              print('currentChatId: $_currentChatId');
              
              if (message.messageId != null && _currentChatId != null) {
                try {
                  print('Пытаемся удалить медиа сообщение ${message.messageId} из чата $_currentChatId');
                  await _chatRouletteService.deleteMessageForAll(_currentChatId!, message.messageId!);
                  print('Медиа сообщение успешно удалено');
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Сообщение удалено для всех'),
                      backgroundColor: AppTheme.toxicYellow,
                    ),
                  );
                } catch (e) {
                  print('Ошибка при удалении медиа сообщения: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка при удалении сообщения: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                print('Не удалось удалить медиа сообщение: messageId=${message.messageId}, chatId=$_currentChatId');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ошибка: отсутствует ID сообщения или чата'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            onEdit: () {
              // TODO: Реализовать редактирование медиа сообщения
              print('Редактировать медиа сообщение');
            },
            onReply: () {
              // TODO: Реализовать ответ на медиа сообщение
              print('Ответить на медиа сообщение');
            },
            onForward: () {
              // TODO: Реализовать пересылку медиа сообщения
              print('Переслать медиа сообщение');
            },
            onPin: () {
              if (_pinnedMessage?.text == message.text) {
                _unpinMessage();
              } else {
                _pinMessage(message);
              }
            },
            onReaction: () {
              // TODO: Реализовать реакцию на медиа сообщение
              print('Реакция на медиа сообщение');
            },
          );
        } else {
          return VisibleMessageBubble(
            message: message,
            showTimestamp: showTimestamp,
            timestampText: showTimestamp ? _formatTime(message.timestamp) : null,
            chatId: _currentChatId ?? '',
            onMessageVisible: _onMessageVisible,
            isPinned: _pinnedMessage?.text == message.text,
            onCopy: () {
              Clipboard.setData(ClipboardData(text: message.text));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Сообщение скопировано'),
                  backgroundColor: AppTheme.toxicYellow,
                ),
              );
            },
            onDelete: () async {
              if (message.messageId != null && _currentChatId != null) {
                try {
                  await _chatRouletteService.deleteMessageForMe(_currentChatId!, message.messageId!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Сообщение скрыто'),
                      backgroundColor: AppTheme.toxicYellow,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка при скрытии сообщения'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            onDeleteForAll: () async {
              print('onDeleteForAll вызван для медиа сообщения: ${message.text}');
              print('messageId: ${message.messageId}');
              print('currentChatId: $_currentChatId');
              
              if (message.messageId != null && _currentChatId != null) {
                try {
                  print('Пытаемся удалить медиа сообщение ${message.messageId} из чата $_currentChatId');
                  await _chatRouletteService.deleteMessageForAll(_currentChatId!, message.messageId!);
                  print('Медиа сообщение успешно удалено');
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Сообщение удалено для всех'),
                      backgroundColor: AppTheme.toxicYellow,
                    ),
                  );
                } catch (e) {
                  print('Ошибка при удалении медиа сообщения: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка при удалении сообщения: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                print('Не удалось удалить медиа сообщение: messageId=${message.messageId}, chatId=$_currentChatId');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ошибка: отсутствует ID сообщения или чата'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            onEdit: () {
              // TODO: Реализовать редактирование сообщения
              print('Редактировать сообщение');
            },
            onReply: () {
              // TODO: Реализовать ответ на сообщение
              print('Ответить на сообщение');
            },
            onForward: () {
              // TODO: Реализовать пересылку сообщения
              print('Переслать сообщение');
            },
            onPin: () {
              if (_pinnedMessage?.text == message.text) {
                _unpinMessage();
              } else {
                _pinMessage(message);
              }
            },
            onReaction: () {
              // TODO: Реализовать реакцию на сообщение
              print('Реакция на сообщение');
            },
          );
        }
      },
    );
  }


  // (удалено) _buildStatusBar — заменён статическим скелетоном

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Найти следующего собеседника - показывает диалог выбора
  Future<void> _findNextPartner() async {
    // Показываем диалог: удалить чат или оставить
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkGray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Что делать с текущим чатом?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Вы можете удалить чат или оставить его для продолжения общения.',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: Text('Отмена', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'delete'),
            child: Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'keep'),
            child: Text('Оставить', style: TextStyle(color: Colors.green)),
                            ),
                          ],
                        ),
    );

    if (action == 'delete') {
      // Удаляем чат и ищем следующего
      await _deleteChatAndFindNext();
    } else if (action == 'keep') {
      // Оставляем чат и ищем следующего
      await _keepChatAndFindNext();
    }
  }

  /// Удалить чат и найти следующего собеседника
  Future<void> _deleteChatAndFindNext() async {
    if (_currentChatId == null) return;

    try {
      await _chatRouletteService.deleteChat(_currentChatId!);
      
      // Показываем индикатор поиска
      setState(() {
        _isSearching = true;
        _messages.clear();
        _currentPartner = null;
        _currentAvatar = null;
        _currentChatId = null;
      });

      // Запускаем анимацию скелетона
      _startSkeletonFlow();
      
      // Слушатель матчей уже активен из _startSearch()
      // Дополнительный слушатель не нужен
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
                      children: [
              Icon(Icons.delete, color: Colors.white),
              SizedBox(width: 8),
              Text('Чат удален. Ищем следующего собеседника...'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при удалении чата'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Оставить чат и найти следующего собеседника
  Future<void> _keepChatAndFindNext() async {
    try {
      // Только завершаем текущий матч, НЕ создаем новый чат
      await _chatRouletteService.findNextPartner();
      
      // Показываем индикатор поиска
      setState(() {
        _isSearching = true;
        _messages.clear();
        _currentPartner = null;
        _currentAvatar = null;
        _currentChatId = null;
      });

      // Запускаем анимацию скелетона
      _startSkeletonFlow();
      
      // Слушатель матчей уже активен из _startSearch()
      // Дополнительный слушатель не нужен
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
                          children: [
              Icon(Icons.save, color: Colors.white),
              SizedBox(width: 8),
              Text('Чат сохранен. Ищем следующего собеседника...'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при поиске следующего собеседника'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Показать диалог подтверждения удаления
  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkGray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Удалить чат?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Это действие нельзя отменить. Чат будет удален навсегда.',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteChat();
            },
            child: Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Удалить чат
  Future<void> _deleteChat() async {
    if (_currentChatId == null) return;

    try {
      await _chatRouletteService.deleteChat(_currentChatId!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.delete, color: Colors.white),
              SizedBox(width: 8),
              Text('Чат удален'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Закрываем экран
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при удалении чата'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Завершить чат
  Future<void> _endChat() async {
    try {
      await _chatRouletteService.endMatch();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.exit_to_app, color: Colors.white),
              SizedBox(width: 8),
              Text('Чат завершен'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Закрываем экран
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при завершении чата'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showChatMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.pureBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Индикатор
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            
            // Кнопка "Следующий собеседник"
            _buildMenuButton(
              icon: Icons.skip_next,
              title: 'Следующий собеседник',
              subtitle: 'Найти нового партнера',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                _findNextPartner();
              },
            ),
            
            SizedBox(height: 12),
            
            // Кнопка "Удалить чат"
            _buildMenuButton(
              icon: Icons.delete,
              title: 'Удалить чат',
              subtitle: 'Удалить этот чат навсегда',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmDialog();
              },
            ),
            
            SizedBox(height: 12),
            
            // Кнопка "Завершить чат"
            _buildMenuButton(
              icon: Icons.close,
              title: 'Завершить чат',
              subtitle: 'Покинуть текущий чат',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _endChat();
              },
            ),
            
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkGray.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[600],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
