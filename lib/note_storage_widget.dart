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
        NoteButton(note: note)
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

  Widget buildErrorMessage(BuildContext context) {
    return Text(noteManager.errorMessage ?? 'An unexpected error occurred.');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: noteManager,
      builder: (context, child) {
        var notes = noteManager.noteList;
        if (notes != null) {
          return buildNoteList(context, notes);
        }
        return buildErrorMessage(context);
      }
    );
  }
}

/// An action to be taken when a note has been edited.
enum NoteEditResult {
  commitChanges,
  discardChanges
}

class NoteButton extends StatelessWidget
{
  const NoteButton({
    super.key,
    required this.note,
  });

  final Note note;
  final int maxLines = 4;

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

  Widget buildNoteEditorAlertDialog(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: AlertDialog(
        content: NoteEditorView(note: note),
        actions: [
          // "Save" button
          TextButton(
            onPressed: (){
              Navigator.of(context).pop(NoteEditResult.commitChanges);
            },
            child: const Text('Save')
          ),
          // "Discard" button
          TextButton(
            onPressed: (){
              Navigator.of(context).pop(NoteEditResult.discardChanges);
            },
            child: const Text('Discard')
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialTitle = note.title;
    final initialContent = note.content;
    return ElevatedButton(
      onPressed: (){
        showDialog(
          context: context,
          builder: buildNoteEditorAlertDialog,
        ).then((value) {
          // Value is `null` if the dialog is dismissed
          if (value == null || value == NoteEditResult.commitChanges) {
            note.updateInStorage();
          }
          else if (value == NoteEditResult.discardChanges) {
            note.title = initialTitle;
            note.content = initialContent;
          }
          else {
            print('[Warning] Result of note editing dialog should be `null` or'
                  ' an instance of `EditNoteResult`, but is: $value');
          }
        });
      },
      child: buildButtonContent(context),
    );
  }
}

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
