class ChatMessage {
  final String text;
  final bool isMine;
  final DateTime timestamp;
  final MessageType type;
  final String? attachmentUrl;
  final bool isRead;

  ChatMessage({
    required this.text,
    required this.isMine,
    required this.timestamp,
    this.type = MessageType.text,
    this.attachmentUrl,
    this.isRead = false,
  });

  ChatMessage copyWith({
    String? text,
    bool? isMine,
    DateTime? timestamp,
    MessageType? type,
    String? attachmentUrl,
    bool? isRead,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isMine: isMine ?? this.isMine,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      isRead: isRead ?? this.isRead,
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
