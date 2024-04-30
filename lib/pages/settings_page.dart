import 'dart:typed_data';

import 'package:examenflutteriit/components/custom_Alert_Dialog.dart';
import 'package:examenflutteriit/components/custom_language.dart';
import 'package:examenflutteriit/configuration/storage/user_setting_preferences.dart';
import 'package:examenflutteriit/l10n/l10n.dart';
import 'package:examenflutteriit/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late int selectedLanguageIndex;
  String generatedUrl = "https://allmylinks.com/hedi-chakchouk";
  ScrollController scrollControllerQr = ScrollController();
  @override
  void initState() {
    super.initState();
    Locale currentLocale = Provider.of<LocaleProvider>(context, listen: false).locale;
    selectedLanguageIndex = languages.indexOf(currentLocale);
  }

  final user = FirebaseAuth.instance.currentUser;

  Future<Uint8List> generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: format,
      build: (context) => pw.Center(
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
            pw.Text('Examen Flutter ',
                style: pw.TextStyle(fontSize: 30, fontBold: pw.Font.courierBold(), fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 50),
            pw.BarcodeWidget(data: generatedUrl, barcode: pw.Barcode.qrCode(), width: 150, height: 150),
          ])),
    ));
    return pdf.save();
  }

  Future<void> printPdf() async {
    const title = 'Examen_Flutter.pdf';
    await Printing.layoutPdf(onLayout: (format) => generatePdf(format), name: title);
  }

  void generatedQr() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text.rich(
                TextSpan(
                  text: 'Qr Code :',
                  style: TextStyle(
                    fontFamily: 'SFProDisplay',
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(color: Colors.black, Icons.close))
            ],
          ),
          content: SizedBox(
              height: MediaQuery.of(context).size.height * 0.40,
              width: 150,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Center(
                      child: QrImageView(
                        data: generatedUrl,
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        printPdf();
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text("Generate a pdf "), Icon(Icons.picture_as_pdf)],
                      ),
                    )
                  ],
                ),
              )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = Provider.of<LocaleProvider>(context).locale;
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.themeData.brightness == Brightness.dark;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: isDark ? Colors.white : Colors.black87,
          centerTitle: true,
          title: Text('Settings Page ',
              style: TextStyle(
                color: isDark ? Colors.black87 : Colors.white,
              )),
        ),
        body: SettingsList(
          lightTheme: SettingsThemeData(
              titleTextColor: isDark ? Colors.black87 : Colors.white,
              settingsListBackground: isDark ? Colors.white : Colors.black87,
              settingsSectionBackground: isDark ? Colors.black87 : Colors.white),
          physics: const BouncingScrollPhysics(),
          applicationType: ApplicationType.cupertino,
          platform: DevicePlatform.iOS,
          sections: [
            SettingsSection(title: const Text('Dark Mode'), tiles: <SettingsTile>[
              SettingsTile.switchTile(
                onToggle: (value) {
                  themeProvider.toggleTheme();
                },
                initialValue: !isDark,
                leading: Icon(Icons.format_paint),
                title: Text('Switch Theme Mode ',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    )),
              )
            ]),
            SettingsSection(
                title: Text(
                  'qrCode',
                  style: TextStyle(color: isDark ? Colors.black87 : Colors.white),
                ),
                tiles: [
                  SettingsTile(
                    onPressed: (BuildContext value) {
                      generatedQr();
                    },
                    trailing: Icon(
                      Icons.qr_code_outlined,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    title: Text('qrCode',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        )),
                    description: Text(context.l10n.settings),
                  ),
                ]),
            SettingsSection(
              title: Text(context.l10n.close),
              tiles: [
                SettingsTile.navigation(
                  value: Text('English'),
                  trailing: Row(
                    children: [
                      Text(currentLocale.countryCode ?? "!",
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          )),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
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
                  title: Text(context.l10n.enteretablissement,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      )),
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
        ));
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
