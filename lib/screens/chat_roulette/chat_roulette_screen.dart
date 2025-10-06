import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../chat/widgets/chat_header.dart';
import '../chat/widgets/message_input.dart';
import '../chat/widgets/typing_indicator.dart';
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
  const ChatRouletteScreen({super.key});

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
  int _skeletonCount = 0;
  Timer? _skeletonTimer;
  
  final String _currentPartner = 'Анна';
  final String _currentAvatar = 'А';

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat();
    _startSkeletonFlow();
    _startSearch();
  }

  @override
  void dispose() {
    _skeletonTimer?.cancel();
    _shimmerController.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
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

  void _startSearch() {
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
          setState(() {
            _isSearching = false;
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

    setState(() {
      _messages.add(ChatMessage(
        text: messageText.trim(),
        isMine: true,
        timestamp: DateTime.now(),
        isRead: false,
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
            text: 'Отлично! 😊',
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
        userName: _currentPartner,
        userAvatar: _currentAvatar,
        isTyping: _isTyping,
        onBack: () => Navigator.pop(context),
                    onMenu: () {},
                  ),
                ),
        ),
      ),
      body: Column(
        children: [
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
          if (!_isSearching)
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
    return ListView.builder(
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
        
        return _buildMessageBubble(message, showTimestamp);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool showTimestamp) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 300),
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
                    child: _buildReadStatus(message),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadStatus(ChatMessage message) {
    final isRead = message.isRead;
    
    if (message.isMine) {
      if (!isRead) {
        return Icon(
          Icons.check,
          size: 18,
          color: Colors.blue,
        );
      } else {
        return Icon(
          Icons.done_all,
          size: 18,
          color: Colors.blue,
        );
      }
    } else {
      return Icon(
        Icons.done_all,
        size: 18,
        color: Colors.green,
      );
    }
  }

  // (удалено) _buildStatusBar — заменён статическим скелетоном

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
