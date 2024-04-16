import 'package:examenflutteriit/components/custom_Alert_Dialog.dart';
import 'package:examenflutteriit/components/custom_language.dart';
import 'package:examenflutteriit/configuration/storage/user_setting_preferences.dart';
import 'package:examenflutteriit/l10n/l10n.dart';
import 'package:examenflutteriit/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late int selectedLanguageIndex;
  @override
  void initState() {
    super.initState();
    Locale currentLocale = Provider.of<LocaleProvider>(context, listen: false).locale;
    selectedLanguageIndex = languages.indexOf(currentLocale);
  }

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = Provider.of<LocaleProvider>(context).locale;
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.themeData.brightness == Brightness.dark;
    return SafeArea(
      child: Scaffold(
           body: SettingsList(
            lightTheme: SettingsThemeData(
                titleTextColor: isDark ? Colors.black87 : Colors.white,
                settingsListBackground: isDark ? Colors.white : Colors.black87,
                settingsSectionBackground: isDark ? Colors.black87 : Colors.white),
            physics: const BouncingScrollPhysics(),
            applicationType: ApplicationType.cupertino,
            platform: DevicePlatform.iOS,
            sections: [
              SettingsSection(
                  title: Text(
                    'qrCode',
                    style: TextStyle(color: isDark ? Colors.black87 : Colors.white),
                  ),
                  tiles: [
                    SettingsTile(
                      onPressed: (BuildContext value) {},
                      trailing: const Icon(Icons.qr_code_outlined, color: Colors.black),
                      title: const Text('qrCode', style: TextStyle(color: Colors.black)),
                      description: Text(context.l10n.settings),
                    ),
                  ]),
              SettingsSection(
                title: Text(context.l10n.close),
                tiles: [
                  SettingsTile.navigation(
                    trailing: Row(
                      children: [
                        Text(currentLocale.countryCode ?? "!", style: const TextStyle(color: Colors.black45)),
                        const Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                    onPressed: (context) {
                      showCupertinoModalPopup<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: 200,
                            padding: const EdgeInsets.only(bottom: 15),
                            color: Colors.white,
                            child: CupertinoPicker(
                              magnification: 1.22,
                              squeeze: 1.2,
                              useMagnifier: true,
                              itemExtent: 32,
                              scrollController: FixedExtentScrollController(
                                initialItem: selectedLanguageIndex,
                              ),
                              onSelectedItemChanged: (int index) {
                                Provider.of<LocaleProvider>(context, listen: false).locale = languages[index];
                                GetStorage box = GetStorage('USER_SETTINGS');
                                box.write('locale', languages[index].languageCode);
                              },
                              children: List<Widget>.generate(languages.length, (int index) {
                                return Center(
                                  child: Text(languages[index].toString()),
                                );
                              }),
                            ),
                          );
                        },
                      );
                    },
                    title: Text(context.l10n.enteretablissement),
                    description: Text(context.l10n.designation),
                  ),
                ],
              ),
              SettingsSection(
                title: Text(context.l10n.account),
                tiles: [
                  SettingsTile(
                    onPressed: (_) async {
                      CustomAlertDialog().showAlertDialog(_);
                    },
                    trailing: const Icon(Icons.logout, color: Colors.red),
                    title: Text(context.l10n.logOut, style: const TextStyle(color: Colors.red)),
                    description: Text(context.l10n.logOutDesc),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}

List<Locale> languages = [
  const Locale('ar', 'arabic'),
  const Locale('en', 'English'),
  const Locale('fr', 'Francais'),
];

void changeLanguage(Locale newLocale, BuildContext context) {
  Provider.of<LocaleProvider>(context, listen: false).locale = newLocale;
  GetStorage box = GetStorage('USER_SETTINGS');
  box.write('locale', newLocale.languageCode);
}
