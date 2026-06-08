class Discussion {
  final String id;
  final String bleepId;
  final String userId;
  final String? parentId;
  final String content;
  final DateTime createdAt;
  final String? username;
  final String? displayName;
  final String? avatarUrl;

  Discussion({
    required this.id,
    required this.bleepId,
    required this.userId,
    this.parentId,
    required this.content,
    required this.createdAt,
    this.username,
    this.displayName,
    this.avatarUrl,
  });

  factory Discussion.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'] as Map<String, dynamic>?;
    return Discussion(
      id: json['id'] as String,
      bleepId: json['bleep_id'] as String,
      userId: json['user_id'] as String,
      parentId: json['parent_id'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      username: profiles?['username'] as String?,
      displayName: profiles?['display_name'] as String?,
      avatarUrl: profiles?['avatar_url'] as String?,
    );
  }
}
