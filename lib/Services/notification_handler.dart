import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationHandler {
  Future<void> sendNotification({
    String? theEmail,
    required String title,
    required String message,
    bool toAll = false,
    List<String>? selectedUsers,
  }) async {
    try {
      List<String> recipientIds = [];

      if (toAll) {
        // Fetch all users
        final allUsersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
        recipientIds =
            allUsersSnapshot.docs.map((doc) => doc.id).toList();
      } else if (selectedUsers != null && selectedUsers.isNotEmpty) {
        // Fetch users by selected emails
        final selectedSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', whereIn: selectedUsers)
            .get();
        recipientIds =
            selectedSnapshot.docs.map((doc) => doc.id).toList();
      } else if (theEmail != null) {
        // Fetch specific recruiter by email
        final recruiterSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: theEmail)
            .limit(1)
            .get();

        if (recruiterSnapshot.docs.isEmpty) {
          throw Exception('Recruiter not found: $theEmail');
        }
        recipientIds = [recruiterSnapshot.docs.first.id];
      } else {
        throw Exception('No valid recipient defined');
      }

      // Send notification to all resolved recipient IDs
      for (final id in recipientIds) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'recipientId': id,
          'title': title,
          'body': message,
          'isRead': false,
          'createdAt': Timestamp.now(),
        });
      }

      print('Notification sent to ${recipientIds.length} user(s)');
    } catch (e) {
      print('Error sending notification: $e');
      rethrow;
    }
  }
}
