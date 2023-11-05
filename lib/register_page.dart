import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  BuildContext? _context;

  showAlertDialog(title, message, [context]) {
    context = context ?? _context!;
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordCheckController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(30),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Name',
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Email',
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Password',
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
              child: TextField(
                controller: passwordCheckController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Password Again',
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(15),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.all(10),
                ),
                onPressed: () async {
                  if (!RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(emailController.text)) {
                    showAlertDialog('Incorrect Email',
                        'The email that you typed is not correct. Please try again.');
                    return;
                  }
                  if (passwordController.text != passwordCheckController.text) {
                    showAlertDialog('Incorrect Password',
                        'The password that you typed is not the same. Please try again.');
                    return;
                  }
                  final supabase = Supabase.instance.client;
                  supabase.from('users').insert([
                    {
                      'email': emailController.text,
                      'name': nameController.text,
                      'password': passwordController.text,
                    }
                  ]).then((value) {
                    print(value);
                    print('a');
                    Navigator.pop(context, {'registerSuccess': true});
                  }).catchError((e) {
                    print(e.toString());
                    if (e.toString().contains(
                        'PostgrestException(message: duplicate key value violates unique constraint "users_email_key", code: 23505')) {
                      showAlertDialog('Register Failed',
                          'Email that you typed is already registered. Please try again.');
                    } else if (e.toString().contains(
                        'PostgrestException(message: duplicate key value violates unique constraint "users_name_key", code: 23505')) {
                      showAlertDialog('Register Failed',
                          'Name that you typed is already registered. Please try again.');
                    } else {
                      print(e);
                    }
                  });
                },
                child: Text('Ok'),
              ),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context, {'registerSuccess': false});
              },
              child: Text('Cancel'),
            )
          ],
        ),
      ),
    );
  }
}
