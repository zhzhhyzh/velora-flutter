import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'services/explore_notification_settings.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _likeNotifications = true;
  bool _commentNotifications = true;
  bool _followNotifications = true;
  bool _projectNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final likeNotifs = await ExploreNotificationSettings.getLikeNotifications();
    final commentNotifs = await ExploreNotificationSettings.getCommentNotifications();
    final followNotifs = await ExploreNotificationSettings.getFollowNotifications();
    final projectNotifs = await ExploreNotificationSettings.getProjectNotifications();

    if (mounted) {
      setState(() {
        _likeNotifications = likeNotifs;
        _commentNotifications = commentNotifs;
        _followNotifications = followNotifs;
        _projectNotifications = projectNotifs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildNotificationSettings(),
          const Divider(height: 1),
          Expanded(
            child: _buildNotificationList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notification Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Like Notifications'),
            value: _likeNotifications,
            onChanged: (value) async {
              await ExploreNotificationSettings.setLikeNotifications(value);
              setState(() => _likeNotifications = value);
            },
          ),
          SwitchListTile(
            title: const Text('Comment Notifications'),
            value: _commentNotifications,
            onChanged: (value) async {
              await ExploreNotificationSettings.setCommentNotifications(value);
              setState(() => _commentNotifications = value);
            },
          ),
          SwitchListTile(
            title: const Text('Follow Notifications'),
            value: _followNotifications,
            onChanged: (value) async {
              await ExploreNotificationSettings.setFollowNotifications(value);
              setState(() => _followNotifications = value);
            },
          ),
          SwitchListTile(
            title: const Text('New Project Notifications'),
            value: _projectNotifications,
            onChanged: (value) async {
              await ExploreNotificationSettings.setProjectNotifications(value);
              setState(() => _projectNotifications = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('exploreNotifications')
          .where('recipientId', isEqualTo: _auth.currentUser?.uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final notifications = snapshot.data?.docs ?? [];

        if (notifications.isEmpty) {
          return const Center(
            child: Text(
              'No notifications yet',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          );
        }

        return Container(
          color: Colors.white,
          child: ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index].data() as Map<String, dynamic>;
              final timestamp = (notification['createdAt'] as Timestamp).toDate();
              final formattedDate = DateFormat('MMM d, y • h:mm a').format(timestamp);

              return ListTile(
                tileColor: Colors.white,
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(
                    _getNotificationIcon(notification['title']),
                    color: Colors.grey.shade700,
                  ),
                ),
                title: Text(
                  notification['title'] ?? 'Notification',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification['body'] ?? ''),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: notification['isRead'] == false
                    ? Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  IconData _getNotificationIcon(String? title) {
    switch (title) {
      case 'New Like':
        return Icons.favorite;
      case 'New Comment on Your Project':
        return Icons.comment;
      case 'New Follower':
        return Icons.person_add;
      case 'New Project from':
        return Icons.add_photo_alternate;
      default:
        return Icons.notifications;
    }
  }
} 