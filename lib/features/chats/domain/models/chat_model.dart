class Chat {
  final String id;
  final String name;
  final String preview;
  final String timeAgo;
  final String? avatarUrl;
  final bool isOnline;
  final int? unreadCount;
  final bool isRead;

  const Chat({
    required this.id,
    required this.name,
    required this.preview,
    required this.timeAgo,
    this.avatarUrl,
    this.isOnline = false,
    this.unreadCount,
    this.isRead = true,
  });

  Chat copyWith({
    String? id,
    String? name,
    String? preview,
    String? timeAgo,
    String? avatarUrl,
    bool? isOnline,
    int? unreadCount,
    bool? isRead,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      preview: preview ?? this.preview,
      timeAgo: timeAgo ?? this.timeAgo,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      unreadCount: unreadCount ?? this.unreadCount,
      isRead: isRead ?? this.isRead,
    );
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as String,
      name: json['name'] as String,
      preview: json['preview'] as String,
      timeAgo: json['time_ago'] as String? ?? json['timeAgo'] as String,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      isOnline: json['is_online'] as bool? ?? json['isOnline'] as bool? ?? false,
      unreadCount: json['unread_count'] as int? ?? json['unreadCount'] as int?,
      isRead: json['is_read'] as bool? ?? json['isRead'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'preview': preview,
      'time_ago': timeAgo,
      'avatar_url': avatarUrl,
      'is_online': isOnline,
      'unread_count': unreadCount,
      'is_read': isRead,
    };
  }
}
