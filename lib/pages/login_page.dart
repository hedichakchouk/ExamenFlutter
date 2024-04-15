import 'dart:ui';

import 'package:examenflutteriit/configuration/storage/user_setting_preferences.dart';
import 'package:examenflutteriit/utils/animations.dart';
import 'package:examenflutteriit/utils/text_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../data/bg_data.dart';
import '../googleAuth/google_auth.dart';

class LoginPage extends StatefulWidget {
  void Function()? onPressed;
  LoginPage({super.key, required this.onPressed});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formkey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool isLoading = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ValueNotifier userCredential = ValueNotifier('');
  bool passwordVisible = false;
  bool rememberPassword = false;
  @override
  void initState() {
    passwordVisible = false;
    password.text.isNotEmpty? password.text =   UserSettingsPreferences.savePassword :'';
  }

  signInWithEmailAndPassword(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text, password: password.text);
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

  int selectedIndex = 0;
  bool showOption = false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: Scaffold(
        floatingActionButton: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          height: 49,
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                  child: showOption
                      ? ShowUpAnimation(
                          delay: 100,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: bgList.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index;
                                      UserSettingsPreferences.setWalpaper(selectedIndex);
                                    });
                                  },
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: selectedIndex == index ? Colors.white : Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.all(1),
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundImage: AssetImage(
                                          bgList[index],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        )
                      : const SizedBox()),
              const SizedBox(
                width: 20,
              ),
              showOption
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          showOption = false;
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ))
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          showOption = true;
                        });
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(
                              bgList[UserSettingsPreferences.getWalpaper],
                            ),
                          ),
                        ),
                      ),
                    )
            ],
          ),
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(bgList[UserSettingsPreferences.getWalpaper]), fit: BoxFit.fill),
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
                    padding: const EdgeInsets.all(25),
                    child: Form(
                      key: formkey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          Center(
                              child: TextUtil(
                            text: "Login",
                            weight: true,
                            size: 30,
                          )),
                          const Spacer(),
                          TextUtil(
                            size: 20,
                            text: "Email",
                          ),
                          Container(
                            height: 35,
                            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white))),
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
                            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white))),
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
                          Row(
                            children: [
                              Checkbox(
                                value: rememberPassword,
                                onChanged: (bool? value) {
                                  setState(() {
                                    rememberPassword = value!;
                                  });
                                },
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: TextUtil(
                                text: "Remember Me , FORGET PASSWORD",
                                size: 12,
                                weight: true,
                              ))
                            ],
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              if (formkey.currentState!.validate()) {
                                if(rememberPassword){
                                  UserSettingsPreferences.setSavePassword(password.text);
                                }
                                signInWithEmailAndPassword(context);
                              }
                            },
                            child: Container(
                              height: 40,
                              width: double.infinity,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                              alignment: Alignment.center,
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.red,
                                    )
                                  : TextUtil(
                                      text: "Log In",
                                      color: Colors.black,
                                    ),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text('Sign in with Google'),
                                Image.asset(
                                  'assets/images/google_icon.png',
                                  height: 20,
                                  width: 20,
                                )
                              ],
                            ),
                            onPressed: () async {
                              userCredential.value = await signInWithGoogle();
                              if (userCredential.value != null) print(userCredential.value.user!.email);
                            },
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: widget.onPressed,
                            child: Center(
                                child: TextUtil(
                              text: "Don't have a account REGISTER",
                              size: 12,
                              weight: true,
                            )),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  )),
            ),
          ),
        ),
      ),
    );
  }
}

Future<dynamic> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  } on Exception catch (e) {
// TODO
    print('exception->$e');
  }
}

Future<bool> signOutFromGoogle() async {
  try {
    await FirebaseAuth.instance.signOut();
    return true;
  } on Exception catch (_) {
    return false;
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
