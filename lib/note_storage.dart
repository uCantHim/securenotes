import 'dart:io';

import 'util.dart';

class NoteData
{
  NoteData(this.title, this.content);

  NoteData.fromJson(Map obj)
      : title = obj['title'] ?? '<failed to parse title>'
      , content = obj['content'] ?? '<failed to parse content>';

  Map<String, String> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }

  String title;
  String content;
}

class NoteStorage
{
  NoteStorage(this._filePath, this._password, {this.notes=const []});

  final String _filePath;
  final String _password;

  List<NoteData> notes;

  static final Map<String, NoteStorage> _cache = {};

  factory NoteStorage.load(String filePath, String password) {
    password = password.padRight(32);
    if (!_cache.containsKey(filePath))
    {
      final file = File(filePath);
      if (!file.existsSync()) {
        file.create();
      }

      var data = file.readAsBytesSync();
      data = encryptJson([{'foo': 'bar', 'title': 'My note', 'content': 'Hello, note!'}], password);
      final obj = decryptJson(data, password);
      assert(obj is List);

      final notes = [for (final note in obj) NoteData.fromJson(note)];
      _cache[filePath] = NoteStorage(filePath, password, notes: notes);
    }

    assert(_cache.containsKey(filePath));
    return _cache[filePath]!;
  }

  /// Encrypt notes and save them to this NoteStorage's file.
  void save() {
    final obj = [for (final note in notes) note.toJson()];
    final data = encryptJson(obj, _password);

    final file = File(_filePath);
    file.writeAsBytesSync(data);
  }

  void addNote() {
    notes.add(NoteData('', ''));
  }
}
