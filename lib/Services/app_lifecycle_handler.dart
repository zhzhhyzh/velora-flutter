import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppLifecycleHandler with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshTokenIfNeeded();
    }
  }

  Future<void> _refreshTokenIfNeeded() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final token = await user.getIdToken(true);
        print("Token refreshed: $token");
      } catch (e) {
        print("Error refreshing token: $e");
      }
    }
  }

  Future<void> _refreshTokenWithRetry() async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.getIdToken(true);
          print("Token refreshed successfully.");
          break;
        }
      } catch (e) {
        retryCount++;
        print("Retry $retryCount failed: $e");
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    if (retryCount == maxRetries) {
      print("Failed to refresh token after $maxRetries attempts.");
    }
  }
}