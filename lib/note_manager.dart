import 'package:flutter/foundation.dart';

import 'note_storage.dart';

/// The 'viewmodel' component in the MVVM-approach to the note screen.
///
/// Provides high-level access to notes and manages the underlying note storage.
class NoteManager extends ChangeNotifier
{
  final NoteStorage _storage;
  NoteList noteList = [];

  NoteManager(this._storage, this.noteList) {
    for (final note in noteList) {
      note.addListener(updateNotes);
    }
    notifyListeners();
  }

  /// Either returns a [NoteManager] object or fails with a
  /// [DecryptionException].
  static Future<NoteManager> fromStorage(NoteStorage storage) async {
    final noteList = await storage.loadNotes();
    return NoteManager(storage, noteList);
  }

  NoteList get notes => noteList;

  Future<void> addNote(Note newNote) async {
    newNote.addListener(updateNotes);
    noteList.add(newNote);

    await _writeNotesToDisk();
    notifyListeners();
  }

  Future<void> removeNote(Note removedNote) async {
    noteList.removeWhere((note) => note == removedNote);
    await updateNotes();
  }

  Future<void> updateNotes() async {
    await _writeNotesToDisk();
    notifyListeners();
  }

  Future<void> _writeNotesToDisk() async {
    try {
      await _storage.saveNotes(noteList);
    }
    catch (err) {
      print('Unable to save notes to disk: $err');
    }
  }
}
