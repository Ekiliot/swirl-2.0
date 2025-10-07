import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
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
                borderRadius: const BorderRadius.only(
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
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
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
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                EvaIcons.arrowBackOutline,
                                color: AppTheme.toxicYellow,
                                size: 20,
                              ),
                              onPressed: () => Navigator.pop(context),
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
                                  'Уведомления',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.darkGray.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.toxicYellow.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: AppTheme.toxicYellow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelColor: AppTheme.pureBlack,
                          unselectedLabelColor: Colors.grey.shade400,
                          labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 14),
                          unselectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 14),
                          tabs: const [
                            Tab(text: 'Системные'),
                            Tab(text: 'Активность'),
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
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildSystemTab(),
            _buildActivityTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkGray.withValues(alpha: 0.7),
            AppTheme.mediumGray.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.toxicYellow.withValues(alpha: 0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSystemTab() {
    final items = [
      _SystemNotif(title: 'Обновление профиля', subtitle: 'Ваш профиль успешно сохранён'),
      _SystemNotif(title: 'Новая функция', subtitle: 'Доступна чат-рулетка'),
      _SystemNotif(title: 'Безопасность', subtitle: 'Подтвердите email для защиты аккаунта'),
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(top: 120, bottom: 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.toxicYellow.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.toxicYellow.withValues(alpha: 0.3), width: 1),
                ),
                child: Icon(EvaIcons.info, color: AppTheme.toxicYellow, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle,
                      style: GoogleFonts.montserrat(color: Colors.grey.shade400, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(EvaIcons.clockOutline, color: Colors.grey.shade500, size: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityTab() {
    final items = <_ActivityNotif>[
      _ActivityNotif(type: _ActivityType.like, user: 'Анна'),
      _ActivityNotif(type: _ActivityType.superLike, user: 'Максим'),
      _ActivityNotif(type: _ActivityType.comment, user: 'Елена', comment: 'Классный профиль!'),
      _ActivityNotif(type: _ActivityType.like, user: 'Дмитрий'),
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(top: 120, bottom: 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        late final IconData icon;
        late final Color color;
        late final String title;

        switch (item.type) {
          case _ActivityType.like:
            icon = EvaIcons.heart;
            color = Colors.redAccent;
            title = '${item.user} поставил лайк';
            break;
          case _ActivityType.superLike:
            icon = EvaIcons.star;
            color = Colors.blueAccent;
            title = '${item.user} отправил супер-лайк';
            break;
          case _ActivityType.comment:
            icon = EvaIcons.messageCircle;
            color = AppTheme.toxicYellow;
            title = '${item.user} оставил комментарий';
            break;
        }

        return _buildCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.6)]),
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 16, spreadRadius: 2),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    if (item.comment != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.comment!,
                        style: GoogleFonts.montserrat(color: Colors.grey.shade300, fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(EvaIcons.clockOutline, color: Colors.grey.shade500, size: 16),
            ],
          ),
        );
      },
    );
  }
}

class _SystemNotif {
  final String title;
  final String subtitle;
  _SystemNotif({required this.title, required this.subtitle});
}

enum _ActivityType { like, superLike, comment }

class _ActivityNotif {
  final _ActivityType type;
  final String user;
  final String? comment;
  _ActivityNotif({required this.type, required this.user, this.comment});
}


