import 'package:shared_preferences/shared_preferences.dart';

class ExploreNotificationSettings {
  static const String _likeNotificationsKey = 'explore_like_notifications';
  static const String _commentNotificationsKey = 'explore_comment_notifications';
  static const String _followNotificationsKey = 'explore_follow_notifications';
  static const String _projectNotificationsKey = 'explore_project_notifications';

  static Future<bool> getLikeNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_likeNotificationsKey) ?? true;
  }

  static Future<bool> getCommentNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_commentNotificationsKey) ?? true;
  }

  static Future<bool> getFollowNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_followNotificationsKey) ?? true;
  }

  static Future<bool> getProjectNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_projectNotificationsKey) ?? true;
  }

  static Future<void> setLikeNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_likeNotificationsKey, value);
  }

  static Future<void> setCommentNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_commentNotificationsKey, value);
  }

  static Future<void> setFollowNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_followNotificationsKey, value);
  }

  static Future<void> setProjectNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_projectNotificationsKey, value);
  }
} 