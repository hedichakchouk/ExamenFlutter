
import 'package:examenflutteriit/application.dart';
import 'package:examenflutteriit/l10n/l10n.dart';
import 'package:examenflutteriit/pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';



void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init('USER_SETTINGS');
  final box = GetStorage('USER_SETTINGS');
  String? storedLocaleCode = box.read('locale') ?? 'en';

  Locale initialLocale = Locale(storedLocaleCode);
  bool isDarkMode = box.read('isDarkMode') ?? false;

  await Application.getInstance().init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LocaleProvider(initialLocale)),
      ChangeNotifierProvider(create: (_) => ThemeProvider(isDarkMode: isDarkMode)),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,

      ),
      locale: localeProvider.locale,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.all,

      home: AuthGate(),
    );
  }
}



class LocaleProvider with ChangeNotifier {
  Locale _locale;

  LocaleProvider(this._locale);

  Locale get locale => _locale;

  set locale(Locale newLocale) {
    if (!L10n.all.contains(newLocale)) return;
    _locale = newLocale;
    notifyListeners();
  }
}

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider({bool isDarkMode = false})
      : _themeData = isDarkMode ? ThemeData.dark() : ThemeData.light();

  ThemeData get themeData => _themeData;

  void toggleTheme() {
    _themeData = _themeData == ThemeData.dark() ? ThemeData.light() : ThemeData.dark();
    notifyListeners();
  }
}

class L10n {
  static final all = [
    const Locale('en', 'English'),
    const Locale('fr', 'Francais'),
    const Locale('ar', 'arabic'),
   ];
}