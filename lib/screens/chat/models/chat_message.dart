import 'dart:typed_data';

class ChatMessage {
  final String text;
  final bool isMine;
  final DateTime timestamp;
  final MessageType type;
  final String? attachmentUrl;
  final bool isRead;
  final bool isPinned; // закреплено ли сообщение
  final bool isEdited; // редактировано ли сообщение
  final String? messageId; // ID сообщения для операций
  
  // Поля для ответов
  final String? replyToMessageId; // ID сообщения, на которое отвечаем
  final String? replyToText; // Текст сообщения, на которое отвечаем
  final String? replyToSenderId; // ID отправителя сообщения, на которое отвечаем
  
  // Медиа поля
  final String? mediaUrl;
  final String? mediaType; // 'photo' или 'video'
  final int? mediaSize;
  final int? mediaDuration; // для видео в миллисекундах
  final String? localPath; // локальный путь к файлу
  final bool isUploading;
  final bool hasError;
  final String? thumbnail; // путь к миниатюре
  final Uint8List? thumbnailData; // данные миниатюры

  ChatMessage({
    required this.text,
    required this.isMine,
    required this.timestamp,
    this.type = MessageType.text,
    this.attachmentUrl,
    this.isRead = false,
    this.isPinned = false,
    this.isEdited = false,
    this.messageId,
    this.replyToMessageId,
    this.replyToText,
    this.replyToSenderId,
    this.mediaUrl,
    this.mediaType,
    this.mediaSize,
    this.mediaDuration,
    this.localPath,
    this.isUploading = false,
    this.hasError = false,
    this.thumbnail,
    this.thumbnailData,
  });

  ChatMessage copyWith({
    String? text,
    bool? isMine,
    DateTime? timestamp,
    MessageType? type,
    String? attachmentUrl,
    bool? isRead,
    bool? isPinned,
    bool? isEdited,
    String? messageId,
    String? replyToMessageId,
    String? replyToText,
    String? replyToSenderId,
    String? mediaUrl,
    String? mediaType,
    int? mediaSize,
    int? mediaDuration,
    String? localPath,
    bool? isUploading,
    bool? hasError,
    String? thumbnail,
    Uint8List? thumbnailData,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isMine: isMine ?? this.isMine,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      isRead: isRead ?? this.isRead,
      isPinned: isPinned ?? this.isPinned,
      isEdited: isEdited ?? this.isEdited,
      messageId: messageId ?? this.messageId,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToText: replyToText ?? this.replyToText,
      replyToSenderId: replyToSenderId ?? this.replyToSenderId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      mediaSize: mediaSize ?? this.mediaSize,
      mediaDuration: mediaDuration ?? this.mediaDuration,
      localPath: localPath ?? this.localPath,
      isUploading: isUploading ?? this.isUploading,
      hasError: hasError ?? this.hasError,
      thumbnail: thumbnail ?? this.thumbnail,
      thumbnailData: thumbnailData ?? this.thumbnailData,
    );
  }

  /// Преобразование в JSON для локального хранения
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isMine': isMine,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type.index,
      'attachmentUrl': attachmentUrl,
      'isRead': isRead,
      'isPinned': isPinned,
      'isEdited': isEdited,
      'messageId': messageId,
      'replyToMessageId': replyToMessageId,
      'replyToText': replyToText,
      'replyToSenderId': replyToSenderId,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'mediaSize': mediaSize,
      'mediaDuration': mediaDuration,
      'localPath': localPath,
      'isUploading': isUploading,
      'hasError': hasError,
      'thumbnail': thumbnail,
      // thumbnailData не сохраняем в JSON, так как это Uint8List
    };
  }

  /// Создание из JSON для локального хранения
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] ?? '',
      isMine: json['isMine'] ?? false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      type: MessageType.values[json['type'] ?? 0],
      attachmentUrl: json['attachmentUrl'],
      isRead: json['isRead'] ?? false,
      isPinned: json['isPinned'] ?? false,
      isEdited: json['isEdited'] ?? false,
      messageId: json['messageId'],
      replyToMessageId: json['replyToMessageId'],
      replyToText: json['replyToText'],
      replyToSenderId: json['replyToSenderId'],
      mediaUrl: json['mediaUrl'],
      mediaType: json['mediaType'],
      mediaSize: json['mediaSize'],
      mediaDuration: json['mediaDuration'],
      localPath: json['localPath'],
      isUploading: json['isUploading'] ?? false,
      hasError: json['hasError'] ?? false,
      thumbnail: json['thumbnail'],
      // thumbnailData не восстанавливаем из JSON
    );
  }
}

enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  location,
  sticker,
}
