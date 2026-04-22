import 'package:hive/hive.dart';

class AppMetaService {
  static const String boxName = 'app_meta';
  static const String dataVersionKey = 'data_version';

  static Future<Box> _openBox() async {
    return await Hive.openBox(boxName);
  }

  static Future<int?> getDataVersion() async {
    final box = await _openBox();
    return box.get(dataVersionKey);
  }

  static Future<void> setDataVersion(int version) async {
    final box = await _openBox();
    await box.put(dataVersionKey, version);
  }
}