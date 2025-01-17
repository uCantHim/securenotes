import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'crypto_util.dart';  // For DecryptionException
import 'firsttime_login_page.dart';
import 'login_page.dart';
import 'note_manager.dart';
import 'note_storage.dart';
import 'note_storage_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Style constants
  static const double buttonCornerRadius = 5.0;

  final ButtonStyle defaultButtonStyle = ButtonStyle(
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonCornerRadius)),
    ),
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark
        ),
        useMaterial3: true,

        // Custom corner rounding for all buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: defaultButtonStyle,
        ),
      ),
      home: const MyHomePage(
        title: 'Flutter Demo Home Page',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({ super.key, });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Loading...',
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}

class MyAppState extends State<MyHomePage> {
  String? _localStorageFilePath;
  bool _initialized = false;

  NoteManager? _noteManager;

  MyAppState() {
    _initialize()
        .then((pair) {
          setState(() {
            _localStorageFilePath = pair.$1;
            _initialized = pair.$2;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    if (_localStorageFilePath == null) {
      return const LoadingPage();
    }

    if (_noteManager != null) {
      return NotePage(noteManager: _noteManager!);
    }

    if (_initialized) {
      return LoginPage(
        onPasswordEntered: (password) async {
          try {
            final storage = NoteStorage(_localStorageFilePath!, password);
            final notes = await NoteManager.fromStorage(storage);
            setState(() {
              _noteManager = notes;
            });
            return PasswordStatus.eCorrect;
          } on DecryptionException {
            return PasswordStatus.eIncorrect;
          }
        }
      );
    }

    return CreatePasswordPage(
      onPasswordSubmit: (password) {
        final storage = NoteStorage(_localStorageFilePath!, password);
        NoteManager.fromStorage(storage)
            .then((noteManager) {
              setState(() {
                noteManager = noteManager;
              });
            });
      }
    );
  }

  static Future<String> _getNoteStorageFilePath() {
    const fileName = 'foobar.txt';
    return getApplicationDocumentsDirectory()
        .then((dir) => dir.path)
        .catchError((err) => '.')
        .then((dirPath) => '$dirPath/$fileName');
  }

  /// Returns a pair [(localStorageFilePath, isInitialized)].
  Future<(String, bool)> _initialize() {
    return _getNoteStorageFilePath()
        .then((path) async => (path, await File(path).exists()));
  }
}

class NotePage extends StatelessWidget {
  const NotePage({ super.key, required this.noteManager });

  final NoteManager noteManager;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('A secure note app'),
        actions: const [
          // We could add some action buttons to the header bar here.
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(30.0),

        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: NoteStorageWidget(noteManager: noteManager),
      ),
      floatingActionButton: FloatingActionButton(
        // Floating 'add note' button.
        onPressed: (){ noteManager.addNote(Note('<untitled>', '<empty>')); },
        tooltip: 'Add note',
        child: const Icon(Icons.add),
      ),
    );
  }
}
