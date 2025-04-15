import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Contact',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(
              automaticallyImplyLeading: false,
              actions: [
          IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<ProfileScreen>(
                builder: (context) =>
                    ProfileScreen(
                      actions: [
                        SignedOutAction((context) {
                          Navigator.of(context).pop();
                        }),
                      ],
                    ),
              ),
            );
          },
        ),
        IconButton(
            icon: const Icon(Icons.add),
        onPressed: () {

          const Icon(Icons.add);

        }
        ),
    ],
    ),
    body: Center(
    child: Column(
    children: [
    UserWidget(),
    ],
    ),
    ),
    ),
    );
  }
  }

  class UserWidget extends StatefulWidget {
  const UserWidget({super.key});
  @override
  State<UserWidget> createState() => _UserWidgetState();
  }
  class _UserWidgetState extends State<UserWidget> {
  User? _user;
  late FirebaseFirestore _firestoreInstance;
  @override
  void initState() {
  super.initState();
//TODO - Get the current user
  _firestoreInstance = FirebaseFirestore.instance;
  var user = FirebaseAuth.instance.currentUser;
  if (user != null) {
  _user = user;
  }
  }
  @override
  Widget build(BuildContext context) {
  return Padding(
  padding: const EdgeInsets.all(8.0),
  child: Column(
  children: [
  _user == null || _user!.displayName == null
  ? Text('Welcome!')
      : Text('Welcome, ${_user!.displayName} !'),
  ],
  ),
  );
  }
  }