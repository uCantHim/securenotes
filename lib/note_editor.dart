import 'package:flutter/material.dart';

import 'note_storage.dart';

enum NoteEditingOptions {
  commitChanges,
  discardChanges,
  deleteNote,
  copyNote,
}

class NoteEditor extends StatelessWidget {
  const NoteEditor({ super.key, });

  /// The padding between editor window and its enclosed NoteTextEditor.
  static const EdgeInsetsGeometry kEditorContentPadding = EdgeInsets.all(20.0);

  /// Show a note editor as an alert dialog. Looks cool on larger screens.
  static Future<NoteEditingOptions> showAsAlertDialog(BuildContext context, Note note) {
    return showDialog<NoteEditingOptions>(
      context: context,
      builder: (context) => Padding(
        padding: kEditorContentPadding,
        child: AlertDialog(
          content: NoteTextEditor(note: note),
          actions: [
            // Popup menu with detail options "delete", "rename", etc.
            _makeDetailedNoteOptionsButton(context),
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
      ),
    ).then((val) => val ?? NoteEditingOptions.discardChanges);
  }

  /// Show a note editor in a routed page.
  static Future<NoteEditingOptions> pushAsPage(BuildContext context, Note note) {
    return Navigator.push<NoteEditingOptions>(
      context,
      MaterialPageRoute(builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text(note.title),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            // Popup menu button with detailed note options
            _makeDetailedNoteOptionsButton(context),
            // 'Save' button
            IconButton(
              onPressed: (){
                Navigator.pop(context, NoteEditingOptions.commitChanges);
              },
              icon: const Icon(Icons.save),
            ),
          ],
        ),
        body: Padding(
          padding: kEditorContentPadding,
          child: NoteTextEditor(note: note),
        ),
      )),
    ).then((val) => val ?? NoteEditingOptions.discardChanges);
  }

  static Widget _makeDetailedNoteOptionsButton(BuildContext context) {
    // Popup menu with detail options "delete", "rename", etc.
    return PopupMenuButton<NoteEditingOptions>(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Text('foo');
  }
}

/// A text editor for a note.
class NoteTextEditor extends StatelessWidget {
  const NoteTextEditor({ super.key, required this.note });

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
