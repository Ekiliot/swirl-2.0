import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

/// Настройки приватности для статуса
enum PrivacyLevel {
  showExactTime,     // Показывать точное время
  showRecent,        // Показывать "недавно", "в сети"
  showWeek,          // Показывать "на этой неделе"
  showMonth,         // Показывать "в этом месяце"
  showLongAgo,       // Показывать "давно"
}

/// Сервис для управления статусом активности пользователей
class UserActivityService {
  static final UserActivityService _instance = UserActivityService._internal();
  factory UserActivityService() => _instance;
  UserActivityService._internal();

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Timer? _activityTimer;
  static const String _activityPath = 'user_activity';
  static const String _userSettingsPath = 'user_settings';
  
  /// Инициализация сервиса активности
  Future<void> initialize() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Устанавливаем начальный статус
    await _updateActivityStatus();
    
    // Запускаем периодическое обновление каждую минуту
    _startActivityTimer();
    
    // Обновляем статус при изменении состояния аутентификации
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _startActivityTimer();
      } else {
        _stopActivityTimer();
      }
    });
  }

  /// Запуск таймера активности
  void _startActivityTimer() {
    _stopActivityTimer();
    _activityTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      _updateActivityStatus();
    });
  }

  /// Остановка таймера активности
  void _stopActivityTimer() {
    _activityTimer?.cancel();
    _activityTimer = null;
  }

  /// Обновление статуса активности пользователя
  Future<void> _updateActivityStatus() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final now = DateTime.now();
      await _database.ref('$_activityPath/${user.uid}').set({
        'lastSeen': now.millisecondsSinceEpoch,
        'isOnline': true,
        'updatedAt': now.millisecondsSinceEpoch,
      });
      
      print('UserActivityService: Статус активности обновлен для ${user.uid}');
    } catch (e) {
      print('UserActivityService: Ошибка обновления статуса активности: $e');
    }
  }

  /// Получение статуса активности пользователя
  Future<Map<String, dynamic>?> getUserActivity(String userId) async {
    try {
      final snapshot = await _database.ref('$_activityPath/$userId').get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      print('UserActivityService: Ошибка получения статуса активности: $e');
      return null;
    }
  }

  /// Получение отформатированного статуса активности
  Future<String> getFormattedActivityStatus(String userId) async {
    try {
      final activity = await getUserActivity(userId);
      if (activity == null) return 'Никогда не был в сети';

      final lastSeenMs = activity['lastSeen'] as int?;
      if (lastSeenMs == null) return 'Неизвестно';

      final lastSeen = DateTime.fromMillisecondsSinceEpoch(lastSeenMs);
      final now = DateTime.now();
      final difference = now.difference(lastSeen);

      // Получаем настройки приватности пользователя
      final privacyLevel = await getUserPrivacyLevel(userId);

      return _formatActivityStatus(difference, privacyLevel);
    } catch (e) {
      print('UserActivityService: Ошибка форматирования статуса: $e');
      return 'Неизвестно';
    }
  }

  /// Форматирование статуса активности в зависимости от настроек приватности
  String _formatActivityStatus(Duration difference, PrivacyLevel privacyLevel) {
    switch (privacyLevel) {
      case PrivacyLevel.showExactTime:
        return _formatExactTime(difference);
      case PrivacyLevel.showRecent:
        return _formatRecentTime(difference);
      case PrivacyLevel.showWeek:
        return _formatWeekTime(difference);
      case PrivacyLevel.showMonth:
        return _formatMonthTime(difference);
      case PrivacyLevel.showLongAgo:
        return _formatLongAgoTime(difference);
    }
  }

  /// Точное время
  String _formatExactTime(Duration difference) {
    if (difference.inMinutes < 1) {
      return 'В сети';
    } else if (difference.inMinutes < 60) {
      return 'Был в сети ${difference.inMinutes} мин. назад';
    } else if (difference.inHours < 24) {
      return 'Был в сети ${difference.inHours} ч. назад';
    } else if (difference.inDays < 7) {
      return 'Был в сети ${difference.inDays} дн. назад';
    } else {
      final lastSeen = DateTime.now().subtract(difference);
      return 'Был в сети ${lastSeen.day}.${lastSeen.month}.${lastSeen.year}';
    }
  }

  /// Недавнее время
  String _formatRecentTime(Duration difference) {
    if (difference.inMinutes < 1) {
      return 'В сети';
    } else if (difference.inMinutes < 5) {
      return 'Был в сети недавно';
    } else if (difference.inHours < 1) {
      return 'Был в сети недавно';
    } else if (difference.inDays < 1) {
      return 'Был в сети недавно';
    } else {
      return 'Был в сети давно';
    }
  }

  /// Время на неделе
  String _formatWeekTime(Duration difference) {
    if (difference.inMinutes < 1) {
      return 'В сети';
    } else if (difference.inDays < 7) {
      return 'Был в сети на этой неделе';
    } else {
      return 'Был в сети давно';
    }
  }

  /// Время в месяце
  String _formatMonthTime(Duration difference) {
    if (difference.inMinutes < 1) {
      return 'В сети';
    } else if (difference.inDays < 30) {
      return 'Был в сети в этом месяце';
    } else {
      return 'Был в сети давно';
    }
  }

  /// Давно
  String _formatLongAgoTime(Duration difference) {
    if (difference.inMinutes < 1) {
      return 'В сети';
    } else {
      return 'Был в сети давно';
    }
  }

  /// Получение уровня приватности пользователя
  Future<PrivacyLevel> getUserPrivacyLevel(String userId) async {
    try {
      final snapshot = await _database.ref('$_userSettingsPath/$userId/privacyLevel').get();
      if (snapshot.exists) {
        final level = snapshot.value as int;
        return PrivacyLevel.values[level];
      }
      return PrivacyLevel.showExactTime; // По умолчанию
    } catch (e) {
      print('UserActivityService: Ошибка получения уровня приватности: $e');
      return PrivacyLevel.showExactTime;
    }
  }

  /// Установка уровня приватности для текущего пользователя
  Future<void> setPrivacyLevel(PrivacyLevel level) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _database.ref('$_userSettingsPath/${user.uid}/privacyLevel').set(level.index);
      print('UserActivityService: Уровень приватности установлен: ${level.name}');
    } catch (e) {
      print('UserActivityService: Ошибка установки уровня приватности: $e');
    }
  }

  /// Получение списка онлайн пользователей
  Stream<List<String>> getOnlineUsers() {
    return _database.ref(_activityPath).onValue.map((event) {
      if (event.snapshot.value == null) return <String>[];
      
      final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      final List<String> onlineUsers = [];
      
      data.forEach((userId, activityData) {
        if (activityData is Map) {
          final lastSeenMs = activityData['lastSeen'] as int?;
          if (lastSeenMs != null) {
            final lastSeen = DateTime.fromMillisecondsSinceEpoch(lastSeenMs);
            final difference = DateTime.now().difference(lastSeen);
            
            // Считаем онлайн если был активен в последние 2 минуты
            if (difference.inMinutes < 2) {
              onlineUsers.add(userId);
            }
          }
        }
      });
      
      return onlineUsers;
    });
  }

  /// Проверка, онлайн ли пользователь
  Future<bool> isUserOnline(String userId) async {
    try {
      final activity = await getUserActivity(userId);
      if (activity == null) return false;

      final lastSeenMs = activity['lastSeen'] as int?;
      if (lastSeenMs == null) return false;

      final lastSeen = DateTime.fromMillisecondsSinceEpoch(lastSeenMs);
      final difference = DateTime.now().difference(lastSeen);
      
      // Считаем онлайн если был активен в последние 2 минуты
      return difference.inMinutes < 2;
    } catch (e) {
      print('UserActivityService: Ошибка проверки статуса онлайн: $e');
      return false;
    }
  }

  /// Очистка данных при выходе из приложения
  Future<void> cleanup() async {
    _stopActivityTimer();
    
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Помечаем пользователя как офлайн
        await _database.ref('$_activityPath/${user.uid}').update({
          'isOnline': false,
          'lastSeen': DateTime.now().millisecondsSinceEpoch,
        });
        print('UserActivityService: Пользователь помечен как офлайн');
      } catch (e) {
        print('UserActivityService: Ошибка при выходе: $e');
      }
    }
  }

  /// Принудительное обновление статуса (при активности пользователя)
  Future<void> updateActivityNow() async {
    await _updateActivityStatus();
  }
}
