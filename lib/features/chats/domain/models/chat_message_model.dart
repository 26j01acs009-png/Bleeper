class ChatMessage {
  final String text;
  final String? timeAgo;
  final bool isMe;
  final bool isRead;

  const ChatMessage({
    required this.text,
    this.timeAgo,
    this.isMe = false,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['content'] as String? ?? json['text'] as String,
      timeAgo: json['time_ago'] as String? ?? json['timeAgo'] as String?,
      isMe: json['is_me'] as bool? ?? json['isMe'] as bool? ?? false,
      isRead: json['is_read'] as bool? ?? json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'time_ago': timeAgo,
      'is_me': isMe,
      'is_read': isRead,
    };
  }
}

class ChatRoom {
  final String chatId;
  final String name;
  final String? avatarUrl;
  final bool isOnline;
  final List<ChatMessage> messages;

  ChatRoom({
    required this.chatId,
    required this.name,
    this.avatarUrl,
    this.isOnline = false,
    required this.messages,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    final messagesList = json['messages'] as List<dynamic>? ?? [];
    return ChatRoom(
      chatId: json['chat_id'] as String? ?? json['chatId'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      isOnline: json['is_online'] as bool? ?? json['isOnline'] as bool? ?? false,
      messages: messagesList
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'name': name,
      'avatar_url': avatarUrl,
      'is_online': isOnline,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }
}
