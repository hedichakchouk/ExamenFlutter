import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUP extends StatefulWidget {
  void Function()? onPressed;
  SignUP({super.key, required this.onPressed});

  @override
  State<SignUP> createState() => _SignUPState();
}

class _SignUPState extends State<SignUP> {
  final formkey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool isLoading = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  createUserWithEmailAndPassword(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text, password: password.text);
      setState(() {
        isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.code == 'user-not-found') {
        scaffoldKey.currentState?.showBottomSheet(
          (context) {
            return const SnackBar(content: Text('No user found for that email.')); // Show SnackBar
          },
        );
      } else if (e.code == 'wrong-password') {
        scaffoldKey.currentState?.showBottomSheet(
          (context) {
            return const SnackBar(content: Text('Wrong password provided for that user.'));
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showExitPopup(context),

      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formkey,
              child: OverflowBar(
                overflowSpacing: 20,
                children: [
                  TextFormField(
                    controller: email,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Email is Empty';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(hintText: 'Email'),
                  ),
                  TextFormField(
                    controller: password,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Password is Empty';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(hintText: 'Password'),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.red,
                            )
                          : const Text('SignUP'),
                      onPressed: () {
                        if (formkey.currentState!.validate()) {
                          createUserWithEmailAndPassword(context);
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: widget.onPressed,
                      child: const Text('Login'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


Future<bool> showExitPopup(BuildContext context) async {
  return (await showDialog(
    context: context,
    builder: (context) =>
        AlertDialog(
          title: const Text('Exit App'),
          content: const Text(
            'Do you really want to exit the app?',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.red, onPrimary: Colors.white),
              onPressed: () {
                SystemNavigator.pop();
              },
              child: const Text('Yes'),
            ),
          ],
        ),
  )) ??
      false;
}
