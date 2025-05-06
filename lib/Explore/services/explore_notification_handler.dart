import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Services/Notification/notification_handler.dart';
import 'explore_notification_settings.dart';

class ExploreNotificationHandler {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationHandler _notificationHandler = NotificationHandler();
  final String _collectionName = 'exploreNotifications';

  Future<void> sendNotification({
    String? theEmail,
    required String title,
    required String message,
    List<String>? selectedUserIds,
    bool sendToAll = false,
  }) async {
    try {
      List<String> recipientIds = [];

      if (sendToAll) {
        final usersSnapshot = await _firestore.collection('users').get();
        recipientIds = usersSnapshot.docs.map((doc) => doc.id).toList();
      } else if (selectedUserIds != null) {
        recipientIds = selectedUserIds;
      } else if (theEmail != null) {
        final userQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: theEmail)
            .get();

        if (userQuery.docs.isNotEmpty) {
          recipientIds = [userQuery.docs.first.id];
        }
      }

      // Send notification to each recipient
      for (String recipientId in recipientIds) {
        // Get recipient's notification settings
        final recipientDoc = await _firestore.collection('users').doc(recipientId).get();
        final recipientData = recipientDoc.data();
        
        if (recipientData != null) {
          bool shouldSendNotification = true;
          
          // Check recipient's notification settings based on notification type
          if (title.contains('Like')) {
            shouldSendNotification = await ExploreNotificationSettings.getLikeNotifications();
          } else if (title.contains('Comment')) {
            shouldSendNotification = await ExploreNotificationSettings.getCommentNotifications();
          } else if (title.contains('Follower')) {
            shouldSendNotification = await ExploreNotificationSettings.getFollowNotifications();
          } else if (title.contains('Project')) {
            shouldSendNotification = await ExploreNotificationSettings.getProjectNotifications();
          }

          if (shouldSendNotification) {
            // Send to main notifications collection
            await _notificationHandler.sendNotification(
              theEmail: recipientData['email'],
              title: title,
              message: message,
            );

            // Store in explore notifications collection
            await _firestore.collection(_collectionName).add({
              'recipientId': recipientId,
              'title': title,
              'body': message,
              'isRead': false,
              'createdAt': FieldValue.serverTimestamp(),
            });

            print('✅ Notification sent to: ${recipientData['email']}');
          } else {
            print('❌ Notifications disabled for recipient: ${recipientData['email']}');
          }
        }
      }
    } catch (e) {
      print('Error sending explore notification: $e');
      rethrow;
    }
  }
} 