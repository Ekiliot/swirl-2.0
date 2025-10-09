import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/chat/models/chat_message.dart';

/// Сервис для управления закрепленными сообщениями
class PinnedMessagesService {
  static const String _pinnedMessagesKey = 'pinned_messages';
  
  /// Получить все закрепленные сообщения для конкретного чата
  static Future<List<ChatMessage>> getPinnedMessages(String chatId) async {
    try {
      // На веб-платформе используем альтернативное хранение
      if (kIsWeb) {
        return _getPinnedMessagesFromWebStorage(chatId);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final String? pinnedMessagesJson = prefs.getString('${_pinnedMessagesKey}_$chatId');
      
      if (pinnedMessagesJson == null) {
        return [];
      }
      
      final List<dynamic> pinnedMessagesList = json.decode(pinnedMessagesJson);
      return pinnedMessagesList
          .map((json) => ChatMessage.fromJson(json))
          .toList();
    } catch (e) {
      print('PinnedMessagesService: Ошибка при получении закрепленных сообщений для чата $chatId: $e');
      return [];
    }
  }
  
  /// Добавить закрепленное сообщение в конкретный чат
  static Future<bool> pinMessage(String chatId, ChatMessage message) async {
    try {
      // На веб-платформе используем альтернативное хранение
      if (kIsWeb) {
        return _pinMessageToWebStorage(chatId, message);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final List<ChatMessage> pinnedMessages = await getPinnedMessages(chatId);
      
      // Проверяем, не закреплено ли уже это сообщение
      if (pinnedMessages.any((m) => m.text == message.text && m.timestamp == message.timestamp)) {
        return true; // Уже закреплено
      }
      
      // Добавляем новое закрепленное сообщение
      pinnedMessages.add(message);
      
      // Сохраняем обновленный список
      final String pinnedMessagesJson = json.encode(
        pinnedMessages.map((m) => m.toJson()).toList()
      );
      
      return await prefs.setString('${_pinnedMessagesKey}_$chatId', pinnedMessagesJson);
    } catch (e) {
      print('PinnedMessagesService: Ошибка при закреплении сообщения в чате $chatId: $e');
      return false;
    }
  }
  
  /// Открепить сообщение из конкретного чата
  static Future<bool> unpinMessage(String chatId, ChatMessage message) async {
    try {
      // На веб-платформе используем альтернативное хранение
      if (kIsWeb) {
        return _unpinMessageFromWebStorage(chatId, message);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final List<ChatMessage> pinnedMessages = await getPinnedMessages(chatId);
      
      // Удаляем сообщение из списка
      pinnedMessages.removeWhere((m) => 
        m.text == message.text && m.timestamp == message.timestamp
      );
      
      // Сохраняем обновленный список
      final String pinnedMessagesJson = json.encode(
        pinnedMessages.map((m) => m.toJson()).toList()
      );
      
      return await prefs.setString('${_pinnedMessagesKey}_$chatId', pinnedMessagesJson);
    } catch (e) {
      print('PinnedMessagesService: Ошибка при откреплении сообщения из чата $chatId: $e');
      return false;
    }
  }
  
  /// Проверить, закреплено ли сообщение в конкретном чате
  static Future<bool> isMessagePinned(String chatId, ChatMessage message) async {
    try {
      final List<ChatMessage> pinnedMessages = await getPinnedMessages(chatId);
      return pinnedMessages.any((m) => 
        m.text == message.text && m.timestamp == message.timestamp
      );
    } catch (e) {
      print('PinnedMessagesService: Ошибка при проверке закрепления сообщения в чате $chatId: $e');
      return false;
    }
  }
  
  /// Очистить все закрепленные сообщения для конкретного чата
  static Future<bool> clearAllPinnedMessages(String chatId) async {
    try {
      // На веб-платформе используем альтернативное хранение
      if (kIsWeb) {
        return _clearAllPinnedMessagesFromWebStorage(chatId);
      }
      
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove('${_pinnedMessagesKey}_$chatId');
    } catch (e) {
      print('PinnedMessagesService: Ошибка при очистке закрепленных сообщений для чата $chatId: $e');
      return false;
    }
  }

  // Веб-альтернативы для хранения в localStorage
  static Map<String, List<ChatMessage>> _webPinnedMessages = {};

  static Future<List<ChatMessage>> _getPinnedMessagesFromWebStorage(String chatId) async {
    try {
      // В веб-версии используем память как временное хранилище
      return _webPinnedMessages[chatId] ?? [];
    } catch (e) {
      print('PinnedMessagesService: Ошибка при получении закрепленных сообщений (веб) для чата $chatId: $e');
      return [];
    }
  }

  static Future<bool> _pinMessageToWebStorage(String chatId, ChatMessage message) async {
    try {
      // Проверяем, не закреплено ли уже это сообщение
      final pinnedMessages = _webPinnedMessages[chatId] ?? [];
      if (pinnedMessages.any((m) => m.text == message.text && m.timestamp == message.timestamp)) {
        return true; // Уже закреплено
      }
      
      // Добавляем новое закрепленное сообщение
      pinnedMessages.add(message);
      _webPinnedMessages[chatId] = pinnedMessages;
      return true;
    } catch (e) {
      print('PinnedMessagesService: Ошибка при закреплении сообщения (веб) в чате $chatId: $e');
      return false;
    }
  }

  static Future<bool> _unpinMessageFromWebStorage(String chatId, ChatMessage message) async {
    try {
      // Удаляем сообщение из списка
      final pinnedMessages = _webPinnedMessages[chatId] ?? [];
      pinnedMessages.removeWhere((m) => 
        m.text == message.text && m.timestamp == message.timestamp
      );
      _webPinnedMessages[chatId] = pinnedMessages;
      return true;
    } catch (e) {
      print('PinnedMessagesService: Ошибка при откреплении сообщения (веб) из чата $chatId: $e');
      return false;
    }
  }

  static Future<bool> _clearAllPinnedMessagesFromWebStorage(String chatId) async {
    try {
      _webPinnedMessages[chatId] = [];
      return true;
    } catch (e) {
      print('PinnedMessagesService: Ошибка при очистке закрепленных сообщений (веб) для чата $chatId: $e');
      return false;
    }
  }
}
