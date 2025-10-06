import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:animations/animations.dart';
import '../../theme/app_theme.dart';
import '../match/match_screen.dart';
import '../chat/chat_screen.dart';
import '../chat_roulette/chat_roulette_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notifications_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ScrollController _scrollController = ScrollController();
  double _matchCardHeight = 220.0; // Начинаем с полной высоты (раскрытое состояние)
  static const double _minHeight = 80.0;
  static const double _maxHeight = 220.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    
    double newHeight;
    
    if (offset <= 0) {
      // Pull to refresh zone или в самом верху - раскрываем карточки
      newHeight = _maxHeight;
    } else if (offset > 0 && offset < 150) {
      // Начинаем скроллить вниз - постепенно сворачиваем
      final progress = offset / 150;
      newHeight = _maxHeight - ((progress * ((_maxHeight - _minHeight))));
    } else {
      // Далеко прокрутили вниз - минимальная высота
      newHeight = _minHeight;
    }

    if ((newHeight - _matchCardHeight).abs() > 1) {
      setState(() {
        _matchCardHeight = newHeight.clamp(_minHeight, _maxHeight);
      });
    }
  }

  static const List<Map<String, dynamic>> _chats = [
    {
      'name': 'Анна',
      'message': 'Привет! Как дела? 😊',
      'time': '2 мин',
      'unread': 2,
      'avatar': 'А',
    },
    {
      'name': 'Максим',
      'message': 'Хочешь пойти в кино?',
      'time': '15 мин',
      'unread': 0,
      'avatar': 'М',
    },
    {
      'name': 'Елена',
      'message': 'Спасибо за вечер!',
      'time': '1 ч',
      'unread': 1,
      'avatar': 'Е',
    },
    {
      'name': 'Дмитрий',
      'message': 'Увидимся завтра',
      'time': '3 ч',
      'unread': 0,
      'avatar': 'Д',
    },
    {
      'name': 'София',
      'message': 'Классно провели время! 🎉',
      'time': '5 ч',
      'unread': 3,
      'avatar': 'С',
    },
    {
      'name': 'Александр',
      'message': 'Давай встретимся на выходных',
      'time': '8 ч',
      'unread': 0,
      'avatar': 'А',
    },
    {
      'name': 'Виктория',
      'message': 'Ты видел этот фильм?',
      'time': '12 ч',
      'unread': 1,
      'avatar': 'В',
    },
    {
      'name': 'Игорь',
      'message': 'Привет, как настроение?',
      'time': '1 д',
      'unread': 0,
      'avatar': 'И',
    },
    {
      'name': 'Мария',
      'message': 'Спасибо за помощь! 🙏',
      'time': '1 д',
      'unread': 2,
      'avatar': 'М',
    },
    {
      'name': 'Артём',
      'message': 'Когда будешь свободен?',
      'time': '2 д',
      'unread': 0,
      'avatar': 'А',
    },
    {
      'name': 'Ольга',
      'message': 'Отличная идея! 💡',
      'time': '2 д',
      'unread': 1,
      'avatar': 'О',
    },
    {
      'name': 'Никита',
      'message': 'Поздравляю! 🎊',
      'time': '3 д',
      'unread': 0,
      'avatar': 'Н',
    },
    {
      'name': 'Екатерина',
      'message': 'До встречи!',
      'time': '3 д',
      'unread': 0,
      'avatar': 'Е',
    },
    {
      'name': 'Сергей',
      'message': 'Как прошли выходные?',
      'time': '4 д',
      'unread': 0,
      'avatar': 'С',
    },
    {
      'name': 'Татьяна',
      'message': 'Звони когда освободишься',
      'time': '5 д',
      'unread': 1,
      'avatar': 'Т',
    },
    {
      'name': 'Владимир',
      'message': 'Отлично поработали! 💪',
      'time': '5 д',
      'unread': 0,
      'avatar': 'В',
    },
    {
      'name': 'Юлия',
      'message': 'Спокойной ночи 🌙',
      'time': '6 д',
      'unread': 0,
      'avatar': 'Ю',
    },
    {
      'name': 'Павел',
      'message': 'Ты где?',
      'time': '1 нед',
      'unread': 0,
      'avatar': 'П',
    },
  ];

  static const List<Map<String, dynamic>> _matches = [
    {
      'name': 'София',
      'age': 24,
      'gender': 'Женский',
      'distance': '2 км',
      'avatar': 'С',
      'hasLike': true,
      'hasSuperLike': false,
    },
    {
      'name': 'Алексей',
      'age': 28,
      'gender': 'Мужской',
      'distance': '5 км',
      'avatar': 'А',
      'hasLike': false,
      'hasSuperLike': true,
    },
    {
      'name': 'Виктория',
      'age': 22,
      'gender': 'Женский',
      'distance': '1 км',
      'avatar': 'В',
      'hasLike': true,
      'hasSuperLike': false,
    },
    {
      'name': 'Иван',
      'age': 26,
      'gender': 'Мужской',
      'distance': '3 км',
      'avatar': 'И',
      'hasLike': true,
      'hasSuperLike': false,
    },
    {
      'name': 'Мария',
      'age': 25,
      'gender': 'Женский',
      'distance': '4 км',
      'avatar': 'М',
      'hasLike': false,
      'hasSuperLike': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.pureBlack.withValues(alpha: 0.3),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.toxicYellow.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      OpenContainer(
                        transitionDuration: Duration(milliseconds: 400),
                        transitionType: ContainerTransitionType.fade,
                        openBuilder: (context, action) => ProfileScreen(),
                        closedElevation: 0,
                        closedShape: CircleBorder(),
                        closedColor: AppTheme.pureBlack,
                        openColor: AppTheme.pureBlack,
                        middleColor: AppTheme.pureBlack,
                        closedBuilder: (context, action) => Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.toxicYellow.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.toxicYellow.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            EvaIcons.personOutline,
                            color: AppTheme.toxicYellow,
                            size: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                AppTheme.toxicYellow,
                                AppTheme.darkYellow,
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'Swirl',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      OpenContainer(
                        transitionDuration: Duration(milliseconds: 400),
                        transitionType: ContainerTransitionType.fade,
                        openBuilder: (context, action) => NotificationsScreen(),
                        closedElevation: 0,
                        closedShape: CircleBorder(),
                        closedColor: AppTheme.pureBlack,
                        openColor: AppTheme.pureBlack,
                        middleColor: AppTheme.pureBlack,
                        closedBuilder: (context, action) => Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.toxicYellow.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.toxicYellow.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            EvaIcons.bellOutline,
                            color: AppTheme.toxicYellow,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            // Скроллируемый контент
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
            SliverToBoxAdapter(child: SizedBox(height: 16)),
            
            // Горизонтальный список матчей с анимацией
            if (_matches.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Матчи',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.toxicYellow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_matches.length}',
                          style: GoogleFonts.montserrat(
                            color: AppTheme.pureBlack,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  height: _matchCardHeight,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _matches.length,
                    itemBuilder: (context, index) {
                      return _buildMatchCard(context, _matches[index]);
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
            
            // Заголовок сообщений
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Сообщения',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.toxicYellow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_chats.where((c) => c['unread'] > 0).length}',
                        style: GoogleFonts.montserrat(
                          color: AppTheme.pureBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20)),
            
            // Список чатов
            if (_chats.isEmpty)
              SliverFillRemaining(child: _buildEmptyChatsList())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _buildChatItem(context, _chats[index]),
                  ),
                  childCount: _chats.length,
                ),
              ),
            
            // Отступ снизу для кнопок
            SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
            
            // Две кнопки внизу (зафиксированы)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.pureBlack.withValues(alpha: 0.0),
                    AppTheme.pureBlack.withValues(alpha: 0.95),
                    AppTheme.pureBlack,
                  ],
                  stops: [0.0, 0.3, 1.0],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Builder(
                      builder: (buttonContext) => _buildButton(
                        context: buttonContext,
                        icon: EvaIcons.messageCircle,
                        label: 'Новый чат',
                        onTap: () {
                          Navigator.push(
                            buttonContext,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => ChatRouletteScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);
                                return SlideTransition(position: offsetAnimation, child: child);
                              },
                              transitionDuration: Duration(milliseconds: 300),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Builder(
                      builder: (buttonContext) => _buildButton(
                        context: buttonContext,
                        icon: EvaIcons.heart,
                        label: 'Матч',
                        onTap: () {
                          Navigator.push(
                            buttonContext,
                            MaterialPageRoute(builder: (context) => MatchScreen()),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChatsList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            EvaIcons.messageCircleOutline,
            color: AppTheme.toxicYellow.withValues(alpha: 0.3),
            size: 80,
          ),
          SizedBox(height: 20),
          Text(
            'Нет сообщений',
            style: GoogleFonts.montserrat(
              color: Colors.grey.shade400,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, Map<String, dynamic> chat) {
    return Dismissible(
      key: Key(chat['name']),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Свайп вправо - закрепить
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(EvaIcons.pin, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Чат закреплен'),
                ],
              ),
              backgroundColor: AppTheme.toxicYellow,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        } else {
          // Свайп влево - удалить
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppTheme.darkGray,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Удалить чат?',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Вы уверены, что хотите удалить чат с ${chat['name']}?',
                style: GoogleFonts.montserrat(color: Colors.grey.shade400),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Отмена',
                    style: GoogleFonts.montserrat(color: Colors.grey.shade400),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Удалить',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
      background: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.toxicYellow,
              AppTheme.darkYellow,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(EvaIcons.pin, color: AppTheme.pureBlack, size: 28),
            SizedBox(height: 4),
            Text(
              'Закрепить',
              style: GoogleFonts.montserrat(
                color: AppTheme.pureBlack,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(EvaIcons.trashOutline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Удалить',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        child: OpenContainer(
          transitionDuration: Duration(milliseconds: 400),
          transitionType: ContainerTransitionType.fade,
          openBuilder: (context, action) => ChatScreen(
            userName: chat['name'],
            userAvatar: chat['avatar'],
          ),
          closedElevation: 0,
          closedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          closedColor: AppTheme.pureBlack,
          openColor: AppTheme.pureBlack,
          middleColor: AppTheme.pureBlack,
          closedBuilder: (context, action) => Container(
            decoration: BoxDecoration(
              color: AppTheme.darkGray,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.mediumGray,
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.toxicYellow,
                          AppTheme.darkYellow,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        chat['avatar'],
                        style: GoogleFonts.montserrat(
                          color: AppTheme.pureBlack,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              chat['name'],
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              chat['time'],
                              style: GoogleFonts.montserrat(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                chat['message'],
                                style: GoogleFonts.montserrat(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (chat['unread'] > 0)
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.toxicYellow,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${chat['unread']}',
                                  style: GoogleFonts.montserrat(
                                    color: AppTheme.pureBlack,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
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
    );
  }

  Widget _buildMatchCard(BuildContext context, Map<String, dynamic> match) {
    // Вычисляем размеры на основе текущей высоты контейнера
    final isExpanded = _matchCardHeight > 150;
    final cardWidth = isExpanded ? 200.0 : (_matchCardHeight * 4 / 3);
    final avatarSize = isExpanded ? 56.0 : 32.0;
    final showDetails = _matchCardHeight > 120;
    
    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(right: 12),
      child: OpenContainer(
        transitionDuration: Duration(milliseconds: 400),
        transitionType: ContainerTransitionType.fade,
        openBuilder: (context, action) => ProfileScreen(),
        closedElevation: 0,
        closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        closedColor: AppTheme.pureBlack,
        openColor: AppTheme.pureBlack,
        middleColor: AppTheme.pureBlack,
        closedBuilder: (context, action) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Карточка с аватаром (адаптивная)
            Stack(
              children: [
                Container(
                  height: _matchCardHeight - (showDetails ? 50 : 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.toxicYellow, AppTheme.darkYellow],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      match['avatar'],
                      style: GoogleFonts.montserrat(
                        color: AppTheme.pureBlack,
                        fontSize: avatarSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Индикатор лайка/суперлайка
                if (match['hasSuperLike'])
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(Icons.star, color: Colors.white, size: 16),
                    ),
                  )
                else if (match['hasLike'])
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.pink,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(Icons.favorite, color: Colors.white, size: 16),
                    ),
                  ),
              ],
            ),
            if (showDetails) ...[
              SizedBox(height: 8),
              // Имя и возраст
              Row(
                children: [
                  Expanded(
                    child: Text(
                      match['name'],
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${match['age']}',
                    style: GoogleFonts.montserrat(
                      color: AppTheme.toxicYellow,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              // Расстояние и пол
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey.shade500, size: 12),
                  SizedBox(width: 2),
                  Text(
                    match['distance'],
                    style: GoogleFonts.montserrat(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text('•', style: GoogleFonts.montserrat(color: Colors.grey.shade600, fontSize: 11)),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      match['gender'],
                      style: GoogleFonts.montserrat(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.darkGray,
          foregroundColor: AppTheme.toxicYellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppTheme.toxicYellow, width: 2),
          ),
          elevation: 8,
          shadowColor: AppTheme.toxicYellow.withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}