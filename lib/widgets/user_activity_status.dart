import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../services/user_activity_service.dart';

/// Виджет для отображения статуса активности пользователя
class UserActivityStatus extends StatefulWidget {
  final String userId;
  final bool showOnlineIndicator;
  final TextStyle? textStyle;
  final Color? onlineColor;
  final Color? offlineColor;

  const UserActivityStatus({
    super.key,
    required this.userId,
    this.showOnlineIndicator = true,
    this.textStyle,
    this.onlineColor,
    this.offlineColor,
  });

  @override
  State<UserActivityStatus> createState() => _UserActivityStatusState();
}

class _UserActivityStatusState extends State<UserActivityStatus> {
  final UserActivityService _activityService = UserActivityService();
  String _statusText = 'Загрузка...';
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _loadActivityStatus();
  }

  Future<void> _loadActivityStatus() async {
    try {
      // Получаем статус активности
      final statusText = await _activityService.getFormattedActivityStatus(widget.userId);
      final isOnline = await _activityService.isUserOnline(widget.userId);
      
      if (mounted) {
        setState(() {
          _statusText = statusText;
          _isOnline = isOnline;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusText = 'Неизвестно';
          _isOnline = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Индикатор онлайн статуса
        if (widget.showOnlineIndicator) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _isOnline 
                  ? (widget.onlineColor ?? AppTheme.toxicYellow)
                  : (widget.offlineColor ?? Colors.grey),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
        ],
        
        // Текст статуса
        Text(
          _statusText,
          style: widget.textStyle ?? GoogleFonts.montserrat(
            color: _isOnline 
                ? (widget.onlineColor ?? AppTheme.toxicYellow)
                : (widget.offlineColor ?? Colors.grey.shade400),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Компактный виджет статуса для чатов
class CompactActivityStatus extends StatelessWidget {
  final String userId;
  final bool isOnline;

  const CompactActivityStatus({
    super.key,
    required this.userId,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isOnline ? AppTheme.toxicYellow : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Виджет настроек приватности статуса
class ActivityPrivacySettings extends StatefulWidget {
  const ActivityPrivacySettings({super.key});

  @override
  State<ActivityPrivacySettings> createState() => _ActivityPrivacySettingsState();
}

class _ActivityPrivacySettingsState extends State<ActivityPrivacySettings> {
  final UserActivityService _activityService = UserActivityService();
  PrivacyLevel _currentLevel = PrivacyLevel.showExactTime;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    // Получаем текущие настройки для текущего пользователя
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final level = await _activityService.getUserPrivacyLevel(user.uid);
      if (mounted) {
        setState(() {
          _currentLevel = level;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Статус активности',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        
        Text(
          'Кто может видеть время вашего последнего посещения:',
          style: GoogleFonts.montserrat(
            color: Colors.grey.shade300,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 16),
        
        ...PrivacyLevel.values.map((level) {
          return RadioListTile<PrivacyLevel>(
            title: Text(
              _getPrivacyLevelTitle(level),
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              _getPrivacyLevelDescription(level),
              style: GoogleFonts.montserrat(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),
            ),
            value: level,
            groupValue: _currentLevel,
            activeColor: AppTheme.toxicYellow,
            onChanged: (value) async {
              if (value != null) {
                await _activityService.setPrivacyLevel(value);
                if (mounted) {
                  setState(() {
                    _currentLevel = value;
                  });
                }
              }
            },
          );
        }).toList(),
      ],
    );
  }

  String _getPrivacyLevelTitle(PrivacyLevel level) {
    switch (level) {
      case PrivacyLevel.showExactTime:
        return 'Точное время';
      case PrivacyLevel.showRecent:
        return 'Недавно';
      case PrivacyLevel.showWeek:
        return 'На этой неделе';
      case PrivacyLevel.showMonth:
        return 'В этом месяце';
      case PrivacyLevel.showLongAgo:
        return 'Давно';
    }
  }

  String _getPrivacyLevelDescription(PrivacyLevel level) {
    switch (level) {
      case PrivacyLevel.showExactTime:
        return 'Показывать точное время последнего посещения';
      case PrivacyLevel.showRecent:
        return 'Показывать только "в сети" или "был недавно"';
      case PrivacyLevel.showWeek:
        return 'Показывать "в сети", "на этой неделе" или "давно"';
      case PrivacyLevel.showMonth:
        return 'Показывать "в сети", "в этом месяце" или "давно"';
      case PrivacyLevel.showLongAgo:
        return 'Показывать только "в сети" или "давно"';
    }
  }
}
