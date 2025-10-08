import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static const String _directMessagesPath = 'direct_messages';

  /// Получить список чатов пользователя
  Stream<List<Map<String, dynamic>>> getUserChats() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      print('ChatService: Пользователь не авторизован');
      return Stream.value([]);
    }

    print('ChatService: Ищем чаты для пользователя $userId');
    
    return _firestore
        .collection(_directMessagesPath)
        .where('participants', arrayContains: userId)
        .snapshots()
        .asyncMap((snapshot) async {
          print('ChatService: Найдено ${snapshot.docs.length} чатов');
          
          final List<Map<String, dynamic>> validChats = [];
          
          // Проверяем каждый чат на наличие сообщений
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final chatId = doc.id;
            
            // Проверяем есть ли сообщения в чате
            final messagesSnapshot = await _firestore
                .collection(_directMessagesPath)
                .doc(chatId)
                .collection('messages')
                .limit(1)
                .get();
            
            // Добавляем чат только если в нем есть сообщения
            if (messagesSnapshot.docs.isNotEmpty) {
              print('ChatService: Чат ${chatId} содержит сообщения');
              validChats.add({
                'id': chatId,
                ...data,
              });
            } else {
              print('ChatService: Чат ${chatId} пустой, пропускаем');
            }
          }
          
          // Сортируем по времени последнего сообщения
          validChats.sort((a, b) {
            final timeA = a['lastMessageTime'];
            final timeB = b['lastMessageTime'];
            
            if (timeA == null && timeB == null) return 0;
            if (timeA == null) return 1;
            if (timeB == null) return -1;
            
            DateTime dateTimeA, dateTimeB;
            if (timeA is Timestamp) {
              dateTimeA = timeA.toDate();
            } else if (timeA is DateTime) {
              dateTimeA = timeA;
            } else {
              return 1;
            }
            
            if (timeB is Timestamp) {
              dateTimeB = timeB.toDate();
            } else if (timeB is DateTime) {
              dateTimeB = timeB;
            } else {
              return -1;
            }
            
            return dateTimeB.compareTo(dateTimeA); // Новые сверху
          });
          
          print('ChatService: Возвращаем ${validChats.length} валидных чатов (${snapshot.docs.length - validChats.length} пустых отфильтровано)');
          return validChats;
        });
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
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw StateError('Пользователь не авторизован');

    final messageData = {
      'text': text,
      'senderId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'messageType': 'text',
    };

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

  /// Отметить сообщение как прочитанное
  Future<void> markMessageAsRead(String chatId, String messageId) async {
    try {
      await _firestore
          .collection(_directMessagesPath)
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});
      
      print('ChatService: Сообщение $messageId отмечено как прочитанное');
    } catch (e) {
      print('ChatService: Ошибка при обновлении статуса прочтения: $e');
    }
  }

  /// Отметить все сообщения в чате как прочитанные
  Future<void> markAllMessagesAsRead(String chatId) async {
    final userId = _auth.currentUser?.uid;
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
      print('ChatService: ${unreadMessages.docs.length} сообщений отмечено как прочитанные');
    } catch (e) {
      print('ChatService: Ошибка при массовом обновлении статуса прочтения: $e');
    }
  }

  /// Получить информацию о собеседнике
  Map<String, dynamic>? getPartnerInfo(Map<String, dynamic> chatData) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      print('ChatService: Пользователь не авторизован в getPartnerInfo');
      return null;
    }

    print('ChatService: getPartnerInfo для пользователя $userId');
    print('ChatService: Данные чата: $chatData');

    final participants = chatData['participants'] as List<dynamic>?;
    if (participants == null) {
      print('ChatService: participants is null');
      return null;
    }

    print('ChatService: participants: $participants');

    // Находим ID собеседника
    String? partnerId;
    for (final participant in participants) {
      if (participant != userId) {
        partnerId = participant as String;
        break;
      }
    }

    print('ChatService: partnerId: $partnerId');

    if (partnerId == null) {
      print('ChatService: partnerId is null');
      return null;
    }

    final result = {
      'id': partnerId,
      'name': chatData['participantNames']?[partnerId] ?? 'Неизвестно',
      'avatar': chatData['participantAvatars']?[partnerId] ?? '?',
    };
    
    print('ChatService: Результат getPartnerInfo: $result');
    return result;
  }

  /// Удалить чат
  Future<void> deleteChat(String chatId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw StateError('Пользователь не авторизован');

    // Получаем данные чата для проверки прав
    final chatDoc = await _firestore.collection(_directMessagesPath).doc(chatId).get();
    if (!chatDoc.exists) return;

    final chatData = chatDoc.data()!;
    if (!chatData['participants'].contains(userId)) {
      throw StateError('Нет доступа к чату');
    }

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
  }

  /// Ручная очистка пустых чатов (для отладки)
  Future<int> cleanupEmptyChats() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('ChatService: Пользователь не авторизован');
        return 0;
      }

      print('ChatService: Запуск ручной очистки пустых чатов...');
      
      // Получаем все чаты пользователя
      final chatsSnapshot = await _firestore
          .collection(_directMessagesPath)
          .where('participants', arrayContains: userId)
          .get();
      
      final List<String> emptyChats = [];
      
      // Проверяем каждый чат на наличие сообщений
      for (final doc in chatsSnapshot.docs) {
        final chatId = doc.id;
        final messagesSnapshot = await _firestore
            .collection(_directMessagesPath)
            .doc(chatId)
            .collection('messages')
            .limit(1)
            .get();
        
        if (messagesSnapshot.docs.isEmpty) {
          emptyChats.add(chatId);
          print('ChatService: Найден пустой чат: $chatId');
        }
      }
      
      // Удаляем пустые чаты
      if (emptyChats.isNotEmpty) {
        print('ChatService: Удаляем ${emptyChats.length} пустых чатов...');
        
        final batch = _firestore.batch();
        for (final chatId in emptyChats) {
          final chatRef = _firestore.collection(_directMessagesPath).doc(chatId);
          batch.delete(chatRef);
        }
        
        await batch.commit();
        print('ChatService: Успешно удалено ${emptyChats.length} пустых чатов');
      } else {
        print('ChatService: Пустые чаты не найдены');
      }
      
      return emptyChats.length;
    } catch (e) {
      print('ChatService: Ошибка при очистке пустых чатов: $e');
      return 0;
    }
  }
}
