import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../shared/widgets.dart';
import '../../../../core/supabase/auth_provider.dart';
import '../../../../features/notifications/data/notification_provider.dart';
import '../../../../features/notifications/data/notification_model.dart';
import '../../../../features/home/domain/entities/bleep.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userId = context.read<AuthProvider>().user?.id;
        if (userId != null) {
          context.read<NotificationProvider>().fetchNotifications(userId);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          final allNotifications = notificationProvider.notifications;
          final mentionNotifications =
              allNotifications.where((n) => n.type == 'mention').toList();
          final visibleNotifications =
              _tabController.index == 0 ? allNotifications : mentionNotifications;

          return Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.screenPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('Updates', style: context.h1),
                    TextButton(
                      onPressed: notificationProvider.markingAllAsRead
                          ? null
                          : () {
                              final userId =
                                  context.read<AuthProvider>().user?.id;
                              if (userId != null) {
                                notificationProvider.markAllAsRead(userId);
                              }
                            },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Mark all as read',
                        style: context.bodyMedium.copyWith(
                          color: context.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.spacingMd),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.screenPadding),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: context.textPrimary,
                  unselectedLabelColor: context.textSecondary,
                  labelStyle: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: context.bodyMedium,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(color: context.accent, width: 2),
                    insets: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Mentions'),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 0.5, color: context.divider),
              Expanded(
                child: _buildBody(
                  context,
                  visibleNotifications,
                  notificationProvider.isLoading,
                  notificationProvider.error,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<NotificationModel> notifications,
    bool isLoading,
    String? error,
  ) {
    if (isLoading && notifications.isEmpty) {
      return const Center(child: BleeperLoadingIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(context.spacingXl),
          child: Text(
            'Failed to load notifications\n$error',
            style: context.bodyMedium.copyWith(color: context.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(context.spacingXl),
          child: Text(
            _tabController.index == 0
                ? 'You have no notifications yet'
                : 'You have not been mentioned yet',
            style: context.bodyMedium.copyWith(color: context.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final type = _getNotificationType(notification.type);
        final message = _getNotificationMessage(notification.type);

        Bleep? preview;
        if (notification.bleepId != null && notification.bleepContent != null) {
          preview = Bleep(
            id: notification.bleepId!,
            userId: notification.actorId,
            username: notification.actorUsername,
            displayName: notification.actorDisplayName,
            content: notification.bleepContent ?? '',
            mediaUrl: notification.bleepMediaUrl,
            appreciatesCount: 0,
            discussesCount: 0,
            resharesCount: 0,
            viewsCount: 0,
            isAppreciatedByMe: false,
            createdAt: notification.createdAt,
          );
        }

        return NotificationCard(
          notificationType: type,
          actorUsername: notification.actorUsername,
          actorDisplayName: notification.actorDisplayName,
          actorAvatarUrl: notification.actorAvatarUrl,
          timeAgo: _formatTimeAgo(notification.createdAt),
          message: message,
          bleepPreview: preview,
          isUnread: !notification.isRead,
        );
      },
    );
  }

  NotificationType _getNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'appreciate':
        return NotificationType.appreciate;
      case 'discuss':
        return NotificationType.discuss;
      case 'reshare':
        return NotificationType.reshare;
      case 'follow':
        return NotificationType.follow;
      case 'mention':
        return NotificationType.mention;
      default:
        return NotificationType.appreciate;
    }
  }

  String _getNotificationMessage(String type) {
    switch (type.toLowerCase()) {
      case 'appreciate':
        return 'appreciated your Bleep';
      case 'discuss':
        return 'discussed your Bleep';
      case 'reshare':
        return 'reshared your Bleep';
      case 'follow':
        return 'started following you';
      case 'mention':
        return 'mentioned you in a Bleep';
      default:
        return 'interacted with your Bleep';
    }
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
