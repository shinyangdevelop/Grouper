import 'package:flutter/material.dart';
import 'package:grouper/util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grouper/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  showAlertDialog() {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Incorrect Login Data"),
      content: Text(
          "The email or password that you typed is wrong. Please try again."),
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

  final supabase = Supabase.instance.client;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(30),
        child: Column(
          children: <Widget>[
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
            OutlinedButton(
              onPressed: () async {
                var loginSuccess = await Util.checkLoginData(
                    emailController.text, passwordController.text);
                if (loginSuccess['success']) {
                  print('${loginSuccess['userId']} ${loginSuccess['name']}');
                  await Util.updateLoginStatus(
                      true, loginSuccess['userId'], loginSuccess['name']);
                  Navigator.pushNamed(context,
                      '/main'); //TODO: improve this method => not to use context across async gaps
                } else {
                  await Util.updateLoginStatus(false, null, null);
                  showAlertDialog();
                }
              },
              child: Text('Confirm'),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                child: OutlinedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterPage()));
                    if (!mounted) return;
                    if (result['registerSuccess']) {
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                            SnackBar(content: Text('Register Success')));
                    }
                  },
                  child: Text('Register'),
                )),
          ],
        ),
      ),
    );
  }
}
