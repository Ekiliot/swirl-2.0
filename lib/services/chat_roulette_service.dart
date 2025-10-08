import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Сервис для управления чат-рулеткой
/// 
/// Использует Firebase Realtime Database для очереди поиска
/// и Firestore для хранения чатов
class ChatRouletteService {
  ChatRouletteService._();
  static final ChatRouletteService instance = ChatRouletteService._();

  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Пути в RTDB
  static const String _queuePath = 'chat_roulette/queue';
  static const String _matchesPath = 'chat_roulette/matches';
  
  // Пути в Firestore
  static const String _directMessagesPath = 'direct_messages';

  /// Получить текущего пользователя
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Добавить пользователя в очередь поиска
  Future<void> joinSearchQueue({
    required String name,
    required int age,
    required String gender,
    required List<String> interests,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw StateError('Пользователь не авторизован');

    final userData = {
      'uid': userId,
      'name': name,
      'age': age,
      'gender': gender,
      'interests': interests,
      'status': 'searching',
      'joinedAt': ServerValue.timestamp,
    };

    await _rtdb.ref('$_queuePath/$userId').set(userData);
  }

  /// Удалить пользователя из очереди поиска
  Future<void> leaveSearchQueue() async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _rtdb.ref('$_queuePath/$userId').remove();
  }

  /// Полная очистка данных пользователя (при выходе из экрана)
  Future<void> cleanupUserData() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      // Удаляем из очереди поиска
      await _rtdb.ref('$_queuePath/$userId').remove();
      
       // Получаем информацию о текущем матче
       final matchSnapshot = await _rtdb.ref('$_matchesPath/$userId').once();
       final matchData = matchSnapshot.snapshot.value;
       
       if (matchData != null) {
         // Безопасное приведение типов
         final match = Map<String, dynamic>.from(matchData as Map);
         final partnerId = match['partnerId'] as String?;
         final chatId = match['chatId'] as String?;
        
        // Удаляем матч пользователя
        await _rtdb.ref('$_matchesPath/$userId').remove();
        
        // Если есть партнер, удаляем и его матч
        if (partnerId != null) {
          await _rtdb.ref('$_matchesPath/$partnerId').remove();
          
          // Сбрасываем статус партнера на 'searching'
          await _rtdb.ref('$_queuePath/$partnerId/status').set('searching');
        }
        
         // Удаляем чат, если он существует
         if (chatId != null) {
           await _deleteChat(chatId);
         }
      }
    } catch (e) {
      print('Ошибка при очистке данных пользователя: $e');
    }
  }

  /// Удаление чата
  Future<void> _deleteChat(String chatId) async {
    try {
      print('Удаление чата: $chatId');
      
      // Удаляем сообщения
      final messagesSnapshot = await _firestore
          .collection(_directMessagesPath)
          .doc(chatId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      
      for (final messageDoc in messagesSnapshot.docs) {
        batch.delete(messageDoc.reference);
      }

      // Удаляем сам чат
      batch.delete(_firestore.collection(_directMessagesPath).doc(chatId));
      
      await batch.commit();
      print('Чат $chatId успешно удален');
    } catch (e) {
      print('Ошибка при удалении чата $chatId: $e');
      
      // Попробуем удалить напрямую
      try {
        await _firestore.collection(_directMessagesPath).doc(chatId).delete();
        print('Чат $chatId удален напрямую');
      } catch (e2) {
        print('Не удалось удалить чат $chatId: $e2');
      }
    }
  }

  /// Получить статус пользователя в очереди
  Future<String?> getUserStatus() async {
    final userId = _currentUserId;
    if (userId == null) return null;

    final snapshot = await _rtdb.ref('$_queuePath/$userId/status').get();
    return snapshot.value as String?;
  }

  /// Слушать изменения статуса пользователя
  Stream<String?> watchUserStatus() {
    final userId = _currentUserId;
    if (userId == null) return Stream.value(null);

    return _rtdb.ref('$_queuePath/$userId/status').onValue.map((event) {
      return event.snapshot.value as String?;
    });
  }

  /// Слушать матчи пользователя
  Stream<Map<String, dynamic>?> watchMatch() {
    final userId = _currentUserId;
    if (userId == null) return Stream.value(null);

    return _rtdb.ref('$_matchesPath/$userId').onValue.map((event) {
      final data = event.snapshot.value;
      return data != null ? Map<String, dynamic>.from(data as Map) : null;
    });
  }

  /// Получить информацию о текущем матче
  Future<Map<String, dynamic>?> getCurrentMatch() async {
    final userId = _currentUserId;
    if (userId == null) return null;

    try {
      final snapshot = await _rtdb.ref('$_matchesPath/$userId').get();
      final data = snapshot.value;
      
      if (data != null) {
        return Map<String, dynamic>.from(data as Map);
      }
      return null;
    } catch (e) {
      print('Ошибка при получении текущего матча: $e');
      return null;
    }
  }

  /// Создать чат в Firestore
  Future<String> createChat({
    required String partnerId,
    required String partnerName,
    required String partnerAvatar,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw StateError('Пользователь не авторизован');

    final chatId = '${userId}_$partnerId';
    
    final chatData = {
      'id': chatId,
      'participants': [userId, partnerId],
      'participantNames': {
        userId: 'Вы',
        partnerId: partnerName,
      },
      'participantAvatars': {
        userId: 'В',
        partnerId: partnerAvatar,
      },
      'isTemporary': false,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': null,
      'lastMessageTime': null,
    };

    await _firestore.collection(_directMessagesPath).doc(chatId).set(chatData);
    return chatId;
  }

  /// Получить сообщения чата
  Stream<List<Map<String, dynamic>>> getChatMessages(String chatId) {
    return _firestore
        .collection(_directMessagesPath)
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList());
  }

  /// Отправить сообщение в чат
  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? mediaType,
    String? mediaUrl,
    int? mediaSize,
    int? mediaDuration,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw StateError('Пользователь не авторизован');

    final messageData = {
      'text': text,
      'senderId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'messageType': mediaType ?? 'text',
    };

    // Добавляем медиа данные если есть
    if (mediaType != null) {
      messageData['mediaType'] = mediaType;
      if (mediaUrl != null) messageData['mediaUrl'] = mediaUrl;
      if (mediaSize != null) messageData['mediaSize'] = mediaSize;
      if (mediaDuration != null) messageData['mediaDuration'] = mediaDuration;
    }

    await _firestore
        .collection(_directMessagesPath)
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    // Обновить последнее сообщение в чате
    await _firestore.collection(_directMessagesPath).doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  /// Удалить чат
  Future<void> deleteChat(String chatId) async {
    final userId = _currentUserId;
    if (userId == null) throw StateError('Пользователь не авторизован');

    try {
      // Используем Cloud Function для удаления чата
      final callable = FirebaseFunctions.instance.httpsCallable('deleteChat');
      final result = await callable.call({'chatId': chatId});
      
      print('Результат удаления чата: ${result.data}');
    } catch (e) {
      print('Ошибка при удалении чата через Cloud Function: $e');
      throw e;
    }
  }

  /// Отметить сообщение как прочитанное
  Future<void> markMessageAsRead(String chatId, String messageId) async {
    try {
      await _firestore
          .collection(_directMessagesPath)
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});
      
      print('ChatRouletteService: Сообщение $messageId отмечено как прочитанное');
    } catch (e) {
      print('ChatRouletteService: Ошибка при обновлении статуса прочтения: $e');
    }
  }

  /// Удалить сообщение для всех участников чата
  Future<void> deleteMessageForAll(String chatId, String messageId) async {
    final userId = _currentUserId;
    print('ChatRouletteService: deleteMessageForAll вызван');
    print('ChatRouletteService: chatId=$chatId, messageId=$messageId, userId=$userId');
    
    if (userId == null) {
      print('ChatRouletteService: Пользователь не авторизован');
      throw StateError('Пользователь не авторизован');
    }

    try {
      print('ChatRouletteService: Получаем сообщение из Firestore...');
      // Проверяем, что сообщение принадлежит текущему пользователю
      final messageDoc = await _firestore
          .collection(_directMessagesPath)
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .get();

      print('ChatRouletteService: Сообщение существует: ${messageDoc.exists}');
      
      if (!messageDoc.exists) {
        print('ChatRouletteService: Сообщение не найдено в Firestore');
        throw StateError('Сообщение не найдено');
      }

      final messageData = messageDoc.data()!;
      print('ChatRouletteService: Данные сообщения: $messageData');
      print('ChatRouletteService: senderId=${messageData['senderId']}, userId=$userId');
      
      if (messageData['senderId'] != userId) {
        print('ChatRouletteService: Нет прав на удаление - senderId не совпадает');
        throw StateError('Нет прав на удаление этого сообщения');
      }

      print('ChatRouletteService: Удаляем сообщение...');
      // Удаляем сообщение
      await _firestore
          .collection(_directMessagesPath)
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();

      print('ChatRouletteService: Сообщение $messageId успешно удалено для всех');
    } catch (e) {
      print('ChatRouletteService: Ошибка при удалении сообщения для всех: $e');
      print('ChatRouletteService: Тип ошибки: ${e.runtimeType}');
      throw e;
    }
  }

  /// Удалить сообщение только для текущего пользователя (скрыть)
  Future<void> deleteMessageForMe(String chatId, String messageId) async {
    final userId = _currentUserId;
    if (userId == null) throw StateError('Пользователь не авторизован');

    try {
      // Добавляем пользователя в список скрытых сообщений
      await _firestore
          .collection(_directMessagesPath)
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'hiddenFor': FieldValue.arrayUnion([userId])
      });

      print('ChatRouletteService: Сообщение $messageId скрыто для пользователя $userId');
    } catch (e) {
      print('ChatRouletteService: Ошибка при скрытии сообщения: $e');
      throw e;
    }
  }

  /// Отметить все сообщения в чате как прочитанные
  Future<void> markAllMessagesAsRead(String chatId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      // Получаем все непрочитанные сообщения от других пользователей
      final unreadMessages = await _firestore
          .collection(_directMessagesPath)
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      // Обновляем каждое сообщение
      final batch = _firestore.batch();
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      await batch.commit();
      print('ChatRouletteService: ${unreadMessages.docs.length} сообщений отмечено как прочитанные');
    } catch (e) {
      print('ChatRouletteService: Ошибка при массовом обновлении статуса прочтения: $e');
    }
  }

  /// Завершить матч (выйти из чата) - НЕ удаляет чат!
  Future<void> endMatch() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      // Используем Cloud Function для завершения матча
      final callable = FirebaseFunctions.instance.httpsCallable('endMatch');
      await callable.call();
    } catch (e) {
      print('Ошибка при завершении матча через Cloud Function: $e');
      // Fallback на прямое удаление матча (БЕЗ удаления чата!)
      final match = await getCurrentMatch();
      if (match != null) {
        final partnerId = match['partnerId'] as String;
        
        await _rtdb.ref('$_matchesPath/$userId').remove();
        await _rtdb.ref('$_matchesPath/$partnerId').remove();
        await _rtdb.ref('$_queuePath/$userId/status').set('searching');
        await _rtdb.ref('$_queuePath/$partnerId/status').set('searching');
        // НЕ удаляем чат! Он остается для продолжения общения
      }
    }
  }

  /// Найти следующего собеседника
  Future<void> findNextPartner() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      // Завершаем матч напрямую (БЕЗ Cloud Function!)
      final match = await getCurrentMatch();
      if (match != null) {
        final partnerId = match['partnerId'] as String;
        
        // Удаляем матчи из RTDB
        await _rtdb.ref('$_matchesPath/$userId').remove();
        await _rtdb.ref('$_matchesPath/$partnerId').remove();
        
        // Сбрасываем статусы на searching
        await _rtdb.ref('$_queuePath/$userId/status').set('searching');
        await _rtdb.ref('$_queuePath/$partnerId/status').set('searching');
        
        // НЕ удаляем чат! Он остается для продолжения общения
      }
    } catch (e) {
      print('Ошибка при завершении матча: $e');
      // Fallback - просто сбрасываем статус
      await _rtdb.ref('$_queuePath/$userId/status').set('searching');
    }
  }

  /// Получить список доступных пользователей в очереди
  Future<List<Map<String, dynamic>>> getAvailableUsers() async {
    final snapshot = await _rtdb.ref(_queuePath).get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    
    if (data == null) return [];

    final userId = _currentUserId;
    final users = <Map<String, dynamic>>[];

     data.forEach((key, value) {
       if (key != userId && value is Map) {
         try {
           final userData = Map<String, dynamic>.from(value);
           if (userData['status'] == 'searching') {
             users.add({
               'uid': key,
               ...userData,
             });
           }
         } catch (e) {
           print('Ошибка при обработке пользователя $key: $e');
         }
       }
     });

    return users;
  }

  /// Проверить совместимость пользователей
  bool areUsersCompatible(Map<String, dynamic> user1, Map<String, dynamic> user2) {
    // Базовая логика совместимости
    // Можно расширить более сложными алгоритмами
    
    final age1 = user1['age'] as int;
    final age2 = user2['age'] as int;
    
    // Проверка возраста (разница не более 10 лет)
    if ((age1 - age2).abs() > 10) return false;
    
    // Проверка общих интересов
    final interests1 = user1['interests'] as List<String>;
    final interests2 = user2['interests'] as List<String>;
    final commonInterests = interests1.where((interest) => interests2.contains(interest)).length;
    
    // Если есть хотя бы один общий интерес, считаем совместимыми
    return commonInterests > 0;
  }
}
