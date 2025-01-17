import 'dart:io';
import 'package:flutter/foundation.dart';

import 'crypto_util.dart';

class Note extends ChangeNotifier
{
  String title;
  String content;

  Note(this.title, this.content);

  Note.fromJson(Map obj)
      : title = obj['title'] ?? '<failed to parse title>'
      , content = obj['content'] ?? '<failed to parse content>';

  Map<String, String> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }

  void updateInStorage() {
    notifyListeners();
  }
}

typedef NoteList = List<Note>;

/// The 'model' component in the MVVM-approach to the note screen.
///
/// Manages access to the file system and encryption.
class NoteStorage
{
  NoteStorage(this._filePath, this._password);

  final String _filePath;
  final String _password;

  /// Initializes a new note storage if the file does not exist or is
  /// empty.
  ///
  /// Throws [DecryptionException] if [this.password] is incorrect.
  Future<NoteList> loadNotes() async {
    final file = await File(_filePath).create(exclusive: false);
    final data = await file.readAsBytes();

    // File is empty, i.e., a new storage has been created:
    if (data.isEmpty) {
      saveNotes([]);
      return [];
    }

    final json = await decryptJson(data, _password);
    assert(json is List);
    return [for (final note in json) Note.fromJson(note)];
  }

  /// Encrypt notes and save them to a file.
  ///
  /// Note: The file [this._filePath] will be overwritten by this operation.
  Future<void> saveNotes(NoteList notes) async {
    final obj = [for (final note in notes) note.toJson()];
    final data = encryptJson(obj, _password);

    await File(_filePath).writeAsBytes(data);
  }
}
