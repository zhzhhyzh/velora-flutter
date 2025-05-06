import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:velora2/Home/home_screen.dart';
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
    if (_notificationSubscription != null) return; // avoid multiple listeners

    _notificationSubscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('recipientId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final title = data['title']?.toString() ?? 'No Title';
        final body = data['body']?.toString() ?? '';

        print('🔔 Incoming Firestore Notification: $title | $body');

        NotificationService.showNotification(
          title: title,
          body: body,
        ).then((_) {
          // Mark as read only if showNotification succeeded
          doc.reference.update({'isRead': true});
          print('✅ Local notification shown and marked as read.');
        }).catchError((e) {
          print('❌ Failed to show notification: $e');
        });
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
