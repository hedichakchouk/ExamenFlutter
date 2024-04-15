import 'dart:convert';

import 'package:get_storage/get_storage.dart';

class UserSettingsPreferences {
  static final appPref = GetStorage('USER_SETTINGS');

  static String get appVersion => appPref.read('AppVersion');

  static void setAppVersion(String val) => appPref.write('AppVersion', val);


  static int get getWalpaper => appPref.read('walpaper')?? 0 ;

  static void setWalpaper(int val) => appPref.write('walpaper', val);

  static String get savePassword => appPref.read('savePassword');

  static void setSavePassword(String val) => appPref.write('savePassword', val);

}
