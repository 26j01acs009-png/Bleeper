class Bleep {
  final String id;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String? displayName;
  final String content;
  final String? mediaUrl;
  final String? circleId;
  final String? circleName;
  final String? circleSlug;
  final String visibility;
  final String replyPermission;
  final String resharePermission;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int appreciatesCount;
  final int discussesCount;
  final int resharesCount;
  final int viewsCount;
  final bool isAppreciatedByMe;
  final bool isResharedByMe;

  Bleep({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.displayName,
    required this.content,
    this.mediaUrl,
    this.circleId,
    this.circleName,
    this.circleSlug,
    this.visibility = 'public',
    this.replyPermission = 'everyone',
    this.resharePermission = 'everyone',
    required this.createdAt,
    this.updatedAt,
    this.appreciatesCount = 0,
    this.discussesCount = 0,
    this.resharesCount = 0,
    this.viewsCount = 0,
    this.isAppreciatedByMe = false,
    this.isResharedByMe = false,
  });

  factory Bleep.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'] as Map<String, dynamic>?;
    final stats = json['bleep_stats'] as Map<String, dynamic>?;

    return Bleep(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      username: profiles?['username'] as String? ??
          json['author_username'] as String? ??
          json['username'] as String? ??
          'anonymous',
      avatarUrl: profiles?['avatar_url'] as String? ??
          json['author_avatar_url'] as String? ??
          json['avatar_url'] as String?,
      displayName: profiles?['display_name'] as String? ??
          json['author_display_name'] as String? ??
          json['display_name'] as String?,
      content: json['content'] as String? ?? '',
      mediaUrl: json['media_url'] as String? ?? json['image_url'] as String?,
      circleId: json['circle_id'] as String?,
      circleName: json['circle_name'] as String?,
      circleSlug: json['circle_slug'] as String?,
      visibility: json['visibility'] as String? ?? 'public',
      replyPermission: json['reply_permission'] as String? ?? 'everyone',
      resharePermission: json['reshare_permission'] as String? ?? 'everyone',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      appreciatesCount: stats?['appreciates_count'] as int? ?? json['appreciates_count'] as int? ?? 0,
      discussesCount: stats?['discusses_count'] as int? ?? json['discusses_count'] as int? ?? 0,
      resharesCount: stats?['reshares_count'] as int? ?? json['reshares_count'] as int? ?? 0,
      viewsCount: stats?['views_count'] as int? ?? json['views_count'] as int? ?? 0,
      isAppreciatedByMe: json['is_appreciated_by_me'] as bool? ??
          json['appreciated'] as bool? ??
          false,
      isResharedByMe: json['is_reshared_by_me'] as bool? ??
          json['reshared'] as bool? ??
          false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'content': content,
      'media_url': mediaUrl,
      'circle_id': circleId,
      'visibility': visibility,
      'reply_permission': replyPermission,
      'reshare_permission': resharePermission,
    };
  }

  Bleep copyWith({
    String? id,
    String? userId,
    String? username,
    String? avatarUrl,
    String? displayName,
    String? content,
    String? mediaUrl,
    String? circleId,
    String? circleName,
    String? circleSlug,
    String? visibility,
    String? replyPermission,
    String? resharePermission,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? appreciatesCount,
    int? discussesCount,
    int? resharesCount,
    int? viewsCount,
    bool? isAppreciatedByMe,
    bool? isResharedByMe,
  }) {
    return Bleep(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      displayName: displayName ?? this.displayName,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      circleId: circleId ?? this.circleId,
      circleName: circleName ?? this.circleName,
      circleSlug: circleSlug ?? this.circleSlug,
      visibility: visibility ?? this.visibility,
      replyPermission: replyPermission ?? this.replyPermission,
      resharePermission: resharePermission ?? this.resharePermission,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      appreciatesCount: appreciatesCount ?? this.appreciatesCount,
      discussesCount: discussesCount ?? this.discussesCount,
      resharesCount: resharesCount ?? this.resharesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      isAppreciatedByMe: isAppreciatedByMe ?? this.isAppreciatedByMe,
      isResharedByMe: isResharedByMe ?? this.isResharedByMe,
    );
  }
}
