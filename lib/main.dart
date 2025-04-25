import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:velora2/config/theme.dart';
import 'package:velora2/user_state.dart';
 import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  //TODO - Insert initialisation of Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  bool _iconBool = false;
  IconData _iconLight = Icons.wb_sunny;
  IconData _iconDark = Icons.nights_stay;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  'Velora',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Signatra',
                  ),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  'An Error has been occurred',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Velora',

          theme: ThemeData(
            scaffoldBackgroundColor: Colors.black,
            primarySwatch: Colors.blue,

          ),
          home: UserState(),
        );
      },
    );
  }
}
