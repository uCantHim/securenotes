import 'package:flutter/material.dart';

import 'note_storage.dart';

class NoteStorageWidget extends StatefulWidget
{
  const NoteStorageWidget({super.key, required this.storage});

  final NoteStorage storage;

  @override
  State<NoteStorageWidget> createState() => _NoteStorageWidgetState();
}

class _NoteStorageWidgetState extends State<NoteStorageWidget>
{
  void addNote() {
    setState(() {
      widget.storage.addNote();
    });
  }

  @override
  Widget build(BuildContext context) {
    var noteButtons = <Widget>[
      for (final note in widget.storage.notes)
        NoteButton(title: note.title, text: note.content)
    ];
    //var noteButtons = <Widget>[
    //  NoteButton(title: 'My note', text: 'Hello, this is Carl. I\'m currently writing a lot of text because I need to test text clipping in this really cool widget that I\'m creating.'),
    //  NoteButton(title: 'My note', text: 'Hello, this is Carl. I\'m currently writing a lot of text because I need to test text clipping in this really cool widget that I\'m creating.'),
    //  NoteButton(title: 'My note', text: 'Hello, this is Carl. I\'m currently writing a lot of text because I need to test text clipping in this really cool widget that I\'m creating.'),
    //  NoteButton(title: 'My note', text: 'Hello, this is Carl. I\'m currently writing a lot of text because I need to test text clipping in this really cool widget that I\'m creating.'),
    //];

    // Wrap buttons in an Expanded widget
    //noteButtons = [for (final b in noteButtons) Expanded(child: b)];
    noteButtons = [for (final b in noteButtons) FittedBox(child: b)];

    return Row(
      children: noteButtons,
    );
  }
}

class NoteButton extends StatelessWidget
{
  const NoteButton({
    super.key,
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  final int maxLines = 2;

  Widget _buildButton(BuildContext context) {
    return ElevatedButton(
      onPressed: (){},
      child: Container(
        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0,),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: maxLines,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildButton(context);
  }
}
