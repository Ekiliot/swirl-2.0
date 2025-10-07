import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'dart:ui';
import '../../../theme/app_theme.dart';

class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String userAvatar;
  final bool isTyping;
  final VoidCallback onBack;
  final VoidCallback? onMenu;

  const ChatHeader({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.isTyping,
    required this.onBack,
    this.onMenu,
  });

  @override
  Size get preferredSize => Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
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
                    // Кнопка назад с анимацией
                    _buildAnimatedBackButton(),
                    SizedBox(width: 12),
                    
                    // Аватар с градиентной рамкой
                    _buildAvatar(),
                    SizedBox(width: 12),
                    
                    // Информация о пользователе
                    Expanded(child: _buildUserInfo()),
                    
                    // Кнопка меню (только если onMenu не null)
                    if (onMenu != null) _buildMenuButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackButton() {
    return Container(
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
          onTap: onBack,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                EvaIcons.arrowBackOutline,
                color: Colors.white,
                size: 20,
              ),
            ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppTheme.toxicYellow,
            AppTheme.darkYellow,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.toxicYellow.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          userAvatar,
          style: GoogleFonts.montserrat(
            color: AppTheme.pureBlack,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Имя пользователя
        Text(
          userName,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 2),
        
        // Статус с анимацией
        Row(
          children: [
            // Индикатор онлайн
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isTyping ? AppTheme.toxicYellow : Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isTyping ? AppTheme.toxicYellow : Colors.green).withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            SizedBox(width: 6),
            
            // Текст статуса
            Text(
              isTyping ? 'печатает...' : 'онлайн',
              style: GoogleFonts.montserrat(
                color: isTyping ? AppTheme.toxicYellow : Colors.grey.shade400,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontStyle: isTyping ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuButton() {
    return Container(
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
          onTap: onMenu,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              EvaIcons.moreVerticalOutline,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
