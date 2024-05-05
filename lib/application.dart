 import 'package:examenflutteriit/configuration/storage/storage_utils.dart';
 import 'package:flutter/foundation.dart';

class Application {
  static Application? _instance;

  static Application getInstance() {
    return _instance ??= Application();
  }

  bool isDebug() {
    return !kReleaseMode;
  }

  String getAppName() {
    return 'ExamenFlutter';
  }

  Future<void> init() async {
    await StorageUtils.init();

  }
}
