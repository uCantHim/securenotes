import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'config.dart';
import 'firsttime_login_page.dart';
import 'loading_page.dart';
import 'login_page.dart';
import 'note_manager.dart';
import 'note_storage.dart';
import 'note_storage_widget.dart';
import 'util_widgets.dart';

/// Used to access the context in out-of-build alert dialogs.
final navigatorKey = GlobalKey<NavigatorState>();

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
        useMaterial3: true,

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

        // Custom corner rounding for all buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: defaultButtonStyle,
        ),
      ),
      home: const MyHomePage(
        title: 'Flutter Demo Home Page',
      ),

      navigatorKey: navigatorKey,
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

class MyAppState extends State<MyHomePage> {
  AppConfig? _config;
  NoteManager? _noteManager;

  MyAppState() {
    AppConfig.loadSystemConfig()
        // Initialize app configuration
        .then((conf) { setState((){ _config = conf; }); });
  }

  @override
  Widget build(BuildContext context) {
    initNoteManager(String storagePath, String password) {
      final storage = NoteStorage(storagePath, password);
      return NoteManager.fromStorage(storage)
          .then((notes) {
            setState((){ _noteManager = notes; });
          });
    }

    if (_noteManager != null) {
      return NotePage(noteManager: _noteManager!);
    }

    if (_config == null) {
      return const LoadingPage();
    }

    if (File(_config!.noteStorageFilePath).existsSync()) {
      return LoginPage(
        onPasswordEntered: (password) {
          return initNoteManager(_config!.noteStorageFilePath, password)
              .then((_) => PasswordStatus.eCorrect)
              .catchError((_) => PasswordStatus.eIncorrect);
        }
      );
    }

    return CreatePasswordPage(
      onPasswordSubmit: (password) {
        initNoteManager(_config!.noteStorageFilePath, password);
      },
      onStorageFileSelect: (file) async {
        assert(File(file).existsSync());
        assert(_config != null);
        assert(!File(_config!.noteStorageFilePath).existsSync());

        await File(file).copy(_config!.noteStorageFilePath);
        setState(() { /* A new storage object was loaded. */ });
      },
    );
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
