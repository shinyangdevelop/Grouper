import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:grouper/registerPage.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> updateAppStatus(
      bool loginStatus, int? userId_, String? userName_) async {
    final prefs = await SharedPreferences.getInstance();
    if (loginStatus) {
      setState(() {
        prefs.setBool('loginStatus', true);
        prefs.setInt('userId', userId_!);
        prefs.setString('userName', userName_!);
      });
    } else {
      prefs.setBool('loginStatus', false);
      prefs.remove('userId');
      prefs.remove('userName');
    }
  }

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

  Future<Map<String, dynamic>> checkLoginData(
      String email, String password) async {
    final data = await supabase
        .from('users')
        .select('id,password,name')
        .eq('email', email);
    try {
      if (data.length == 0) {
        return {'success': false};
      } else {
        if (data[0]['password'] == password) {
          return {
            'success': true,
            'userId': data[0]['id'],
            'name': data[0]['name']
          };
        } else {
          return {'success': false};
        }
      }
    } catch (e) {
      print(e.toString());
      return {'success': false};
    }
  }

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
                var loginSuccess = await checkLoginData(
                    emailController.text, passwordController.text);
                if (loginSuccess['success']) {
                  print('${loginSuccess['userId']} ${loginSuccess['name']}');
                  updateAppStatus(
                      true, loginSuccess['userId'], loginSuccess['name']);
                } else {
                  updateAppStatus(false, null, null);
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
