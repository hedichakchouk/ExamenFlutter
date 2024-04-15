import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(user!.email.toString()),
    );
  }
}
