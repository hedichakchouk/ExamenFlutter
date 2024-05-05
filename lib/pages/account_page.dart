import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:examenflutteriit/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

Color tPrimaryColor = Colors.blue;
Color tDarkColor = Colors.black;
Color tAccentColor = Colors.red;
final user = FirebaseAuth.instance.currentUser;
final displayName = user!.displayName;
final email = user!.email;
final photoURL = user!.photoURL;
final emailVerified = user!.emailVerified;
TextEditingController nameController = TextEditingController();
TextEditingController phoneController = TextEditingController();
final ImagePicker picker = ImagePicker();
XFile? imageFile;
String? imagePath;

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    super.initState();
    print(user);
    if (user != null) {
      nameController.text = user!.displayName ?? "";
      phoneController.text = user!.phoneNumber ?? "";
      imagePath = user!.photoURL ?? "";
    }
  }

  Future<void> updateDisplayName() async {
    if (user != null) {
      await user!.updateProfile(displayName: nameController.text);
      await user!.reload();
      print("Display name updated to: ${user!.displayName}");
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          imageFile = pickedFile;
          imagePath = pickedFile.path;
          user!.updateProfile(photoURL: imageFile!.path);
        });
      }
    } catch (e) {
      print("Failed to pick image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.themeData.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.white : Colors.black87,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Stack(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: (imagePath == null || imagePath =="")
                        ? const Image(image: AssetImage('assets/teacher.png'))
                        : imagePath!.contains("http")?Image.network(imagePath!):Image.file(File(imagePath!)),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: tPrimaryColor,
                    ),
                    child: InkWell(
                      onTap: () {
                        pickImage(ImageSource.camera);
                      },
                      child: const Icon(
                        LineAwesomeIcons.alternate_pencil,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Text(user!.displayName ?? '',
                style: TextStyle(
                  color: isDark ? Colors.black87 : Colors.white,
                )),
            const SizedBox(height: 10),
            Text(user!.email.toString(),
                style: TextStyle(
                  color: isDark ? Colors.black87 : Colors.white,
                )),

            const SizedBox(height: 20),

            /// -- BUTTON
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () async {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    try {
                      await user.updateDisplayName( nameController.text);
                      await user.reload();
                      user = FirebaseAuth.instance.currentUser;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        showCloseIcon: false,
                        elevation: 0,
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.transparent,
                        content: AwesomeSnackbarContent(
                          title: 'Succes!',
                          message: 'Settings Updated successfully',
                          contentType: ContentType.success,
                        ),
                        duration: const Duration(seconds: 3),
                      ));
                    } catch (e) {
                      print("Failed to update display name: $e");
                    }
                  } else {
                    print("No user logged in");
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: CupertinoColors.activeGreen , side: BorderSide.none, shape: const StadiumBorder()),
                child: Text(' Edit Profile',
                    style: TextStyle(
                      color: isDark ? Colors.black87 : Colors.white,
                    )),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Edit Display Name'),
                onTap: () {},
                controller: nameController,
                style: TextStyle(
                  color: isDark ? Colors.black87 : Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 30),

            ProfileMenuWidget(
                title: "recieve email to reset password ",
                icon: LineAwesomeIcons.mail_bulk,
                textColor: Colors.red,
                endIcon: false,
                onPress: () async {
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: user!.email!)
                      .then((value) => FirebaseAuth.instance.signOut());
                }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    var iconColor = isDark ? tPrimaryColor : tAccentColor;

    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: iconColor.withOpacity(0.1),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyText1?.apply(color: textColor)),
      trailing: endIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.grey.withOpacity(0.1),
              ),
              child: const Icon(LineAwesomeIcons.angle_right, size: 18.0, color: Colors.grey))
          : null,
    );
  }
}
