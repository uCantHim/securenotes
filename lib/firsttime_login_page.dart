import 'package:flutter/material.dart';

class CreatePasswordPage extends StatefulWidget {
  const CreatePasswordPage({ super.key, required this.onPasswordSubmit, });

  final Function(String password) onPasswordSubmit;

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
    var mainColumn = Column(
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

        // Submit button
        if (_canSubmit())
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  widget.onPasswordSubmit(password);
                },
                child: const Text('Create', style: TextStyle(fontSize: 20)),
              )
            ),
          ),

        // Conditional error text if password is incorrect
        if (errorText != null)
          Text(errorText!, style: kErrorTextStyle),
      ],
    );

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: mainColumn,
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
    if (password.length <= kMinPasswordLength) {
      return 'Password must be at least $kMinPasswordLength characters long.';
    }
    if (password != passwordRepeat) {
      return 'The entered passwords are not equal.';
    }
    return null;
  }

  bool _canSubmit() => _checkPasswordIntegrity() == null;
}
