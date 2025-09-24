import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BasePrefs {
  static FlutterSecureStorage storage = const FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.unlocked));

  static void saveData(String key, dynamic value) async {
    storage.write(key: key, value: value.toString());
  }

  static Future<dynamic> readData(String key) async {
    dynamic obj = storage.read(key: key);
    return obj;
  }

  static Future<void> deleteData(String key) async {
    await storage.delete(key: key);
  }

  static Future<void> clearPrefs() async {
    await storage.deleteAll();
  }
}
