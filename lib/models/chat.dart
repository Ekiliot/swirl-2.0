class Chat {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String avatarUrl;
  final bool isOnline;
  final bool isPinned;
  final int unreadCount;

  Chat({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.avatarUrl,
    this.isOnline = false,
    this.isPinned = false,
    this.unreadCount = 0,
  });

  Chat copyWith({
    String? id,
    String? name,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? avatarUrl,
    bool? isOnline,
    bool? isPinned,
    int? unreadCount,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      isPinned: isPinned ?? this.isPinned,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}