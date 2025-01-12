import 'dart:math';

import 'package:flutter/material.dart';

import 'note_storage.dart' show NoteList, Note;
import 'note_manager.dart';

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
      res.removeLast();
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
      res.removeLast();
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

/// An action to be taken on an edited note
enum NoteEditingOptions {
  commitChanges,
  discardChanges,
  deleteNote,
  copyNote,
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
  Widget buildButtonContent(BuildContext context) {
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

  /// Build the alert dialog that includes the text editor and an action bar
  /// with options to manipulate the note.
  Widget buildNoteEditorAlertDialog(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: AlertDialog(
        content: NoteEditorView(note: note),
        actions: [
          // Popup menu with detail options "delete", "rename", etc.
          PopupMenuButton<NoteEditingOptions>(
            initialValue: null,
            onSelected: (NoteEditingOptions opt) {
              Navigator.pop(context, opt);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: NoteEditingOptions.deleteNote,
                child: Text('Delete Note'),
              ),
              const PopupMenuItem(
                value: NoteEditingOptions.copyNote,
                child: Text('Copy Note'),
              ),
            ],
          ),
          // "Save" button
          TextButton(
            onPressed: () => Navigator.pop(context, NoteEditingOptions.commitChanges),
            child: const Text('Save')
          ),
          // "Discard" button
          TextButton(
            onPressed: () => Navigator.pop(context, NoteEditingOptions.discardChanges),
            child: const Text('Cancel')
          ),
        ],
      )
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
        showDialog<NoteEditingOptions>(
          context: context,
          builder: buildNoteEditorAlertDialog,
        ).then((value) {
          // Value is `null` if the dialog is dismissed
          switch (value) {
            case null:
            case NoteEditingOptions.commitChanges:
              note.updateInStorage();

            case NoteEditingOptions.discardChanges:
              note.title = initialTitle;
              note.content = initialContent;

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
      child: buildButtonContent(context),
    );
  }
}

/// A text editor for a note.
class NoteEditorView extends StatelessWidget {
  const NoteEditorView({ super.key, required this.note });

  final Note note;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0 / 2.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input field for the note's title
          TextField(
            controller: TextEditingController(text: note.title),
            onChanged: (str) => note.title = str,
            decoration: null,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          // Space between title and content
          const Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: null,
          ),
          // Input field for the note's content
          TextField(
            controller: TextEditingController(text: note.content),
            onChanged: (str) => note.content = str,
            decoration: null,
            maxLines: null,
          ),
        ],
      ),
    );
  }
}
