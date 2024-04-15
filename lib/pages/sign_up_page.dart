import 'dart:ui';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:examenflutteriit/configuration/storage/user_setting_preferences.dart';
import 'package:examenflutteriit/data/bg_data.dart';
import 'package:examenflutteriit/utils/text_utils.dart';
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
  bool passwordVisible = false;
  @override
  void initState() {
    passwordVisible = false;
  }

  void createUserWithEmailAndPassword(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text, password: password.text);
    } on FirebaseAuthException catch (e) {
      showErrorMessage(e.code, context);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => showExitPopup(context),
        child: Scaffold(
            body: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  image:
                      DecorationImage(image: AssetImage(bgList[UserSettingsPreferences.getWalpaper]), fit: BoxFit.fill),
                ),
                alignment: Alignment.center,
                child: Container(
                  height: 400,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black.withOpacity(0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: formkey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Spacer(),
                              Center(
                                  child: TextUtil(
                                text: "Sign In",
                                weight: true,
                                size: 30,
                              )),
                              const Spacer(),
                              TextUtil(
                                size: 20,
                                text: "Email",
                              ),
                              Container(
                                height: 30,
                                decoration:
                                    const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white))),
                                child: TextFormField(
                                  controller: email,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'Email is Empty';
                                    }
                                    return null;
                                  },
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    suffixIcon: Icon(
                                      Icons.mail,
                                      color: Colors.white,
                                    ),
                                    fillColor: Colors.white,
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              TextUtil(
                                size: 20,
                                text: "Password",
                              ),
                              Container(
                                height: 35,
                                decoration:
                                    const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white))),
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  obscureText: !passwordVisible,
                                  controller: password,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'Password is Empty';
                                    }
                                    return null;
                                  },
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        passwordVisible ? Icons.lock : Icons.lock_open,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          passwordVisible = !passwordVisible;
                                        });
                                      },
                                    ),
                                    fillColor: Colors.white,
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: ElevatedButton(
                                  child: isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.black,
                                        )
                                      : const Text('Create New Account '),
                                  onPressed: () {
                                    if (formkey.currentState!.validate()) {
                                      createUserWithEmailAndPassword(context);
                                    }
                                  },
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: widget.onPressed,
                                  child: const Text('Go to Login Page '),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ))));
  }
}

Future<bool> showExitPopup(BuildContext context) async {
  return (await showDialog(
        context: context,
        builder: (context) => AlertDialog(
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

void showErrorMessage(String errorCode, context) {
  String errorMessage;
  switch (errorCode) {
    case 'email-already-in-use':
      errorMessage = 'The email address is already in use by another account.!!';
      break;
    case 'invalid-email':
      errorMessage = 'The email address is not valid.!!';
      break;
    case 'weak-password':
      errorMessage = 'The password is not strong enough.!!';
      break;
    default:
      errorMessage = 'An unexpected error occurred. Please try again.!!';
      break;
  }
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    showCloseIcon: false,
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'Opps!',
      message: errorMessage,
      contentType: ContentType.failure,
    ),
    duration: const Duration(seconds: 3),
  ));
}
