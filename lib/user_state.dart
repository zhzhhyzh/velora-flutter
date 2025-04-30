import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:velora2/Home/home_screen.dart';
import 'package:velora2/LoginPage/login_screen.dart';
import 'package:velora2/Services/app_lifecycle_handler.dart'; // Ensure correct path

class UserState extends StatefulWidget {
  const UserState({super.key});

  @override
  State<UserState> createState() => _UserStateState();
}

class _UserStateState extends State<UserState> with WidgetsBindingObserver {
  final AppLifecycleHandler _lifecycleHandler = AppLifecycleHandler();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycleHandler);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleHandler);
    super.dispose();
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
            body: Center(
              child: Text('An error has occurred. Try again later'),
            ),
          );
        } else if (userSnapshot.hasData) {
          print('User is already logged in');
          return const HomeScreen();
        } else {
          print('User is not logged in');
          return  Login();
        }
      },
    );
  }
}
