import 'package:flutter/material.dart';

import 'note_storage.dart' show NoteList, Note;
import 'note_manager.dart';
import 'note_editor.dart' show NoteEditor, NoteEditingOptions;

class NoteStorageWidget extends StatelessWidget
{
  const NoteStorageWidget({super.key, required this.noteManager});

  final NoteManager noteManager;

  Widget buildNoteList(BuildContext context, NoteList notes) {
    var noteButtons = <Widget>[
      for (final note in notes)
        NoteButton(note: note, manager: noteManager)
    ];

    // Wrap buttons in a Flexible widget
    noteButtons = [for (final b in noteButtons) Flexible(child: b)];

    // TODO: Calculate row size based on parent width
    const int itemsPerRow = 4;
    const double padding = 15.0;

    /// Create a row of note buttons.
    /// We insert SizedBoxes to create horizontal padding between items.
    List<Widget> makeRowChildren(int i) {
      var res = <Widget>[];
      for (int j = i; j < i + itemsPerRow; j++) {
        if (j < noteButtons.length) {
          res.add(noteButtons[j]);
        }
        else {
          // Make sure that notes don't take the full width in half-filled rows
          res.add(const Flexible(child: SizedBox()));
        }
        res.add(const SizedBox(width: padding));
      }
      if (res.isNotEmpty) {
        res.removeLast();
      }
      return res;
    }

    /// Create a column of rows of note buttons.
    /// We insert SizedBoxes to create vertical padding between rows.
    List<Widget> makeColumnChildren() {
      var res = <Widget>[];
      for (int i = 0; i < noteButtons.length; i += itemsPerRow) {
        res.add(
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: makeRowChildren(i),
            )
          )
        );
        res.add(const SizedBox(height: padding));
      }
      if (res.isNotEmpty) {
        res.removeLast();
      }
      return res;
    }

    return Column(children: makeColumnChildren());
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: noteManager,
      builder: (context, child) {
        var notes = noteManager.noteList;
        return buildNoteList(context, notes);
      }
    );
  }
}

class NoteButton extends StatelessWidget
{
  const NoteButton({
    super.key,
    required this.note,
    required this.manager,
  });

  final Note note;
  final NoteManager manager;
  final int maxLines = 4;

  /// Build content of the 'note button', i.e., a preview of the note's
  /// content.
  Widget _buildButtonContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title text
          Text(
            note.title,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: null,
          ),
          // Body text
          Text(
            note.content,
            overflow: TextOverflow.ellipsis,
            maxLines: maxLines,
          ),
        ],
      ),
    );
  }

  /// Build the Note button with an on-click behaviour that opens it in an
  /// editor dialog.
  @override
  Widget build(BuildContext context) {
    final initialTitle = note.title;
    final initialContent = note.content;
    return ElevatedButton(
      onPressed: (){
        // TODO: How do I change behaviour based on screen size or mobile/desktop?
        //NoteEditor.showAsAlertDialog(context, note).then((value) {
        NoteEditor.pushAsPage(context, note).then((value) {
          switch (value) {
            case NoteEditingOptions.discardChanges:
              note.title = initialTitle;
              note.content = initialContent;

            case NoteEditingOptions.commitChanges:
              note.updateInStorage();

            case NoteEditingOptions.deleteNote:
              // Show a confirmation dialog before deleting
              showDialog<bool>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text('Delete note "${note.title}"?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete')
                    ),
                  ],
                ),
              ).then((bool? confirmed) {
                if (confirmed == true) {
                  manager.removeNote(note);
                }
              });

            case NoteEditingOptions.copyNote:
              manager.addNote(Note(note.title, note.content));
          }
        });
      },
      child: _buildButtonContent(context),
    );
  }
}
