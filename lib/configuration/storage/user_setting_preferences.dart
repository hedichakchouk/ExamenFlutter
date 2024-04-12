import 'dart:convert';

import 'package:get_storage/get_storage.dart';

class UserSettingsPreferences {
  static final appPref = GetStorage('USER_SETTINGS');

  static String get appVersion => appPref.read('AppVersion');

  static void setAppVersion(String val) => appPref.write('AppVersion', val);

  static String get deviceId => appPref.read('deviceId') ?? '';

  static void setDeviceID(String val) => appPref.write('deviceId', val);

  static String get getUrlService => appPref.read('serviceUrl') ?? '';

  static void setUrlService(String val) => appPref.write('serviceUrl', val);

  static void saveStringList(String key, List<String> valueList) {
    String jsonString = jsonEncode(valueList);
    appPref.write(key, jsonString);
  }

  static List<String> getStringList(String key) {
    String jsonString = appPref.read(key) ?? '[]';
    List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((item) => item.toString()).toList();
  }

  static List<String> getAllUrls() {
    return getStringList('urls');
  }
}
