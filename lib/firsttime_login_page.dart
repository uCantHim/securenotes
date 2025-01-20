import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'util_widgets.dart';

class CreatePasswordPage extends StatefulWidget {
  const CreatePasswordPage({
    super.key,
    required this.onPasswordSubmit,
    required this.onStorageFileSelect,
  });

  final Function(String password) onPasswordSubmit;
  final Function(String path) onStorageFileSelect;

  @override
  State<CreatePasswordPage> createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  static const int kMinPasswordLength = 1;
  static const kErrorTextStyle = TextStyle(color: Colors.red);

  String password = '';
  String passwordRepeat = '';
  String? errorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: IntrinsicWidth(
          child: Column(
            children: [
              _buildPasswordCreateForm(context),
              const Padding(
                padding: EdgeInsets.only(top: 30.0, bottom: 30.0),
                child: TextDivider(child: Text('or')),
              ),
              _buildFileSelectForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordCreateForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description:
        const Text(
          'Create a secure password. Don\'t forget it, or your notes will be'
          ' lost forever.',
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 20),
        ),
        const Padding(padding: EdgeInsets.only(top: 3.0)),

        // Password input text field
        TextField(
          obscureText: true,
          onChanged: (text) {
            _setPasswordFields(text, null);
          },
          onSubmitted: (text) {
            if (_canSubmit()) {
              widget.onPasswordSubmit(password);
            }
          },
        ),

        // Password confirmation text field
        TextField(
          obscureText: true,
          onChanged: (text) {
            _setPasswordFields(null, text);
          },
          onSubmitted: (text) {
            if (_canSubmit()) {
              widget.onPasswordSubmit(password);
            }
          },
        ),

        // Error text and 'create' button are in the same row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Conditional error text if password is incorrect
            Text(errorText ?? '', style: kErrorTextStyle),

            // Submit button
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: !_canSubmit() ? null : () {
                    widget.onPasswordSubmit(password);
                  },
                  child: const Text('Create', style: TextStyle(fontSize: 20)),
                )
              ),
            ),
          ]
        ),
      ],
    );
  }

  Widget _buildFileSelectForm(BuildContext context) {
    return TextButton(
      onPressed: () {
        FilePicker.platform.pickFiles(allowMultiple: false)
            .then((FilePickerResult? res) {
              if (res != null) {
                widget.onStorageFileSelect(res.files.single.path!);
              }
            });
      },
      //style: TextButton.styleFrom(
      //  foregroundColor: Colors.white,
      //  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      //),
      child: const Text(
        'Import backup file',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  void _setPasswordFields(String? pw, String? pwRepeat) {
    setState(() {
      password = pw ?? password;
      passwordRepeat = pwRepeat ?? passwordRepeat;
      errorText = _checkPasswordIntegrity();
    });
  }

  /// Returns an error message if the entered password is invalid, or
  /// [null] if it is valid.
  String? _checkPasswordIntegrity() {
    if (password.length < kMinPasswordLength) {
      return 'Password must be at least $kMinPasswordLength characters long.';
    }
    if (password != passwordRepeat) {
      return 'The entered passwords are not equal.';
    }
    return null;
  }

  bool _canSubmit() => _checkPasswordIntegrity() == null;
}
