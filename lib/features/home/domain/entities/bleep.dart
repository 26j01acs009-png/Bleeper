class Bleep {
  final String id;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String? name;
  String? get displayName => name;
  final String content;
  final String? imageUrl;
  final int appreciatesCount;
  final int discussesCount;
  final int resharesCount;
  final int viewsCount;
  final bool isAppreciatedByMe;
  final bool isResharedByMe;
  final DateTime createdAt;
  final String? visibility;
  final String? replyPermission;
  final String? mediaUrl;

  Bleep({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.name,
    required this.content,
    this.imageUrl,
    this.appreciatesCount = 0,
    this.discussesCount = 0,
    this.resharesCount = 0,
    this.viewsCount = 0,
    this.isAppreciatedByMe = false,
    this.isResharedByMe = false,
    required this.createdAt,
    this.visibility,
    this.replyPermission,
    this.mediaUrl,
  });

  factory Bleep.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'] as Map<String, dynamic>?;
    return Bleep(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      username: profiles?['username'] as String? ?? json['username'] as String? ?? 'anonymous',
      avatarUrl: profiles?['avatar_url'] as String? ?? json['avatar_url'] as String?,
      name: profiles?['display_name'] as String? ?? json['name'] as String?,
      content: json['content'] as String? ?? '',
      imageUrl: json['media_url'] as String?,
      mediaUrl: json['media_url'] as String?,
      appreciatesCount: json['appreciates_count'] as int? ?? 0,
      discussesCount: json['discussions_count'] as int? ?? 0,
      resharesCount: json['reshares_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      isAppreciatedByMe: json['is_appreciated_by_me'] as bool? ?? false,
      isResharedByMe: json['is_reshared_by_me'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      visibility: json['visibility'] as String?,
      replyPermission: json['reply_permission'] as String?,
    );
  }

  Bleep copyWith({
    String? id,
    String? userId,
    String? username,
    String? avatarUrl,
    String? name,
    String? content,
    String? imageUrl,
    String? mediaUrl,
    int? appreciatesCount,
    int? discussesCount,
    int? resharesCount,
    int? viewsCount,
    bool? isAppreciatedByMe,
    bool? isResharedByMe,
    DateTime? createdAt,
    String? visibility,
    String? replyPermission,
  }) {
    return Bleep(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      name: name ?? this.name,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      appreciatesCount: appreciatesCount ?? this.appreciatesCount,
      discussesCount: discussesCount ?? this.discussesCount,
      resharesCount: resharesCount ?? this.resharesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      isAppreciatedByMe: isAppreciatedByMe ?? this.isAppreciatedByMe,
      isResharedByMe: isResharedByMe ?? this.isResharedByMe,
      createdAt: createdAt ?? this.createdAt,
      visibility: visibility ?? this.visibility,
      replyPermission: replyPermission ?? this.replyPermission,
    );
  }
}
