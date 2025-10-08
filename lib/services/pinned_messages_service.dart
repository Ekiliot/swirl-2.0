import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/chat/models/chat_message.dart';

/// Сервис для управления закрепленными сообщениями
class PinnedMessagesService {
  static const String _pinnedMessagesKey = 'pinned_messages';
  
  /// Получить все закрепленные сообщения
  static Future<List<ChatMessage>> getPinnedMessages() async {
    try {
      // На веб-платформе используем альтернативное хранение
      if (kIsWeb) {
        return _getPinnedMessagesFromWebStorage();
      }
      
      final prefs = await SharedPreferences.getInstance();
      final String? pinnedMessagesJson = prefs.getString(_pinnedMessagesKey);
      
      if (pinnedMessagesJson == null) {
        return [];
      }
      
      final List<dynamic> pinnedMessagesList = json.decode(pinnedMessagesJson);
      return pinnedMessagesList
          .map((json) => ChatMessage.fromJson(json))
          .toList();
    } catch (e) {
      print('PinnedMessagesService: Ошибка при получении закрепленных сообщений: $e');
      return [];
    }
  }
  
  /// Добавить закрепленное сообщение
  static Future<bool> pinMessage(ChatMessage message) async {
    try {
      // На веб-платформе используем альтернативное хранение
      if (kIsWeb) {
        return _pinMessageToWebStorage(message);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final List<ChatMessage> pinnedMessages = await getPinnedMessages();
      
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
      
      return await prefs.setString(_pinnedMessagesKey, pinnedMessagesJson);
    } catch (e) {
      print('PinnedMessagesService: Ошибка при закреплении сообщения: $e');
      return false;
    }
  }
  
  /// Открепить сообщение
  static Future<bool> unpinMessage(ChatMessage message) async {
    try {
      // На веб-платформе используем альтернативное хранение
      if (kIsWeb) {
        return _unpinMessageFromWebStorage(message);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final List<ChatMessage> pinnedMessages = await getPinnedMessages();
      
      // Удаляем сообщение из списка
      pinnedMessages.removeWhere((m) => 
        m.text == message.text && m.timestamp == message.timestamp
      );
      
      // Сохраняем обновленный список
      final String pinnedMessagesJson = json.encode(
        pinnedMessages.map((m) => m.toJson()).toList()
      );
      
      return await prefs.setString(_pinnedMessagesKey, pinnedMessagesJson);
    } catch (e) {
      print('PinnedMessagesService: Ошибка при откреплении сообщения: $e');
      return false;
    }
  }
  
  /// Проверить, закреплено ли сообщение
  static Future<bool> isMessagePinned(ChatMessage message) async {
    try {
      final List<ChatMessage> pinnedMessages = await getPinnedMessages();
      return pinnedMessages.any((m) => 
        m.text == message.text && m.timestamp == message.timestamp
      );
    } catch (e) {
      print('PinnedMessagesService: Ошибка при проверке закрепления сообщения: $e');
      return false;
    }
  }
  
  /// Очистить все закрепленные сообщения
  static Future<bool> clearAllPinnedMessages() async {
    try {
      // На веб-платформе используем альтернативное хранение
      if (kIsWeb) {
        return _clearAllPinnedMessagesFromWebStorage();
      }
      
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_pinnedMessagesKey);
    } catch (e) {
      print('PinnedMessagesService: Ошибка при очистке закрепленных сообщений: $e');
      return false;
    }
  }

  // Веб-альтернативы для хранения в localStorage
  static List<ChatMessage> _webPinnedMessages = [];

  static Future<List<ChatMessage>> _getPinnedMessagesFromWebStorage() async {
    try {
      // В веб-версии используем память как временное хранилище
      return _webPinnedMessages;
    } catch (e) {
      print('PinnedMessagesService: Ошибка при получении закрепленных сообщений (веб): $e');
      return [];
    }
  }

  static Future<bool> _pinMessageToWebStorage(ChatMessage message) async {
    try {
      // Проверяем, не закреплено ли уже это сообщение
      if (_webPinnedMessages.any((m) => m.text == message.text && m.timestamp == message.timestamp)) {
        return true; // Уже закреплено
      }
      
      // Добавляем новое закрепленное сообщение
      _webPinnedMessages.add(message);
      return true;
    } catch (e) {
      print('PinnedMessagesService: Ошибка при закреплении сообщения (веб): $e');
      return false;
    }
  }

  static Future<bool> _unpinMessageFromWebStorage(ChatMessage message) async {
    try {
      // Удаляем сообщение из списка
      _webPinnedMessages.removeWhere((m) => 
        m.text == message.text && m.timestamp == message.timestamp
      );
      return true;
    } catch (e) {
      print('PinnedMessagesService: Ошибка при откреплении сообщения (веб): $e');
      return false;
    }
  }

  static Future<bool> _clearAllPinnedMessagesFromWebStorage() async {
    try {
      _webPinnedMessages.clear();
      return true;
    } catch (e) {
      print('PinnedMessagesService: Ошибка при очистке закрепленных сообщений (веб): $e');
      return false;
    }
  }
}
