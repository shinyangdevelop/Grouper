import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: '/config/.ENV');
  await Supabase.initialize(
      url: dotenv.env['URL']!, anonKey: dotenv.env['Key']!);

  runApp(Grouper());
}

class Grouper extends StatelessWidget {
  const Grouper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grouper',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isLoggedIn = false;
  String userName = '';
  int userId = -1;

  @override
  void initState() {
    super.initState();
    loadAppStatus();
  }

  Future<void> loadAppStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = (prefs.getBool('loginStatus') ?? false);
      userName = (prefs.getString('userName') ?? '');
      userId = (prefs.getInt('userId') ?? -1);
    });
  }

  Future<void> updateAppStatus(
      bool loginStatus, int? userId_, String? userName_) async {
    final prefs = await SharedPreferences.getInstance();
    if (loginStatus) {
      setState(() {
        userName = userName_!;
        isLoggedIn = true;
        userId = userId_!;
        prefs.setBool('loginStatus', true);
        prefs.setInt('userId', userId_);
        prefs.setString('userName', userName_);
      });
    } else {
      userName = '';
      isLoggedIn = false;
      userId = -1;
      prefs.setBool('loginStatus', false);
      prefs.remove('userId');
      prefs.remove('userName');
    }
  }

  @override
  Widget build(BuildContext context) {
    loadAppStatus();
    if (!isLoggedIn) {
      return LoginPage();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Grouper'),
        centerTitle: true,
        elevation: 0.0,
        leading: Text(userName),
        leadingWidth: 100,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              updateAppStatus(false, null, null);
            },
          ),
        ],
      ),
      body: Align(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 100,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 50,
                    margin: EdgeInsets.fromLTRB(25, 15, 25, 15),
                    color: Colors.grey[900],
                    child: Center(child: Text('Entry ${index + 1}')),
                  );
                }
              )
            )
          ],
        ),
      ),
    );
  }
}

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
            )
          ],
        ),
      ),
    );
  }
}
