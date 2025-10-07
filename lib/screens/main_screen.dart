import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../models/chat.dart';
import '../theme/app_theme.dart';
import 'match/match_screen.dart';
import 'profile/profile_screen.dart';
import 'search/search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Chat> _chats = [
    Chat(
      id: '1',
      name: 'Алексей',
      lastMessage: 'Привет! Как дела?',
      lastMessageTime: DateTime.now().subtract(Duration(minutes: 5)),
      avatarUrl: '',
      isOnline: true,
      unreadCount: 2,
    ),
    Chat(
      id: '2',
      name: 'Мария',
      lastMessage: 'Спасибо за помощь!',
      lastMessageTime: DateTime.now().subtract(Duration(hours: 2)),
      avatarUrl: '',
      isOnline: false,
      unreadCount: 0,
    ),
    Chat(
      id: '3',
      name: 'Дмитрий',
      lastMessage: 'До свидания 👋',
      lastMessageTime: DateTime.now().subtract(Duration(days: 1)),
      avatarUrl: '',
      isOnline: false,
      unreadCount: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.pureBlack,
        elevation: 0,
        title: Text(
          'Swirl',
          style: TextStyle(
            color: AppTheme.toxicYellow,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            fontFamily: 'Montserrat',
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(EvaIcons.searchOutline, color: AppTheme.toxicYellow, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(EvaIcons.personOutline, color: AppTheme.toxicYellow, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Кнопки действий
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                // Кнопка поиска собеседников (пока неактивна)
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.darkGray,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.mediumGray,
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Поиск собеседников скоро будет доступен!'),
                              backgroundColor: AppTheme.toxicYellow,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          child: Text(
                            'Найти собеседника',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Кнопка матчинга
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.toxicYellow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MatchScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(EvaIcons.heart, color: AppTheme.pureBlack, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Матч',
                                style: TextStyle(
                                  color: AppTheme.pureBlack,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Список чатов
          Expanded(
            child: ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final chat = _chats[index];
                return Slidable(
                  key: Key(chat.id),
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    extentRatio: 0.6,
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          _pinChat(chat);
                        },
                        backgroundColor: AppTheme.toxicYellow,
                        foregroundColor: AppTheme.pureBlack,
                        icon: EvaIcons.pin,
                        label: 'Закрепить',
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        spacing: 12,
                      ),
                      SlidableAction(
                        onPressed: (context) {
                          _deleteChat(chat);
                        },
                        backgroundColor: Color(0xFFFF4444), // Красный, но не чистый
                        foregroundColor: Colors.white,
                        icon: EvaIcons.trash2,
                        label: 'Удалить',
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        spacing: 12,
                      ),
                    ],
                  ),
                  child: _ChatTile(chat: chat),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _pinChat(Chat chat) {
    setState(() {
      final index = _chats.indexOf(chat);
      if (index != -1) {
        _chats[index] = chat.copyWith(isPinned: !chat.isPinned);
        // Переместить закрепленный чат в начало списка
        if (chat.isPinned) {
          _chats.removeAt(index);
          _chats.insert(0, chat.copyWith(isPinned: true));
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(chat.isPinned ? 'Чат закреплен' : 'Чат откреплен'),
        backgroundColor: AppTheme.toxicYellow,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _deleteChat(Chat chat) {
    setState(() {
      _chats.remove(chat);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Чат удален'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final Chat chat;

  const _ChatTile({required this.chat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.mediumGray.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Аватар
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.toxicYellow,
                  AppTheme.darkYellow,
                ],
              ),
              border: Border.all(
                color: chat.isOnline ? Colors.green : AppTheme.mediumGray,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.toxicYellow.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                chat.name[0].toUpperCase(),
                style: TextStyle(
                  color: AppTheme.pureBlack,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ),

          SizedBox(width: 16),

          // Информация о чате
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      chat.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    if (chat.isPinned) ...[
                      SizedBox(width: 8),
                      Icon(
                        EvaIcons.pin,
                        size: 14,
                        color: AppTheme.toxicYellow,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  chat.lastMessage,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Время и количество непрочитанных
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(chat.lastMessageTime),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                ),
              ),
              if (chat.unreadCount > 0) ...[
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.toxicYellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    chat.unreadCount.toString(),
                    style: TextStyle(
                      color: AppTheme.pureBlack,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}д';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч';
    } else {
      return '${difference.inMinutes}м';
    }
  }
}