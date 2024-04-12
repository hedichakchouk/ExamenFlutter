import 'package:get_storage/get_storage.dart';

class StorageUtils {
  static const List<String> containers = [
    'GLOBAL',
    'USER_SETTINGS',
    'APP_SETTINGS'
  ];

  static Future<void> init() async {
    containers.forEach(GetStorage.init);
  }
}
