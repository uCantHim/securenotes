import 'package:flutter/material.dart';

enum PasswordStatus {
  eIncorrect,
  eCorrect,
}

class LoginPage extends StatefulWidget {
  const LoginPage({ super.key, required this.onPasswordEntered });

  final Future<PasswordStatus> Function(String password) onPasswordEntered;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool passwordEnteredButIncorrect = false;

  @override
  Widget build(BuildContext context) {
    var mainColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description:
        const Text(
          'Enter your encryption key to unlock your notes:',
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 20),
        ),
        const Padding(padding: EdgeInsets.only(top: 3.0)),

        // The password input text field:
        TextField(
          obscureText: true,
          onChanged: (_) {
            setState(() { passwordEnteredButIncorrect = false; });
          },
          onSubmitted: (text) {
            widget.onPasswordEntered(text)
                .then((status) {
                  setState(() {
                    passwordEnteredButIncorrect = status == PasswordStatus.eIncorrect;
                  });
                });
          },
        ),

        // Conditional error text if password is incorrect:
        if (passwordEnteredButIncorrect)
          const Text(
            'Incorrect password!',
            style: TextStyle(color: Colors.red),
          ),
      ],
    );

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: mainColumn,
      ),
    );
  }
}
