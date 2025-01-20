import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Global configuration settings for the secure notes app.
class AppConfig {
  AppConfig() {
    getNoteStorageFilePath().then((path) => noteStorageFilePath = path);
  }

  late final String noteStorageFilePath;

  static Future<String> getNoteStorageFilePath() async {
    const fileName = 'securenotes_storage.txt';

    return getApplicationDocumentsDirectory()
        .then((dir) => dir.path)
        .catchError((err) => '.')
        .then((dirPath) => p.join(dirPath, fileName));
  }

  /// Load an [AppConfig] from the default location on the current system.
  /// Defaults to an empty configuration if none is found.
  static Future<AppConfig> loadSystemConfig() {
    return _openConfigFile()
        .then((file) => file.readAsString())
        .then((str)  => jsonDecode(str))
        .then((json) => AppConfig.fromJson(json))
        // Default to an empty config.
        .catchError((_) => AppConfig());
  }

  /// Returns an exception if an underlying system error occurs.
  static Future<void> storeAsSystemConfig(AppConfig config) {
    return _openConfigFile()
        .then((file) {
          file.writeAsString(jsonEncode(config.toJson()));
        });
  }

  /// Construct a configuration object from a JSON object.
  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig();
  }

  /// Turn the configuration into a JSON object.
  Map<String, dynamic> toJson() {
    return {};
  }

  static Future<File> _openConfigFile() {
    const configFileName = 'securenotes_config.json';
    return getApplicationSupportDirectory()
        .then((dir)  => p.join(dir.path, configFileName))
        .then((path) => File(path));
  }
}
