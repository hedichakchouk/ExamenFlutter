import 'package:examenflutteriit/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
    HomePage({super.key});
final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Home Page"),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.person),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute<User?>(
          //         builder: (context) => const LoginPage(),
          //       ),
          //     );
          //   },
          // ),
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              icon: Icon(Icons.login))
        ],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child:  Text(user!.email.toString()),
      ),
    );
  }
}
