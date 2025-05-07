import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:velora2/Explore/explore_screen.dart';
import 'package:velora2/LoginPage/login_screen.dart';
import 'package:velora2/Services/app_lifecycle_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:velora2/Services/Notification/notification_service.dart';

class UserState extends StatefulWidget {
  const UserState({super.key});

  @override
  State<UserState> createState() => _UserStateState();
}

class _UserStateState extends State<UserState> with WidgetsBindingObserver {
  final AppLifecycleHandler _lifecycleHandler = AppLifecycleHandler();
  final ValueNotifier<bool> hasUnreadNotifications = ValueNotifier(false);

  User? _currentUser;
  StreamSubscription<QuerySnapshot>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycleHandler);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleHandler);
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _startNotificationListener(User user) {
    _notificationSubscription?.cancel(); // Cancel any existing listener to avoid duplication

    _notificationSubscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('recipientId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        hasUnreadNotifications.value = true;
      }

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final title = data['title']?.toString() ?? 'No Title';
        final body = data['body']?.toString() ?? '';

        NotificationService.showNotification(
          title: title,
          body: body,
        ).then((_) {
          doc.reference.update({'isRead': true});
        }).catchError((e) {
          print('❌ Failed to show notification: $e');
        });
      }

      // Reset badge if all notifications processed
      if (snapshot.docs.isEmpty) {
        hasUnreadNotifications.value = false;
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (userSnapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('An error has occurred. Try again later')),
          );
        } else if (userSnapshot.hasData) {
          final user = userSnapshot.data!;
          if (_currentUser?.uid != user.uid) {
            _currentUser = user;
            _startNotificationListener(user);
          }
          return const ExploreScreen();
        } else {
          _notificationSubscription?.cancel();
          _currentUser = null;
          return  Login();
        }
      },
    );
  }
}
