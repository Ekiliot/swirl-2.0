import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> with TickerProviderStateMixin {
  final List<User> _users = [
    User(
      id: '1',
      name: 'Анна',
      age: 25,
      gender: 'female',
      avatarUrl: '',
      bio: 'Люблю путешествия и хорошую музыку 🎵',
      interests: ['Музыка', 'Путешествия', 'Фотография', 'Кино'],
    ),
    User(
      id: '2',
      name: 'Максим',
      age: 28,
      gender: 'male',
      avatarUrl: '',
      bio: 'Спортсмен, люблю активный отдых 🏃',
      interests: ['Спорт', 'Горы', 'Книги', 'Кулинария'],
    ),
    User(
      id: '3',
      name: 'Елена',
      age: 23,
      gender: 'female',
      avatarUrl: '',
      bio: 'Художница, творческий человек 🎨',
      interests: ['Искусство', 'Живопись', 'Кино', 'Театр'],
    ),
    User(
      id: '4',
      name: 'Дмитрий',
      age: 30,
      gender: 'male',
      avatarUrl: '',
      bio: 'IT-специалист, увлекаюсь технологиями 💻',
      interests: ['Технологии', 'Путешествия', 'Гейминг', 'Фотография'],
    ),
    User(
      id: '5',
      name: 'София',
      age: 26,
      gender: 'female',
      avatarUrl: '',
      bio: 'Дизайнер, люблю творчество 🖌️',
      interests: ['Дизайн', 'Мода', 'Искусство', 'Путешествия'],
    ),
  ];
  
  int _currentIndex = 0;
  Offset _position = Offset.zero;
  
  late AnimationController _animationController;
  late AnimationController _nextCardController;
  late Animation<double> _nextCardScaleAnimation;
  late Animation<double> _nextCardOffsetAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    
    _nextCardController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    
    _nextCardScaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _nextCardController,
      curve: Curves.easeOutCubic,
    ));
    
    _nextCardOffsetAnimation = Tween<double>(
      begin: 8,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _nextCardController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nextCardController.dispose();
    super.dispose();
  }

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
                            EvaIcons.options2Outline,
                            color: AppTheme.toxicYellow,
                            size: 20,
                          ),
                          onPressed: () {},
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
      body: _currentIndex >= _users.length 
        ? _buildEmptyState() 
        : _buildCardStack(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.toxicYellow.withValues(alpha: 0.2),
                  AppTheme.toxicYellow.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(color: AppTheme.toxicYellow, width: 3),
            ),
            child: Icon(
              Icons.search_off,
              color: AppTheme.toxicYellow,
              size: 60,
            ),
          ),
          SizedBox(height: 40),
          Text(
            'Больше нет людей поблизости',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Расширьте радиус поиска или попробуйте позже',
              style: GoogleFonts.montserrat(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _currentIndex = 0;
              });
            },
            icon: Icon(Icons.refresh),
            label: Text('Начать заново'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.toxicYellow,
              foregroundColor: AppTheme.pureBlack,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 8,
              shadowColor: AppTheme.toxicYellow.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardStack() {
    return SafeArea(
      child: Column(
        children: [
          // Карточки
          Expanded(
            child: Stack(
              children: [
                // Задние карточки (2-3 карточки сзади для глубины)
                if (_currentIndex + 2 < _users.length)
                  _buildBackCard(_users[_currentIndex + 2], 0.85, 16),
                if (_currentIndex + 1 < _users.length)
                  _buildBackCard(_users[_currentIndex + 1], 0.92, 8),
                
                // Основная интерактивная карточка
                _buildDraggableCard(_users[_currentIndex]),
              ],
            ),
          ),
          
          // Кнопки действий
          Padding(
            padding: EdgeInsets.only(bottom: 30, top: 20),
            child: _buildActionButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(User user, double scale, double topOffset) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.center,
        child: AnimatedBuilder(
          animation: _nextCardController,
          builder: (context, child) {
            // Если это первая задняя карточка (та, что станет активной)
            final isNextCard = scale == 0.92;
            final animatedScale = isNextCard 
              ? _nextCardScaleAnimation.value 
              : scale;
            final animatedOffset = isNextCard 
              ? _nextCardOffsetAnimation.value 
              : topOffset;
            
            return Transform.translate(
              offset: Offset(0, animatedOffset),
              child: Transform.scale(
                scale: animatedScale,
                child: _buildCardContent(user, isInteractive: false),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDraggableCard(User user) {
    final screenWidth = MediaQuery.of(context).size.width;
    final rotationAngle = _position.dx / screenWidth * 0.4;

    return Positioned.fill(
      child: GestureDetector(
        onPanStart: (details) {},
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
        },
        onPanEnd: (details) {
          final velocityX = details.velocity.pixelsPerSecond.dx;
          final velocityY = details.velocity.pixelsPerSecond.dy;
          
          // Проверяем вертикальный свайп (вверх или вниз) для супер лайка
          if (_position.dy.abs() > 100 || velocityY.abs() > 500) {
            _superLike();
          }
          // Проверяем горизонтальный свайп
          else if (_position.dx.abs() > 100 || velocityX.abs() > 500) {
            if (_position.dx > 0 || velocityX > 0) {
              _swipeRight();
            } else {
              _swipeLeft();
            }
          } 
          // Возвращаем карточку на место
          else {
            _resetPosition();
          }
        },
        child: Transform.translate(
          offset: _position,
          child: Transform.rotate(
            angle: rotationAngle,
            child: _buildCardContent(user, isInteractive: true),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(User user, {required bool isInteractive}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1a1a1a),
                Color(0xFF2d2d2d),
                Color(0xFF1a1a1a),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Декоративные элементы фона
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.toxicYellow.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.toxicYellow.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              
              // Основной контент
              Column(
                children: [
                  SizedBox(height: 80),
                  
                  // Аватар
                  Container(
                    width: 120,
                    height: 120,
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
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.toxicYellow.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: GoogleFonts.montserrat(
                          color: AppTheme.pureBlack,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  Spacer(),
                  
                  // Информация
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      user.name,
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '${user.age}',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.toxicYellow.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.toxicYellow,
                                  width: 2,
                                ),
                              ),
                            child: Icon(
                              EvaIcons.infoOutline,
                              color: AppTheme.toxicYellow,
                              size: 24,
                            ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 12),
                        
                        Row(
                          children: [
                            Icon(
                              EvaIcons.pinOutline,
                              color: AppTheme.toxicYellow,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '2 км от вас',
                              style: GoogleFonts.montserrat(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 12),
                        
                        Text(
                          user.bio,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        SizedBox(height: 16),
                        
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: user.interests.take(3).map((interest) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.toxicYellow.withValues(alpha: 0.3),
                                  AppTheme.toxicYellow.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.toxicYellow.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              interest,
                              style: GoogleFonts.montserrat(
                                color: AppTheme.toxicYellow,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
              _buildActionButton(
                icon: EvaIcons.close,
                color: Colors.red,
                size: 60,
                iconSize: 32,
                onTap: _swipeLeft,
              ),
              _buildActionButton(
                icon: EvaIcons.star,
                color: Colors.blue,
                size: 50,
                iconSize: 28,
                onTap: _superLike,
              ),
              _buildActionButton(
                icon: EvaIcons.heart,
                color: AppTheme.toxicYellow,
                size: 60,
                iconSize: 32,
                onTap: _swipeRight,
              ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required double size,
    required double iconSize,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.pureBlack,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: iconSize,
        ),
      ),
    );
  }

  void _swipeLeft() {
    setState(() {
      _position = Offset(-500, 0);
    });
    
    // Запускаем анимацию следующей карточки
    _nextCardController.forward();
    
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _currentIndex++;
        _position = Offset.zero;
      });
      _nextCardController.reset();
    });
  }

  void _swipeRight() {
    setState(() {
      _position = Offset(500, 0);
    });
    
    // Запускаем анимацию следующей карточки
    _nextCardController.forward();
    
    Future.delayed(Duration(milliseconds: 200), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(EvaIcons.heart, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Лайк отправлен!',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: AppTheme.toxicYellow,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: 1),
        ),
      );
      
      setState(() {
        _currentIndex++;
        _position = Offset.zero;
      });
      _nextCardController.reset();
    });
  }

  void _superLike() {
    // Определяем направление (вверх или вниз)
    final direction = _position.dy < 0 ? -1 : 1;
    
    setState(() {
      _position = Offset(0, direction * 800);
    });
    
    // Запускаем анимацию следующей карточки
    _nextCardController.forward();
    
    Future.delayed(Duration(milliseconds: 200), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(EvaIcons.star, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Супер лайк отправлен! ⭐',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: 1),
        ),
      );
      
      setState(() {
        _currentIndex++;
        _position = Offset.zero;
      });
      _nextCardController.reset();
    });
  }

  void _resetPosition() {
    setState(() {
      _position = Offset.zero;
    });
  }
}

