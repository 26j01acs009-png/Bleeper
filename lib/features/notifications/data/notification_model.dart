class NotificationModel {
  final String id;
  final String actorId;
  final String actorUsername;
  final String? actorDisplayName;
  final String? actorAvatarUrl;
  final String type;
  final String? bleepId;
  final String? bleepContent;
  final String? bleepImageUrl;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.actorId,
    required this.actorUsername,
    this.actorDisplayName,
    this.actorAvatarUrl,
    required this.type,
    this.bleepId,
    this.bleepContent,
    this.bleepImageUrl,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'] as Map<String, dynamic>?;
    final bleep = json['bleeps'] as Map<String, dynamic>?;

    return NotificationModel(
      id: json['id'] as String,
      actorId: json['actor_id'] as String,
      actorUsername: profiles?['username'] as String? ?? 'unknown',
      actorDisplayName: profiles?['display_name'] as String?,
      actorAvatarUrl: profiles?['avatar_url'] as String?,
      type: json['type'] as String,
      bleepId: json['bleep_id'] as String?,
      bleepContent: bleep?['content'] as String?,
      bleepImageUrl: bleep?['media_url'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
