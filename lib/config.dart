import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Global configuration settings for the secure notes app.
class AppConfig {
  AppConfig(this.noteStorageFilePath);

  final String noteStorageFilePath;

  /// Find the file path of the local note storage.
  static Future<String> getNoteStorageFilePath() async {
    const fileName = 'securenotes_storage.txt';
    final dirs = <Future<String> Function()>[
      () async => getApplicationDocumentsDirectory()
          .then((d) => p.join(d.path, '.config/securenotes')),
      () async => getApplicationDocumentsDirectory().then((d) => d.path),
      () async => '.',
   ];

    for (final func in dirs) {
      try {
        final path = p.canonicalize(await func());
        final dir = await Directory(path).create();
        return p.join(dir.path, fileName);
      }
      catch (err) {
        // Continue
      }
    }

    return '${p.canonicalize('.')}/$fileName';
  }

  /// Load an [AppConfig] from the default location on the current system.
  /// Defaults to an empty configuration if none is found.
  static Future<AppConfig> loadSystemConfig() {
    return _openConfigFile()
        .then((file) => file.readAsString())
        .then((str)  => jsonDecode(str))
        .then((json) => AppConfig.fromJson(json)!)
        // Default to an empty config.
        .catchError((_) async {
          final path = await AppConfig.getNoteStorageFilePath();
          return AppConfig(path);
        });
  }

  /// Returns an exception if an underlying system error occurs.
  static Future<void> storeAsSystemConfig(AppConfig config) {
    return _openConfigFile()
        .then((file) {
          file.writeAsString(jsonEncode(config.toJson()));
        });
  }

  /// Construct a configuration object from a JSON object.
  static AppConfig? fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('noteStorageFilePath')) {
      return null;
    }
    return AppConfig(json['noteStorageFilePath']);
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
