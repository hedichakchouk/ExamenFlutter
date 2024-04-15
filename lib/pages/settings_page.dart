import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SettingsList(
        physics: const BouncingScrollPhysics(),
        applicationType: ApplicationType.cupertino,
        platform: DevicePlatform.iOS,
        sections: [
           SettingsSection(title: Text('qrCode'), tiles: [
            SettingsTile(
              onPressed: (BuildContext value) {},
              trailing: const Icon(Icons.qr_code_outlined, color: Colors.black),
              title: Text('qrCode', style: TextStyle(color: Colors.black)),
              description: Text('generateQrCode'),
            ),
          ]),
          SettingsSection(
            title: Text('langage'),
            tiles: [
              SettingsTile.navigation(
                trailing: Row(
                  children: [
                    // Text(languages[UserSettingsPreferences.getLanguage].countryCode!, style: TextStyle(color: Colors.black45)),
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
                onPressed: (_) {
                  // CustomLanguage().showDialog(
                  // context,
                  // BlocBuilder<LocalCubit, LocalState>(
                  // buildWhen: (previousState, currentState) => previousState != currentState,
                  // builder: (context, state) {
                  // return CupertinoPicker(
                  // magnification: 1.22,
                  // squeeze: 1.2,
                  // useMagnifier: true,
                  // itemExtent: 32,
                  // scrollController: FixedExtentScrollController(
                  // initialItem: UserSettingsPreferences.getLanguage,
                  // ),
                  // onSelectedItemChanged: (int selectedItem) {
                  // BlocProvider.of<LocalCubit>(context).changeLocal(languages[selectedItem]);
                  // },
                  // children: List<Widget>.generate(languages.length, (int index) {
                  // return Center(
                  // child: Text(languages[index].countryCode!),
                  // );
                  // }),
                  // );
                  // },
                  // ),
                  // );
                },
                title: Text('appLanguage'),
                description: Text('appLanguageDesc'),
              ),
            ],
          ),
          SettingsSection(
            title: Text('account'),
            tiles: [
              SettingsTile(
                onPressed: (BuildContext value) {},
                trailing: const Icon(Icons.logout, color: Colors.red),
                title: Text('logOut', style: TextStyle(color: Colors.red)),
                description: Text('logOutDesc'),
              ),
            ],
          ),
        ],
      )),
    );
  }
}
