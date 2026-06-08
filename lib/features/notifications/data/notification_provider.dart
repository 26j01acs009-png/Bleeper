import 'package:flutter/foundation.dart';
import 'package:bleeper/features/notifications/data/notification_repository.dart';
import 'package:bleeper/features/notifications/data/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;

  NotificationProvider(this._repository);

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _markingAllAsRead = false;
  bool get markingAllAsRead => _markingAllAsRead;

  Future<void> fetchNotifications(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _repository.getNotifications(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead(String userId) async {
    _markingAllAsRead = true;
    notifyListeners();

    try {
      await _repository.markAllAsRead(userId);
      _notifications = _notifications
          .map((n) => _markAsRead(n))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _markingAllAsRead = false;
      notifyListeners();
    }
  }

  static NotificationModel _markAsRead(NotificationModel n) {
    return NotificationModel(
      id: n.id,
      recipientId: n.recipientId,
      actorId: n.actorId,
      actorUsername: n.actorUsername,
      actorDisplayName: n.actorDisplayName,
      actorAvatarUrl: n.actorAvatarUrl,
      type: n.type,
      bleepId: n.bleepId,
      bleepContent: n.bleepContent,
      bleepMediaUrl: n.bleepMediaUrl,
      isRead: true,
      createdAt: n.createdAt,
    );
  }
}
