import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'home.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              //  Display only the logo
              return Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(
                    "assets/images/logo.jpg",
                    width: 200,
                    height: 200,
                  ),
                ),
              );
            },
            subtitleBuilder: (context, action) {
             
              return Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 8.0), // Added top padding
                child:  Text.rich(
                    TextSpan(
                      style: TextStyle(),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'WELCOME TO ',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        TextSpan(
                          text: 'VELORA',
                          style:
                          TextStyle(color: Color(0xFF689F77), fontSize: 20.0),
                        ),
                      ],
                    ),
                  ),

              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            sideBuilder: (context, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: FlutterLogo(
                    size: 100,
                  ),
                ),
              );
            },
          );
        }
        return const HomeScreen();
      },
    );
  }
}

