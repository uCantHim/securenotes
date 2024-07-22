import 'package:flutter/foundation.dart';

import 'note_storage.dart';

/// The 'viewmodel' component in the MVVM-approach to the note screen.
///
/// Provides high-level access to notes and manages the underlying note storage.
class NoteManager extends ChangeNotifier
{
  final NoteStorage _storage;

  NoteList? noteList;
  String? errorMessage;

  NoteManager(this._storage) {
    init();
  }

  Future<bool> init() async {
    try {
      noteList = await _storage.loadNotes();
      for (final note in noteList!) {
        note.addListener(updateNotes);
      }
    }
    catch (err) {
      errorMessage = 'Unable to load notes: $err';
      return false;
    }

    notifyListeners();
    return true;
  }

  NoteList? get notes => noteList;

  Future<void> addNote(Note newNote) async {
    if (noteList == null && !await init()) {
      return;
    }
    newNote.addListener(updateNotes);
    noteList!.add(newNote);

    await _writeNotesToDisk();
    notifyListeners();
  }

  Future<void> updateNotes() async {
    await _writeNotesToDisk();
    notifyListeners();
  }

  Future<void> _writeNotesToDisk() async {
    if (noteList != null) {
      try {
        await _storage.saveNotes(noteList!);
      }
      catch (err) {
        print('Unable to save notes to disk: $err');
      }
    }
  }
}
